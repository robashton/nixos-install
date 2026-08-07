{ config, pkgs, lib, ... }:

# Everything in here is only useful on a machine somebody sits in front of.
#
# It is split out because ashton-nuc is headless (SSH jump host + CI runner) and
# the desktop closure was 24GiB of it -- LibreOffice, Zoom, Chrome, Steam, GNOME,
# two GHCs via xmonad and a 2GiB cef-binary via obs-studio -- none of which can
# ever be garbage collected, because it is all in the live system generation.
#
# Defaults to on, so ashton-recoil keeps exactly what it had.

let
  discord_latest = pkgs.discord.overrideAttrs (oldArtrs: {
    src = builtins.fetchTarball {
      url ="https://stable.dl2.discordapp.net/apps/linux/0.0.76/discord-0.0.76.tar.gz";
      sha256 = "1xgkbz4llj6sd9p0zzdxm2w4niv03nnd7kjbbbl004xndlf2adcw";
    };
  });

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
  options.id3as.desktop.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Whether this machine is a workstation: X11/GNOME/xmonad, sway, audio,
      printing and the GUI applications. Turn it off for headless hosts.
    '';
  };

  config = lib.mkIf config.id3as.desktop.enable {

    location.latitude = 55.8;
    location.longitude = 4.2;
    services.redshift = {
      enable = true;
    };

    programs.steam.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    environment.systemPackages = with pkgs; [
      gnome-settings-daemon

      wine

      sonic-pi
      appimage-run

      pavucontrol
      wireshark

      motion

      obs-studio

      # General web things
      firefox-bin
      google-chrome
      slack
      discord_latest
      zoom-us

      # Desktop Env
      gnome-screenshot
      mate.mate-calc
      dmenu
      xclip
      termite
      feh
      libreoffice-still

      brightnessctl

      # Wayland stuff
      wl-clipboard

      # Hardware Acceleration Utilities
      libva-utils
      mesa-demos

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

    programs.sway = {
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
        # gnome3.adwaita-icon-theme  # default gnome cursors
        swaylock
        swayidle
        grim # screenshot functionality
        slurp # screenshot functionality
        bemenu # wayland clone of dmenu
      ];
    };

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      # gtk portal needed to make gtk apps happy
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      # gtkUsePortal = true;
    };

    # Enable CUPS to print documents.
    services.printing.enable = true;

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
        gdm.enable = true;
        defaultSession = "none+xmonad";
        sessionCommands = ''
          ${pkgs.feh}/bin/feh --bg-fill ~/.config/wallpapers/rainbow-dash.jpg
        '';
      };

      windowManager = {
        xmonad = {
          enable = true;
          enableContribAndExtras = true;
          extraPackages = haskellPackages: with haskellPackages; [
            xmobar
          ];
        };
      };

      desktopManager = {
        gnome.enable = true;
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
  };
}
