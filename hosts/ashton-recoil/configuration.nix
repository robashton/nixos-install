# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # Common things
      ./../../common

      ./../../common/power.nix
      ./../../common/fake-laptop-sleep.nix
      ./../../common/pony-notify.nix

      # Hardware & user specific things
      ./robashton
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  # Disabled for now as incompatibler with even beta nvidia drivers
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "ashton-recoil"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  services.hardware.openrgb.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;


  services.xserver.xkbOptions = "ctrl:swapcaps";
  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.strongswan = {
    enable = true;
    secrets = [
      "ipsec.d/ipsec.nm-l2tp.secrets"
    ];
  };

  services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];

   boot.extraModulePackages = with config.boot.kernelPackages; [
    acpi_call
  ];

  boot.extraModprobeConfig = ''
    options nvidia NVreg_DynamicPowerManagement=0x02
  '';

  boot.kernelModules = [ "nvidia-uvm" "nvidia-drm" "acpi_call" ];
  boot.kernelParams = [ "acpi_backlight=native" "s2idle=platform" "usbcore.autosuspend=-1"  ];

  environment.etc."X11/xorg.conf.d/20-backlight.conf".text = ''
    Section "Device"
        Identifier "AMD"
        Driver "amdgpu"
        Option "Backlight" "amdgpu_bl2"
    EndSection
  '';

  boot.blacklistedKernelModules = [ "nouveau" ];

  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.prime.offload.enable = true;
  hardware.nvidia.prime.nvidiaBusId = "PCI:1:0:0";
  hardware.nvidia.prime.amdgpuBusId = "PCI:6:0:0";
  hardware.nvidia.nvidiaPersistenced = true;
  hardware.nvidia.open = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "gb";
    variant = "extd";
  };

  # Configure console keymap
  console.keyMap = "uk";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.robashton = {
    isNormalUser = true;
    description = "Rob Ashton";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (final: prev: {
      avell-unofficial-control-center =
        prev.avell-unofficial-control-center.overrideAttrs (old: {
          postPatch = (old.postPatch or "") + ''
            # Use your actual keyboard PID (048d:600b) instead of the old 0xce00
            substituteInPlace aucc/main.py \
              --replace "product_id=0xce00" "product_id=0x600b"
          '';
        });
      })
  ];

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="048d", ATTR{idProduct}=="600b", MODE="0660", GROUP="input"
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{power/control}="auto"
    SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="Lid Switch", \
    ENV{ID_INPUT_SWITCH}="1", ENV{ID_INPUT_SWITCH_TYPE}="lid", TAG+="power-switch"
  '';

  environment.systemPackages = with pkgs; [
    avell-unofficial-control-center
    openrgb
    # nvidia-offload
    # nvidia-env
    xorg.xbacklight
    #bumblebee
    powertop
    pmutils
    linuxPackages.nvidia_x11
    vdpauinfo



    # brightness scripts
    (pkgs.writeShellScriptBin "fn-brightness-up" ''
      #!/usr/bin/env bash
      # Recoil: panel is amdgpu_bl2
      brightnessctl -d amdgpu_bl1 set +5%
      BRIGHT=$(brightnessctl -d amdgpu_bl1 get)
      PERCENT=$(( BRIGHT * 100 / 255 ))
      pony-notify Brightness "$PERCENT%"
    '')

    (pkgs.writeShellScriptBin "fn-brightness-down" ''
      #!/usr/bin/env bash
      brightnessctl -d amdgpu_bl1 set 5%-
      BRIGHT=$(brightnessctl -d amdgpu_bl1 get)
      PERCENT=$(( BRIGHT * 100 / 255 ))
      pony-notify Brightness "$PERCENT%"
    '')

    pkgs.pamixer
    (pkgs.writeShellScriptBin "fn-volume-up" ''
      #!/usr/bin/env bash
      pamixer --increase 5
      VOL=$(pamixer --get-volume)
      pony-notify Volume "$VOL%"
    '')

    (pkgs.writeShellScriptBin "fn-volume-down" ''
      #!/usr/bin/env bash
      pamixer --decrease 5
      VOL=$(pamixer --get-volume)
      pony-notify Volume "$VOL%"
    '')

    (pkgs.writeShellScriptBin "fn-volume-mute" ''
      #!/usr/bin/env bash
      pamixer --toggle-mute
      VOL=$(pamixer --get-mute)
      pony-notify Muted "$VOL"
      '')

    (pkgs.writeShellScriptBin "fn-kb-up" ''
      #!/usr/bin/env bash
      aucc -b 4 
      '')

    (pkgs.writeShellScriptBin "fn-kb-down" ''
      #!/usr/bin/env bash
      aucc -b 1 
      '')
    
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
