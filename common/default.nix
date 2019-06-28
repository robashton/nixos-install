# vim: set sts=2 ts=2 sw=2 expandtab :

{ config, pkgs, lib, ... }:

let
  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    rev = "dd94a849df69fe62fe2cb23a74c2b9330f1189ed";
    ref = "release-18.09";
  };

  private = import ./private { inherit pkgs; };
in
{
  imports =
    [ # home-manager for per-user management
      "${home-manager}/nixos"

      ./stears
    ];

  networking.extraHosts = private.configuration.hosts;

  # Select internationalisation properties.
  i18n = {
    # consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "de";

    # English Language with sensible formatting
    defaultLocale = "en_DK.UTF-8";
  };

  # Set your time zone.
  services.timesyncd.enable = true; # the default, but explicitness is a good thing
  time.timeZone = "Europe/Vienna";

  # Allow non-free things like firefox-bin
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [

    # Admin & Development Tools
    wget
    vim
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
    jq
    awscli
    unzip
    dnsutils # dig
    manpages

    # Docker - until I can obviate it
    docker
    docker-gc
    docker-ls

    # Virtualization
    virtualbox

    # General web things
    firefox-bin
    google-chrome
    skypeforlinux
    slack

    # Security
    gnupg
    srm
    keepassxc

    # Desktop Env
    gnome3.dconf # for the few gnome things I use, such as seahorse
    gnome3.dconf-editor
    gnome3.gnome-screenshot
    mate.mate-calc
    dmenu
    networkmanager_dmenu
    xclip
    alacritty
    feh
    libreoffice-still

    # Desktop Env Support Utilities
    ( writeScriptBin "otp" (builtins.readFile ./files/scripts/otp) )

    ( writeScriptBin "st-audio-get-master-volume" ''
      #!${pkgs.bash}/bin/bash
      amixer sget Master | awk -F '[][]' '/.*Left:/ { print $2 }'
    ''
    )

    ( writeScriptBin "st-audio-get-master-status" ''
      #!${pkgs.bash}/bin/bash
      amixer sget Master | awk -F '[][]' '/.*Left:/ { print $4 }'
    ''
    )

    ( writeScriptBin "st-audio-get-capture-volume" ''
       #!${pkgs.bash}/bin/bash
       amixer sget Capture | awk -F '[][]' '/.*Left:/ { print $2 }'
    ''
    )

    ( writeScriptBin "st-audio-get-capture-status" ''
       #!${pkgs.bash}/bin/bash
       amixer sget Capture | awk -F '[][]' '/.*Left:/ { print $4 }'
    ''
    )

    ( writeScriptBin "st-kb-get-layout" ''
       #!${pkgs.bash}/bin/bash
       setxkbmap -query | awk '/^layout:/ { printf "%s", $2 }'
    ''
    )

    ( writeScriptBin "st-gpg-update-startup-tty" ''
       #!${pkgs.bash}/bin/bash
       echo UPDATESTARTUPTTY | gpg-connect-agent
    ''
    )
  ];

  # So system utility zsh completions are available
  environment.pathsToLink = [ "/share/zsh" ];

  virtualisation = {
    docker.enable = true;
    virtualbox = {
      host = {
        enable = true;
      };
    };
  };

  # Yubikey stuff
  services.pcscd.enable = true;

  programs = {
    ssh.startAgent = false;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    # Honestly, nano can just go and die in a fire
    vim.defaultEditor = true;

    bash = {
      enableCompletion = true;
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions = {
        enable = true;
      };
      ohMyZsh = {
        enable = true;
        theme = "agnoster";
        plugins = [ "git" ];
      };
      syntaxHighlighting = {
        enable = true;
      };
      # zsh-autoenv = {
      #   enable = true;
      # };
    };

    wireshark = {
      enable = true;
    };
  };

  environment.shellInit = ''
    export GPG_TTY="$(tty)"
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
  '';

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    challengeResponseAuthentication = false;
  };

  # Allow docker0 to bypass the firewall
  networking.firewall.extraCommands = ''
    ip46tables -I nixos-fw 1 -i docker0 -j nixos-fw-accept
  '';

  networking.networkmanager.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "us";

    displayManager = {
      lightdm.enable = true;

      # TODO: There has to be a better place for this
      sessionCommands = ''
        ${pkgs.feh}/bin/feh --bg-fill ~/.config/wallpapers/towelday2013-A.jpg
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

  services.gnome3 = {

    # Install the keyring fully (home manager can't do this by itself)
    gnome-keyring.enable = true;

    # So we can inspect the key chain
    seahorse.enable = true;
  };

  # So the key chain is unlocked on login
  security.pam.services.lightdm.enableGnomeKeyring = true;

  security.sudo.extraRules = lib.mkAfter [
    {
      groups = [ "stears" ];
      commands = [
        {
          command = ''${pkgs.systemd}/bin/systemctl restart pcscd'';
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  services.compton = {
    enable          = true;
    # fade            = true;
    # inactiveOpacity = "0.9";
    # shadow          = true;
    # fadeDelta       = 4;
  };

  # services.xserver.xkbOptions = "eurosign:e";

  # Enable passwd and co.
  users.mutableUsers = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?
}