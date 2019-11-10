# vim: set sts=2 ts=2 sw=2 expandtab :

{ config, pkgs, lib, ... }:

let
  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    rev = "dd94a849df69fe62fe2cb23a74c2b9330f1189ed";
    ref = "release-18.09";
  };
in
{
  imports =
    [ # home-manager for per-user management
      "${home-manager}/nixos"

      ./robashton
    ];

  # Can't get this working with virtualbox
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  # Select internationalisation properties.
  i18n = {
    # consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";

    # English Language with sensible formatting
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  services.timesyncd.enable = true; # the default, but explicitness is a good thing
  time.timeZone = "Europe/London";

  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [

    # Admin & Development Tools
    wget
    #vim
    pavucontrol
    openssh
    git git-lfs
    tmux
    ripgrep
    htop iotop iftop
    lftp
    tree
    bashCompletion
    wireshark
    wireshark-cli
    iperf
    pv
    mbuffer
    openssl
    tcpdump
    ethtool
    jq
    awscli
    unzip
    dnsutils 
    manpages
    pciutils usbutils
    fwupd
    shellcheck
    nixops
    gccStdenv 

    # Docker - until I can obviate it
    docker
    docker-gc
    docker-ls

    # General web things
    firefox-bin
    google-chrome
    skypeforlinux
    slack
    zoom-us

    # Security
    gnupg
    srm
    keepassxc

    # Desktop Env
    gnome3.dconf 
    gnome3.dconf-editor
    gnome3.gnome-screenshot
    mate.mate-calc
    dmenu
    xclip
    alacritty
    feh
    libreoffice-still

    # Hardware Acceleration Utilities
    libva-utils
    glxinfo

    ( writeScriptBin "ra-audio-get-master-volume" ''
      #!${pkgs.bash}/bin/bash
      amixer sget Master | awk -F '[][]' '/.*Left:/ { print $2 }'
    ''
    )
  
    ( writeScriptBin "ra-audio-get-master-status" ''
      #!${pkgs.bash}/bin/bash
      amixer sget Master | awk -F '[][]' '/.*Left:/ { print $4 }'
    ''
    )
  
    ( writeScriptBin "ra-audio-get-capture-volume" ''
       #!${pkgs.bash}/bin/bash
       amixer sget Capture | awk -F '[][]' '/.*Left:/ { print $2 }'
    ''
    )
  
    ( writeScriptBin "ra-audio-get-capture-status" ''
       #!${pkgs.bash}/bin/bash
       amixer sget Capture | awk -F '[][]' '/.*Left:/ { print $4 }'
    ''
    ) 
  ];


  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = false;
    };
  };

  # It's useful to be able to manage firmware
  services.fwupd.enable = true;

  # And thunderbolt things
  services.hardware.bolt.enable = true;

  programs = {
    ssh.startAgent = false;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    # Honestly, nano can just go and die in a fire (lol, totes)
    vim.defaultEditor = true;

    bash = {
      enableCompletion = true;
    };

    wireshark = {
      enable = true;
    };
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    challengeResponseAuthentication = false;
    openFirewall = false;
  };

  # Allow docker0 to bypass the firewall
  networking.firewall.extraCommands = ''
    ip46tables -I nixos-fw 1 -i docker0 -j nixos-fw-accept
  '';

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "us";
    xkbOptions = "ctrl:swapcaps";

    displayManager = {
      lightdm.enable = true;
      sessionCommands = ''
        ${pkgs.feh}/bin/feh --bg-fill ~/.config/wallpapers/rainbow-dash.jpg
      '';
    };

    windowManager = {
      default = "xmonad";

      xmonad = {
        enable = true;
        enableContribAndExtras = true;
        extraPackages = haskellPackages: with haskellPackages; [
          xmobar
        ];
      };
    };

    desktopManager = {
      default = "none";
      xterm.enable = false;
    };
  };

  services.compton = {
    vSync           = true;
    backend         = "glx";
    enable          = true;
    fade            = true;
    shadow          = true;
    # inactiveOpacity = "0.9";
    fadeDelta       = 4;
    opacityRules    = [
      "90:class_g *= 'Alacritty'"
    ];
  };

  # services.xserver.xkbOptions = "eurosign:e";

  # Enable passwd and co.
  users.mutableUsers = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?
}
