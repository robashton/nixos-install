{ pkgs, hostname, ... }:
let
  brewPkgs = [
    "tailscale"
  ];
  brewCasks = [
    "audacity"
    "discord"
    "dropbox"
    "firefox"
    "google-chrome"
    "launchcontrol"
    "loopback"
    "lunar"
    "native-access"
    "skype"
    "slack"
    "spotify"
    "vlc"
    "wireshark"
    "zoom"
    "iterm2"
    "rectangle"
    "docker"
  ];
  nixPkgs = with pkgs; [
    # ashton-neovim
    ashton-hx
    arp-scan
    awscli2
    bat
    clang
    coreutils
    curl
    tmux
    diff-so-fancy
    fd
    (ffmpeg-full.override { withGme = false; })
    fzf
    git-lfs
    git-filter-repo
    gnumake
    gnupg
    iftop
    jc
    jq
    m-cli
    nmap
    nodejs
    python3
    ripgrep
    rsync
    silver-searcher
    terminal-notifier
    tokei
    tldr
    tree
    wget
  ];
in

{
  networking.hostName = hostname;

  nix.package = pkgs.nixVersions.stable;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnsupportedSystem = true;

  programs.zsh.enable = true;
  programs.nix-index.enable = true;


  time.timeZone = "Europe/London";

  # Recreate /run/current-system symlink after boot
  # services.activate-system.enable = true;
  # services.nix-daemon.enable = true;

  homebrew = {
    enable = true;
    global.brewfile = true;
    prefix = "/opt/homebrew";
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      # Homebrew removed `brew bundle --cleanup` (nix-darwin passes it for "zap"/"uninstall"),
      # which aborts the whole activation. Back to "zap" once nix-darwin stops using it.
      cleanup = "none";
    };
    taps = [
    ];
    brews = brewPkgs;
    casks = brewCasks;
    masApps = {

    };
  };

  users.users.robashton = {
    home = "/Users/robashton";
  };


  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.robashton = { pkgs, ... }: {
      home.stateVersion = "23.05";
      home.packages = nixPkgs;
      home.file.".ssh/id_rsa".text = pkgs.ashton-private.id_rsa;
      home.file.".ssh/id_ed25519".text = pkgs.ashton-private.id_ed25519;
      home.file.".ssh/config".source = ../../common/files/sshconfig;

      # https://github.com/nix-community/home-manager/issues/423
      home.sessionVariables = {
        PAGER = "less -R";
      };

      # claude's native installer and the src-todo tools (norsk-daily, issues-*)
      # both land in ~/.local/bin. Via home-manager's session vars this reaches
      # every zsh, including the `zsh -lc` the install-services launchd agents run.
      home.sessionPath = [ "$HOME/.local/bin" ];

      programs.zsh = {
        enable = true;
        enableCompletion = true;
        initContent = ''
          test -f ~/.dir_colors && eval $(dircolors ~/.dir_colors)
          setopt no_share_history
          unsetopt share_history
          bindkey "^[[1;5C" forward-word
          bindkey "^[[1;5D" backward-word
        '';
        shellAliases = {
          vi = "nvim";
          vim = "nvim";
        };
      };

      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };


      programs.htop = {
        enable = true;
        settings.show_program_path = true;
      };

      programs.git = {
        enable = true;
        settings.user = { name = "Rob Ashton"; email = "robashton@codeofrob.com"; };
      };
    };
  };

  system.primaryUser = "robashton";

  system.defaults = {
    dock = {
      autohide = true;
      mru-spaces = false;
      minimize-to-application = true;
    };

    screencapture.location = "/tmp";

    finder = {
      AppleShowAllExtensions = true;
      _FXShowPosixPathInTitle = true;
      FXEnableExtensionChangeWarning = false;
    };

    NSGlobalDomain._HIHideMenuBar = false;
    NSGlobalDomain.NSWindowResizeTime = 0.1;

  };

  # fonts.fontDir.enable = true;
  fonts.packages = with pkgs; [
    fira-code
    font-awesome
    inconsolata
    recursive
    roboto
    roboto-mono
  ];

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };
  system.stateVersion = 6;

  # if I ever remove and re-instal nix, I can remove this line
  ids.gids.nixbld = 30000;
}

