{ config, pkgs, lib, ... }:

let
  private = import ./private { inherit pkgs; };

  # Find an extant release here https://repo.skype.com/deb/pool/main/s/skypeforlinux/
  skypeforlinux_latest_version = "8.64.0.81";
  skypeforlinux_latest = pkgs.skypeforlinux.overrideAttrs (oldAttrs: {
    version = skypeforlinux_latest_version;
    src = pkgs.fetchurl {
      url = "https://repo.skype.com/deb/pool/main/s/skypeforlinux/skypeforlinux_${skypeforlinux_latest_version}_amd64.deb";
      sha256 = "0p6sp45kabm97p3hp3wp087b3k42m26ji99kzhpsz3n9vzjiczjh";
    };
  });
in
{
  imports =
    [ 
      ./robashton
      ./stears
    ];

  security.sudo.extraConfig = ''
    %wheel	ALL=(ALL)	NOPASSWD: ALL
  '';

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

  services.redshift = {
    enable = true;
    latitude = "55.8";
    longitude = "4.2";
  };

  nixpkgs.config.allowUnfree = true;

  environment.interactiveShellInit = ''
    alias vi='vim'
  '';

  users.extraGroups.tmux = {
    gid = 2000;
  };

  system.activationScripts = {
      mnt = {
        text = ''mkdir -p /var/tmux && chgrp -R tmux /var/tmux && chmod -R 2775 /var/tmux/'';
        deps = [];
      };
  };


  environment.systemPackages = with pkgs; [

    # Admin & Development Tools
    wget
    ag

    wine

    nodePackages.purescript-language-server
    sonic-pi

    okular
    dropbox-cli
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

    obs-studio

    # General web things
    firefox-bin
    google-chrome
    skypeforlinux_latest
    slack
    teams
    zoom-us

    # Security
    gnupg
    srm
    #keepassxc

    # Desktop Env
    gnome3.dconf 
    gnome3.dconf-editor
    gnome3.gnome-screenshot
    mate.mate-calc
    dmenu
    xclip
    alacritty
    termite
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

    ( writeScriptBin "id3as-tmux-create" ''
      #!${pkgs.bash}/bin/bash
      tmux -S /var/tmux/$1 new -s $1
    ''
    )

    ( writeScriptBin "id3as-tmux-attach" ''
      #!${pkgs.bash}/bin/bash
      tmux -S /var/tmux/$1 attach -t $1
    ''
    )

    ( writeScriptBin "psls-wrapper" ''
      #!${pkgs.bash}/bin/bash
      cd $1
      purescript-language-server --stdio
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

  networking.extraHosts = private.configuration.hosts;


  # Dropbox
  networking.firewall = {
    allowedTCPPorts = [ 17500 ];
    allowedUDPPorts = [ 17500 ];
  };

  # Speaking of..
  systemd.user.services.dropbox = {
    description = "Dropbox";
    after = [ "xembedsniproxy.service" ];
    wants = [ "xembedsniproxy.service" ];
    wantedBy = [ "graphical-session.target" ];
    environment = {
      QT_PLUGIN_PATH = "/run/current-system/sw/" + pkgs.qt5.qtbase.qtPluginPrefix;
      QML2_IMPORT_PATH = "/run/current-system/sw/" + pkgs.qt5.qtbase.qtQmlPrefix;
    };
    serviceConfig = {
      ExecStart = "${pkgs.dropbox.out}/bin/dropbox";
      ExecReload = "${pkgs.coreutils.out}/bin/kill -HUP $MAINPID";
      KillMode = "control-group"; # upstream recommends process
      Restart = "on-failure";
      PrivateTmp = true;
      ProtectSystem = "full";
      Nice = 10;
    };
  };

  # Allow docker0 to bypass the firewall
  networking.firewall.extraCommands = ''
    ip46tables -I nixos-fw 1 -i docker0 -j nixos-fw-accept
    ip46tables -N LOGDROP
    ip46tables -A LOGDROP -j LOG
    ip46tables -A LOGDROP -j DROP
    ip46tables -I INPUT -p tcp --dport 22 -m state --state NEW -m recent --set
    ip46tables -I INPUT -p tcp --dport 22 -m state --state NEW -m recent  --update --seconds 60 --hitcount 4 -j LOGDROP
  '';

  networking.dhcpcd.extraConfig = ''
        noipv4ll
      '';

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;


  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

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
    fade            = false;
    shadow          = false;
    # inactiveOpacity = "0.9";
    fadeDelta       = 4;
    opacityRules    = [
#      "90:class_g *= 'Alacritty'"
    ];
  };

     nixpkgs.config.permittedInsecurePackages = [
         "google-chrome-81.0.4044.138"
       ];

  # services.xserver.xkbOptions = "eurosign:e";

  # Enable passwd and co.
  users.mutableUsers = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?
}
