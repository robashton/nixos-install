# NixOS Configuration Modernization Plan

## Current State Assessment

### Repository Structure

```
nixos-install/
├── common/
│   ├── default.nix             # 467 lines - main shared config (MANY deprecated options)
│   ├── robashton/
│   │   ├── default.nix         # Fetches home-manager from GitHub (should use flake input)
│   │   ├── hm.nix              # Custom merge logic (should use standard imports)
│   │   ├── hm-nixos.nix
│   │   ├── hm-tmux.nix
│   │   ├── hm-neovim.nix
│   │   ├── hm-git.nix          # Has deprecated git options
│   │   ├── hm-xmonad.nix
│   │   ├── hm-direnv.nix
│   │   ├── hm-emacs.nix
│   │   ├── hm-wayland.nix
│   │   └── files/
│   ├── adrian/default.nix      # 48 lines - boilerplate
│   ├── alex/default.nix        # 37 lines - boilerplate
│   ├── steve/default.nix       # 48 lines - boilerplate
│   ├── stears/default.nix      # 48 lines - boilerplate
│   ├── nicholaw/default.nix    # 48 lines - boilerplate
│   ├── power.nix               # Good - TLP config
│   ├── laptop-suspend.nix
│   ├── fake-laptop-sleep.nix   # Good - custom lid handling
│   ├── pony-notify.nix         # Good - notification system
│   └── files/
│       ├── bash-prompt.sh
│       └── sshconfig
├── hosts/
│   ├── ashton-recoil/
│   │   ├── flake.nix           # nixos-25.11
│   │   ├── configuration.nix
│   │   ├── hardware-configuration.nix
│   │   └── robashton/
│   ├── ashton-nuc/
│   │   ├── flake.nix           # nixos-24.05 (DIFFERENT VERSION!)
│   │   ├── configuration.nix
│   │   └── hardware-configuration.nix
│   └── ashton-studio/
│       ├── flake.nix           # nixos-23.05 + nix-darwin (DIFFERENT VERSION!)
│       └── ...
└── scripts/
    └── setup_vim.sh
```

---

## PROBLEM 1: Deprecated Options (11 warnings)

### In `common/default.nix`:

**Line 315** - Bash completion:
```nix
# CURRENT (deprecated):
programs.bash.enableCompletion = true;

# SHOULD BE:
programs.bash.completion.enable = true;
```

**Lines 333-339** - OpenSSH settings:
```nix
# CURRENT (deprecated):
services.openssh = {
  enable = true;
  passwordAuthentication = false;        # Line 335
  kbdInteractiveAuthentication = false;  # Line 336
  openFirewall = false;
  forwardX11 = true;                     # Line 338
};

# SHOULD BE:
services.openssh = {
  enable = true;
  openFirewall = false;
  settings = {
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
    X11Forwarding = true;
  };
};
```

**Lines 400-405** - PulseAudio (hardware.pulseaudio -> services.pulseaudio):
```nix
# CURRENT (deprecated):
hardware.pulseaudio.extraConfig = "unload-module module-switch-on-port-available";
hardware.pulseaudio.configFile = pkgs.runCommand "default.pa" {} ''...''

# SHOULD BE:
services.pulseaudio.extraConfig = "unload-module module-switch-on-port-available";
services.pulseaudio.configFile = pkgs.runCommand "default.pa" {} ''...''
```

**Lines 412-414** - Display manager:
```nix
# CURRENT (deprecated):
services.xserver.displayManager.gdm.enable = true;
services.xserver.displayManager.defaultSession = "none+xmonad";

# SHOULD BE:
services.displayManager.gdm.enable = true;
services.displayManager.defaultSession = "none+xmonad";
# Keep sessionCommands under services.xserver.displayManager.sessionCommands
```

**Lines 430-431** - GNOME desktop:
```nix
# CURRENT (deprecated):
services.xserver.desktopManager.gnome.enable = true;

# SHOULD BE:
services.desktopManager.gnome.enable = true;
```

### In `hosts/ashton-recoil/configuration.nix`:

**Line 82** - xkbOptions:
```nix
# CURRENT (deprecated):
services.xserver.xkbOptions = "ctrl:swapcaps";

# SHOULD BE:
services.xserver.xkb.options = "ctrl:swapcaps";
```

**Line 84-85** - Display manager and GNOME (duplicates common/default.nix):
```nix
# CURRENT (deprecated):
services.xserver.displayManager.gdm.enable = true;
services.xserver.desktopManager.gnome.enable = true;

# SHOULD BE:
services.displayManager.gdm.enable = true;
services.desktopManager.gnome.enable = true;
```

### In `common/robashton/hm-git.nix` (Home-Manager):

```nix
# CURRENT (deprecated):
programs.git.userName = "...";
programs.git.userEmail = "...";

# SHOULD BE:
programs.git.settings.user.name = "...";
programs.git.settings.user.email = "...";
```

---

## PROBLEM 2: Decentralized Flakes with Duplicated Logic

### Current: Each host has its own flake.nix

**hosts/ashton-recoil/flake.nix:**
```nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  inputs.private = { url = "git+ssh://git@github.com/robashton/nixos-install-private"; };
  inputs.neovim = { url = "git+ssh://git@github.com/robashton/flake-neovim"; };
  inputs.hx = { url = "git+ssh://git@github.com/robashton/flake-helix"; };

  outputs = { self, nixpkgs, private, neovim, hx }: {
    nixosConfigurations.ashton-recoil = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ pkgs, ... }: {
          system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
          nix.extraOptions = "experimental-features = nix-command flakes";
          nixpkgs.overlays = [
             (_: _: { ashton-private = private.legacyPackages.x86_64-linux; })
             (_: _: { ashton-neovim = neovim.packages.x86_64-linux.default; })
             (_: _: { ashton-hx = hx.packages.x86_64-linux.default; })
          ];
        })
        ./configuration.nix {}
      ];
    };
  };
}
```

**hosts/ashton-nuc/flake.nix:** (ALMOST IDENTICAL but different nixpkgs version!)
```nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";  # <-- DIFFERENT!
  inputs.private = { url = "git+ssh://git@github.com/robashton/nixos-install-private"; };
  inputs.neovim = { url = "/home/robashton/src/flake-neovim"; };  # <-- LOCAL PATH (inconsistent)
  inputs.hx = { url = "git+ssh://git@github.com/robashton/flake-helix"; };
  # ... same overlay pattern ...
}
```

### Issues:
1. **Version drift**: recoil=25.11, nuc=24.05, studio=23.05
2. **Duplicated overlay definitions** in every flake
3. **Inconsistent input URLs**: Some use git+ssh, nuc uses local path for neovim
4. **No single source of truth** for inputs

---

## PROBLEM 3: Custom Home-Manager Aggregation

### Current: `common/robashton/hm.nix` (46 lines)

```nix
{ pkgs, lib, ... }:

let
  modules = [
    ./hm-nixos.nix
    ./hm-tmux.nix
    ./hm-neovim.nix
    ./hm-git.nix
    ./hm-xmonad.nix
    ./hm-direnv.nix
    ./hm-emacs.nix
    ./hm-wayland.nix
  ];

  moduleResults = builtins.map runModule modules;
  runModule = module: import module { inherit pkgs lib; };
  combined = builtins.foldl' mergeResult emptyAcc moduleResults;

  emptyAcc = { home = {
    stateVersion = "23.11";
    packages = []; }; };

  # This is a deep set merge, right-hand-side wins,
  # it's not perfect but it should do
  mergeResult =
    acc: moduleResult:
      let
        modulePackages = lib.attrsets.attrByPath [ "home" "packages" ] [] moduleResult;
        currentPackages = acc.home.packages;
        allPackages = modulePackages ++ currentPackages;
        moduleResultPatched = lib.recursiveUpdate moduleResult { home = { packages = allPackages; }; };
      in
        lib.recursiveUpdate acc moduleResultPatched;

in
  combined
```

### Why this is problematic:
1. **Reinvents the module system** - NixOS/home-manager already handles this
2. **Fragile** - doesn't handle all merge cases (only packages list)
3. **Hard to extend** - adding new merge logic requires modifying this file
4. **Breaks module features** - things like `mkIf`, `mkMerge`, `mkDefault` won't work properly

### Should be:
```nix
{ pkgs, lib, ... }:
{
  imports = [
    ./hm-nixos.nix
    ./hm-tmux.nix
    ./hm-neovim.nix
    ./hm-git.nix
    ./hm-xmonad.nix
    ./hm-direnv.nix
    ./hm-emacs.nix
    ./hm-wayland.nix
  ];

  home.stateVersion = "23.11";
}
```

**BUT** this requires updating each hm-*.nix file to be a proper module (add the standard function signature).

---

## PROBLEM 4: Home-Manager Fetched from GitHub in User Config

### Current: `common/robashton/default.nix` (lines 3-8)

```nix
let
  home-manager = builtins.fetchGit {
    url = "https://github.com/nix-community/home-manager.git";
    rev = "20561be440a11ec57a89715480717baf19fe6343";
    ref = "release-25.11";
  };
in
{
  imports = [
    "${home-manager}/nixos"
  ];
  # ...
}
```

### Why this is problematic:
1. **Not reproducible** - different from flake.lock pinning
2. **Version mismatch risk** - HM version might not match nixpkgs version
3. **Should be a flake input** - centralized, locked, follows nixpkgs

---

## PROBLEM 5: User Config Boilerplate

### Current: 5 nearly identical files

**common/adrian/default.nix** (48 lines):
```nix
{ config, pkgs, lib, ... }:
{
  users.extraGroups.adrian = {};
  users.users.adrian = {
    isNormalUser = true;
    extraGroups = [ "docker" "wireshark" "video" "tmux" ];
    createHome = true;
    home = "/home/adrian";
    group = "adrian";
    openssh.authorizedKeys.keys = [
      (import ./files/pubkey-adrian.nix)
    ];
  };

  home-manager.users.adrian = {
    home.packages = (with pkgs; []);
    home.stateVersion = "24.05";
    programs.vim = { enable = false; plugins = []; /* ... */ };
    programs.bash = { enable = true; };
    programs.direnv = { enable = true; enableBashIntegration = true; };
    programs.home-manager = { enable = true; };
  };
}
```

**alex, steve, stears, nicholaw** - ALL NEARLY IDENTICAL (only name and SSH key differ)

### Should be: A reusable function

```nix
# users/mkGuestUser.nix
{ name, sshKeyFile, stateVersion ? "25.11", extraGroups ? [] }:
{ config, pkgs, lib, ... }:
{
  users.extraGroups.${name} = {};
  users.users.${name} = {
    isNormalUser = true;
    extraGroups = [ "docker" "wireshark" "video" "tmux" ] ++ extraGroups;
    createHome = true;
    home = "/home/${name}";
    group = name;
    openssh.authorizedKeys.keys = [ (import sshKeyFile) ];
  };

  home-manager.users.${name} = {
    home.stateVersion = stateVersion;
    home.packages = [];
    programs.bash.enable = true;
    programs.direnv = { enable = true; enableBashIntegration = true; };
    programs.home-manager.enable = true;
  };
}
```

Usage:
```nix
imports = [
  (import ../users/mkGuestUser.nix {
    name = "adrian";
    sshKeyFile = ./files/pubkey-adrian.nix;
  })
];
```

---

## PROBLEM 6: Overlay in Host Config

### Current: `hosts/ashton-recoil/configuration.nix` (lines 158-169)

```nix
nixpkgs.overlays = [
  (final: prev: {
    avell-unofficial-control-center =
      prev.avell-unofficial-control-center.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace aucc/main.py \
            --replace "product_id=0xce00" "product_id=0x600b"
          substituteInPlace aucc/main.py \
            --replace "from elevate import elevate" "" \
            --replace "if not os.geteuid() == 0:" "if False:" \
            --replace "elevate()" "pass"
        '';
      });
  })
];
```

### Should be: Extracted to a module

```nix
# modules/overlays/aucc.nix
{ config, pkgs, lib, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      avell-unofficial-control-center =
        prev.avell-unofficial-control-center.overrideAttrs (old: {
          postPatch = (old.postPatch or "") + ''
            # Patch for PCSpecialist Recoil 16 keyboard (048d:600b)
            substituteInPlace aucc/main.py \
              --replace "product_id=0xce00" "product_id=0x600b"
            # Remove root check - udev rules handle permissions
            substituteInPlace aucc/main.py \
              --replace "from elevate import elevate" "" \
              --replace "if not os.geteuid() == 0:" "if False:" \
              --replace "elevate()" "pass"
          '';
        });
    })
  ];
}
```

---

## Proposed Target Architecture

### Root flake.nix (NEW FILE)

```nix
{
  description = "Rob Ashton's NixOS configurations";

  inputs = {
    # Pin nixpkgs for all hosts
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    # Home-manager follows nixpkgs
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Darwin for macOS
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Private packages/secrets
    private.url = "git+ssh://git@github.com/robashton/nixos-install-private";

    # Custom editor flakes
    neovim.url = "git+ssh://git@github.com/robashton/flake-neovim";
    hx.url = "git+ssh://git@github.com/robashton/flake-helix";
  };

  outputs = { self, nixpkgs, home-manager, darwin, private, neovim, hx, ... }:
  let
    # Shared overlay for all systems
    sharedOverlays = [
      (_: _: { ashton-private = private.legacyPackages.x86_64-linux; })
      (_: _: { ashton-neovim = neovim.packages.x86_64-linux.default; })
      (_: _: { ashton-hx = hx.packages.x86_64-linux.default; })
    ];

    # Common module for all NixOS hosts
    commonNixOSModule = { pkgs, ... }: {
      system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
      nix.extraOptions = "experimental-features = nix-command flakes";
      nixpkgs.overlays = sharedOverlays;
    };
  in
  {
    nixosConfigurations = {
      ashton-recoil = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          commonNixOSModule
          home-manager.nixosModules.home-manager
          ./hosts/ashton-recoil/configuration.nix
        ];
      };

      ashton-nuc = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          commonNixOSModule
          home-manager.nixosModules.home-manager
          ./hosts/ashton-nuc/configuration.nix
        ];
      };
    };

    darwinConfigurations = {
      ashton-studio = darwin.lib.darwinSystem {
        system = "aarch64-darwin";  # or x86_64-darwin
        modules = [
          home-manager.darwinModules.home-manager
          ./hosts/ashton-studio/configuration.nix
        ];
      };
    };
  };
}
```

### Proposed Directory Structure

```
nixos-install/
├── flake.nix                    # NEW: Root flake (single source of truth)
├── flake.lock                   # NEW: Pinned versions
│
├── modules/                     # NEW: Reusable NixOS modules
│   ├── common.nix              # Refactored from common/default.nix
│   ├── desktop.nix             # GNOME/GDM/Xserver stuff
│   ├── power.nix               # Moved from common/power.nix
│   ├── ssh.nix                 # OpenSSH config
│   └── overlays/
│       ├── default.nix         # Aggregates all overlays
│       └── aucc.nix            # Keyboard LED overlay
│
├── users/                       # NEW: User definitions
│   ├── robashton/              # Full user config (current common/robashton/)
│   │   ├── default.nix
│   │   └── home/               # Home-manager modules
│   │       ├── default.nix     # imports all below
│   │       ├── git.nix
│   │       ├── tmux.nix
│   │       ├── neovim.nix
│   │       ├── xmonad.nix
│   │       ├── wayland.nix
│   │       └── direnv.nix
│   ├── mkGuestUser.nix         # Function to create guest users
│   └── guests.nix              # All guest user definitions
│
├── hosts/
│   ├── recoil/                 # Simplified (no flake.nix)
│   │   ├── default.nix         # Host-specific config
│   │   └── hardware.nix        # hardware-configuration.nix
│   ├── nuc/
│   │   ├── default.nix
│   │   └── hardware.nix
│   └── studio/
│       ├── default.nix
│       └── hardware.nix
│
└── lib/                         # NEW: Helper functions
    └── default.nix
```

---

## Migration Checklist

### Phase 1: Fix Deprecated Options (LOW RISK)
- [ ] `common/default.nix` line 315: `enableCompletion` -> `completion.enable`
- [ ] `common/default.nix` lines 335-338: openssh settings
- [ ] `common/default.nix` lines 400-405: `hardware.pulseaudio` -> `services.pulseaudio`
- [ ] `common/default.nix` lines 412-414: displayManager path
- [ ] `common/default.nix` line 431: desktopManager path
- [ ] `hosts/ashton-recoil/configuration.nix` line 82: xkbOptions
- [ ] `hosts/ashton-recoil/configuration.nix` lines 84-85: displayManager/desktopManager
- [ ] `common/robashton/hm-git.nix`: userName/userEmail

### Phase 2: Create Root Flake (MEDIUM RISK)
- [ ] Create `flake.nix` at repo root
- [ ] Define all inputs once
- [ ] Create shared overlay definition
- [ ] Export nixosConfigurations for recoil and nuc
- [ ] Export darwinConfigurations for studio
- [ ] Test with `nix flake check`
- [ ] Test build: `nix build .#nixosConfigurations.ashton-recoil.config.system.build.toplevel`

### Phase 3: Migrate Hosts to Root Flake (MEDIUM RISK)
- [ ] Update recoil to use root flake
- [ ] Keep old host flake.nix as backup (rename to flake.nix.bak)
- [ ] Test full rebuild on recoil
- [ ] Repeat for nuc
- [ ] Repeat for studio (darwin)

### Phase 4: Refactor HM Aggregation (MEDIUM RISK)
- [ ] Convert each hm-*.nix to proper module format
- [ ] Replace custom merge in hm.nix with standard imports
- [ ] Test home-manager activation

### Phase 5: Cleanup (LOW RISK)
- [ ] Extract aucc overlay to module
- [ ] Create mkGuestUser function
- [ ] Replace 5 user files with function calls
- [ ] Reorganize directory structure
- [ ] Delete old host flake.nix backups

---

## Commands Reference

```bash
# Current (per-host flake)
cd ~/src/nixos-install/hosts/ashton-recoil
sudo nixos-rebuild switch --flake .#ashton-recoil

# After migration (root flake)
cd ~/src/nixos-install
sudo nixos-rebuild switch --flake .#ashton-recoil

# Check flake validity
nix flake check

# Update all inputs
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs

# Show flake info
nix flake show

# Build without switching (for testing)
nix build .#nixosConfigurations.ashton-recoil.config.system.build.toplevel
```

---

## Notes for Resumption

- **Test on recoil first** - it's the daily driver
- **Keep backups** - rename old flake.nix files, don't delete
- **Phase 1 is safe** - just option renames, can do anytime
- **Phase 2 is the big one** - creating root flake changes workflow
- **home-manager module in flake** - use `home-manager.nixosModules.home-manager`
- **Darwin uses different module** - `home-manager.darwinModules.home-manager`
- The `private` flake provides `pkgs.ashton-private.hosts` for `/etc/hosts` entries
