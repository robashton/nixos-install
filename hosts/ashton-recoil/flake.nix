{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  # Nix itself from a newer nixpkgs: 2.35 stops nix develop copying the whole flake
  # source into the store each time (disk filled on 2026-11-19).
  inputs.nixpkgs-nix.url = "github:NixOS/nixpkgs/e21fec321d73511849707a7585e4ea155ee4bf40";
  inputs.private = { url = "git+ssh://git@github.com/robashton/nixos-install-private"; };

  inputs.neovim = { url = "git+ssh://git@github.com/robashton/flake-neovim"; };
  inputs.hx = { url = "git+ssh://git@github.com/robashton/flake-helix"; };

  outputs = { self, nixpkgs, nixpkgs-nix, private, neovim, hx }: {
    nixosConfigurations.ashton-recoil = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ pkgs, ... }: {
          system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
          nix.extraOptions = "experimental-features = nix-command flakes";
          nix.package = (import nixpkgs-nix { system = "x86_64-linux"; }).nixVersions.nix_2_35;

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
