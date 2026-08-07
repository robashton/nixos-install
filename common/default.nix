{ config, pkgs, lib, ... }:

let

# Find an extant release here https://repo.skype.com/deb/pool/main/s/skypeforlinux/
#  skypeforlinux_latest_version = "8.96.76.407";
#  skypeforlinux_latest = pkgs.skypeforlinux.overrideAttrs (oldAttrs: {
#    version = skypeforlinux_latest_version;
#    src = pkgs.fetchurl {
#      url = "https://repo.skype.com/deb/pool/main/s/skypeforlinux/skypeforlinux_${skypeforlinux_latest_version}_amd64.deb";
#      sha256 = "00wa8c1ndwrwn28zp01lg6z8yzj6vxrpy3rva4c9n7ra3gpn2wrk";
#    };
#  });

  pls = pkgs.nodePackages.purescript-language-server.override {
    version = "0.15.0";
    src = builtins.fetchurl {
      url = "https://registry.npmjs.org/purescript-language-server/-/purescript-language-server-0.15.0.tgz";
    };
  };
in
{
  imports =
    [
      ./desktop.nix
      ./robashton
      ./stears
      ./nicholaw
      ./steve
      ./adrian
      ./alex
    ];


  security.sudo.extraConfig = ''
    %wheel	ALL=(ALL)	NOPASSWD: ALL
  '';

  console.keyMap = "uk";
  # Select internationalisation properties.
  # i18n = {xx    # English Language with sensible formatting
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Set your time zone.
  services.timesyncd.enable = true; # the default, but explicitness is a good thing

  # popups
  time.timeZone = "Europe/London";

  nix.settings.auto-optimise-store = true;

  # Nothing was ever collectable here: generations going back years pinned
  # essentially the whole store, so plain nix-collect-garbage freed nothing.
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };

  environment.interactiveShellInit = ''
    alias vi='nvim'
    alias vim='nvim'
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
    silver-searcher

    networkmanager-l2tp
    strongswan

    openssh
    git git-lfs
    tmux
    ripgrep
    htop iotop iftop
    lftp
    tree
    bash-completion
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
    nixops_unstable_minimal
    gccStdenv

    # Docker - until I can obviate it
    docker
    docker-gc
    docker-ls

    # Security
    gnupg
    srm
    #keepassxc

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

      # Volumes are deliberately left alone here; only images/containers
      # /networks/build cache are pruned.
      autoPrune = {
        enable = true;
        dates = "daily";
        flags = [ "--all" "--filter" "until=24h" ];
      };
    };
  };

  # It's useful to be able to manage firmware
  services.fwupd.enable = true;
  services.journald.extraConfig = "SystemMaxUse=100M";

  # And thunderbolt things
  services.hardware.bolt.enable = true;
  hardware.nvidia-container-toolkit.enable = true;

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

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    # Honestly, nano can just go and die in a fire (lol, totes)
    # vim.defaultEditor = true;

    bash = {
      enableCompletion = true;
      interactiveShellInit = builtins.readFile ./files/bash-prompt.sh;
    };

    wireshark = {
      enable = true;
    };
  };
  services.dbus.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
    openFirewall = false;
    forwardX11 = true;
  };

  networking.extraHosts = pkgs.ashton-private.hosts;


  # Dropbox
  networking.firewall = {
    allowedTCPPorts = [ 17500 ];
    allowedUDPPorts = [ 17500 ];
  };

  # Speaking of..
#  systemd.user.services.dropbox = {
#    description = "Dropbox";
#    after = [ "xembedsniproxy.service" ];
#    wants = [ "xembedsniproxy.service" ];
#    wantedBy = [ "graphical-session.target" ];
#    environment = {
#      QT_PLUGIN_PATH = "/run/current-system/sw/" + pkgs.qt5.qtbase.qtPluginPrefix;
#      QML2_IMPORT_PATH = "/run/current-system/sw/" + pkgs.qt5.qtbase.qtQmlPrefix;
#    };
#    serviceConfig = {
#      ExecStart = "${pkgs.dropbox.out}/bin/dropbox";
#      ExecReload = "${pkgs.coreutils.out}/bin/kill -HUP $MAINPID";
#      KillMode = "control-group"; # upstream recommends process
#      Restart = "on-failure";
#      PrivateTmp = true;
#      ProtectSystem = "full";
#      Nice = 10;
#    };
#  };

#  systemd.services.nix-daemon.environment.TMPDIR = "/home/tmp"; # do builds on the rather more spacious home partition


  systemd.coredump.enable = true;
  systemd.coredump.extraConfig  = ''
    Storage=external
    ProcessSizeMax=20G
    ExternalSizeMax=20G
    '';

  # Allow docker0 to bypass the firewall
  # These must be idempotent: on a reload the chain still exists from the
  # previous run, and a bare `-N LOGDROP` aborts the whole script, which
  # leaves nixos-fw unreferenced and the box wide open.
  networking.firewall.extraCommands = ''
    ip46tables -I nixos-fw 1 -i docker0 -j nixos-fw-accept
    ip46tables -N LOGDROP 2>/dev/null || true
    ip46tables -F LOGDROP
    ip46tables -A LOGDROP -j LOG
    ip46tables -A LOGDROP -j DROP
    ip46tables -I INPUT -p tcp --dport 22 -m state --state NEW -m recent --set
    ip46tables -I INPUT -p tcp --dport 22 -m state --state NEW -m recent  --update --seconds 60 --hitcount 4 -j LOGDROP
  '';

  # Without these the INPUT rules above accumulate a duplicate pair on every
  # reload, and LOGDROP survives to break the next start.
  # Loop rather than a single -D: duplicates double-count the `recent` hits,
  # so --hitcount 4 would start locking SSH out after ~2 connections.
  networking.firewall.extraStopCommands = ''
    for ipt in iptables ip6tables; do
      while $ipt -D INPUT -p tcp --dport 22 -m state --state NEW -m recent  --update --seconds 60 --hitcount 4 -j LOGDROP 2>/dev/null; do :; done
      while $ipt -D INPUT -p tcp --dport 22 -m state --state NEW -m recent --set 2>/dev/null; do :; done
      $ipt -F LOGDROP 2>/dev/null || true
      $ipt -X LOGDROP 2>/dev/null || true
    done
  '';

  networking.dhcpcd.extraConfig = ''
        noipv4ll
      '';

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
  # system.stateVersion = "20.03"; # Did you read the comment?
}
