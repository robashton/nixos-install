{ pkgs, hostname, ... }:
let
  brewPkgs = [

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
    ashton-neovim
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
    youtube-dl
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
  services.activate-system.enable = true;
  services.nix-daemon.enable = true;

  homebrew = {
    enable = true;
    global.brewfile = true;
    brewPrefix = "/opt/homebrew/bin";
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
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

      # https://github.com/nix-community/home-manager/issues/423
      home.sessionVariables = {
        PAGER = "less -R";
      };

      programs.zsh = {
        enable = true;
        enableCompletion = true;
        initExtra = ''
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
        userName = "Rob Ashton"; userEmail = "robashton@codeofrob.com";
      };
    };
  };

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

  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [
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
}

