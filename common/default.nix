{ config, pkgs, lib, ... }:

let
  private = import ./private { inherit pkgs; };

  # Find an extant release here https://repo.skype.com/deb/pool/main/s/skypeforlinux/
  skypeforlinux_latest_version = "8.80.76.112";
  skypeforlinux_latest = pkgs.skypeforlinux.overrideAttrs (oldAttrs: {
    version = skypeforlinux_latest_version;
    src = pkgs.fetchurl {
      url = "https://repo.skype.com/deb/pool/main/s/skypeforlinux/skypeforlinux_${skypeforlinux_latest_version}_amd64.deb";
      sha256 = "0s84yj6qfb0ysj1c6bk2bg6j8ag7grgzrqkxa714k2hm12lc0ab0";
    };
  });

  discord_latest = pkgs.discord.overrideAttrs (oldArtrs: {
    src = builtins.fetchTarball "https://dl.discordapp.net/apps/linux/0.0.25/discord-0.0.25.tar.gz";
  });

  pls = pkgs.nodePackages.purescript-language-server.override {
    version = "0.15.0";
    src = builtins.fetchurl {
      url = "https://registry.npmjs.org/purescript-language-server/-/purescript-language-server-0.15.0.tgz";
    };
  };


   dbus-sway-environment = pkgs.writeTextFile {
    name = "dbus-sway-environment";
    destination = "/bin/dbus-sway-environment";
    executable = true;

    text = ''
  dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
  systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
  systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      '';
  };

  configure-gtk = pkgs.writeTextFile {
      name = "configure-gtk";
      destination = "/bin/configure-gtk";
      executable = true;
      text = let
        schema = pkgs.gsettings-desktop-schemas;
        datadir = "${schema}/share/gsettings-schemas/${schema.name}";
      in ''
        export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
        gnome_schema=org.gnome.desktop.interface
        gsettings set $gnome_schema gtk-theme 'Dracula'
        '';
  };
in
{
  imports =
    [
      ./robashton
      ./stears
      ./nicholaw
      ./steve
      ./adrian
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

  nix.autoOptimiseStore = true;

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



  programs.steam.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  environment.systemPackages = with pkgs; [

    # Copied and pasted from the nixos sway docs

    # Admin & Development Tools
    wget
    silver-searcher

    wine


    sonic-pi
    appimage-run

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
    bash-completion
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
    man-pages
    pciutils usbutils
    fwupd
    shellcheck
    nixops
    gccStdenv

    motion

    # Docker - until I can obviate it
    docker
    docker-gc
    docker-ls

    obs-studio

    # General web things
    firefox-bin
    google-chrome
    #skypeforlinux_latest
    slack
    discord_latest
    teams
    zoom-us

    # Security
    gnupg
    srm
    #keepassxc

    # Desktop Env
#    gnome3.dconf
#    gnome3.dconf-editor
    gnome3.gnome-screenshot
    mate.mate-calc
    dmenu
    xclip
#    alacritty
    termite
    feh
    libreoffice-still

    # Needed for Coc
    nodejs-14_x

    # Wayland stuff
    wl-clipboard


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

##  services.jack = {
##    jackd.enable = true;
##    alsa.enable = false;
##    loopback = {
##      enable = true;
##    };
##  };

  programs = {
    ssh.startAgent = false;
    ssh.forwardX11 = true;
    ssh.setXAuthLocation = true;

    sway = {
      enable = true;
      wrapperFeatures.gtk = true; # so that gtk works properly
      extraPackages = with pkgs; [
        swaylock
        swayidle
        wl-clipboard
        mako # notification daemon
        alacritty # Alacritty is the default terminal in the config
        dmenu # Dmenu is the default in the config but i recommend wofi since its wayland native
        dbus-sway-environment
        configure-gtk
        wayland
        glib # gsettings
        dracula-theme # gtk theme
        gnome3.adwaita-icon-theme  # default gnome cursors
        swaylock
        swayidle
        grim # screenshot functionality
        slurp # screenshot functionality
        bemenu # wayland clone of dmenu
      ];
    };

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    # Honestly, nano can just go and die in a fire (lol, totes)
    vim.defaultEditor = true;

    bash = {
      enableCompletion = true;
      interactiveShellInit = builtins.readFile ./files/bash-prompt.sh;
    };

    wireshark = {
      enable = true;
    };
  };
  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    gtkUsePortal = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    challengeResponseAuthentication = false;
    openFirewall = false;
    forwardX11 = true;
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


  systemd.coredump.enable = true;
  systemd.coredump.extraConfig  = ''
    Storage=external
    ProcessSizeMax=20G
    ExternalSizeMax=20G
    '';

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
  # hardware.pulseaudio.enable = true;

  # Disable that annoying-as-fuck 'SURELY YOU MUST WANT TO USE HDMI AUDIO NOW YOUR MONITOR IS TURNED ON' behaviour
  # jfc why is that the default fucking hell no
  hardware.pulseaudio.extraConfig = "unload-module module-switch-on-port-available";

  hardware.pulseaudio.configFile = pkgs.runCommand "default.pa" {} ''
  sed 's/module-udev-detect$/module-udev-detect tsched=0/' \
    ${pkgs.pulseaudio}/etc/pulse/default.pa > $out
'';




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
     "python2.7-PyJWT-1.7.1"
     "python2.7-urllib3-1.26.2"
     "python2.7-certifi-2021.10.8"
     "python2.7-pyjwt-1.7.1"
   ];

  # services.xserver.xkbOptions = "eurosign:e";

  # Enable passwd and co.
  users.mutableUsers = true;


  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
}
