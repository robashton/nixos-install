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

  networking.firewall = {
    trustedInterfaces = [];
    allowedTCPPorts = [
      22    # SSH
      8080  # dev
      8443
      6791
      8000
    ];

    allowedUDPPorts = [];

    allowedUDPPortRanges = [];

  };

  # Enable networking
  networking.networkmanager = { 
    enable = true;
    plugins = [
      pkgs.networkmanager-l2tp
      pkgs.networkmanager-strongswan # For IPsec part of L2TP
    ];
  };

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
    tuxedo-keyboard  # provides ite_8291_lb for lightbar control
  ];

  boot.extraModprobeConfig = ''
    options nvidia NVreg_DynamicPowerManagement=0x02
  '';

  boot.kernelModules = [ "nvidia-uvm" "nvidia-drm" "acpi_call" "ite_8291_lb" ];
  boot.kernelParams = [ "acpi_backlight=native" "s2idle=platform" "usbcore.autosuspend=-1" "amdgpu.dcdebugmask=0x10" "amdgpu.gpu_recovery=1" ];

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
    extraGroups = [ "networkmanager" "wheel" "input" ];
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

            # Remove the root check - we have proper udev rules for device access
            substituteInPlace aucc/main.py \
              --replace "from elevate import elevate" "" \
              --replace "if not os.geteuid() == 0:" "if False:" \
              --replace "elevate()" "pass"
          '';
        });
      })
  ];

  services.udev.extraRules = ''
    # Keyboard LED controller - USB device
    SUBSYSTEM=="usb", ATTR{idVendor}=="048d", ATTR{idProduct}=="600b", TAG+="uaccess"
    # Keyboard LED controller - hidraw device (aucc uses hidraw, not USB directly)
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="048d", ATTRS{idProduct}=="600b", TAG+="uaccess"
    # Lightbar LED controller - USB device
    SUBSYSTEM=="usb", ATTR{idVendor}=="048d", ATTR{idProduct}=="7001", TAG+="uaccess"
    # Lightbar LED controller - hidraw device
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="048d", ATTRS{idProduct}=="7001", TAG+="uaccess"
    SUBSYSTEM=="leds", KERNEL=="rgb:lightbar", RUN+="${pkgs.coreutils}/bin/chmod 0666 /sys/class/leds/rgb:lightbar/brightness /sys/class/leds/rgb:lightbar/multi_intensity"
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

    (pkgs.writeShellScriptBin "fn-lightbar-up" ''
      #!/usr/bin/env bash
      BRIGHTNESS_FILE="$XDG_RUNTIME_DIR/lightbar-brightness"

      # Read current or default to 50
      if [ -f "$BRIGHTNESS_FILE" ]; then
        read -r LB < "$BRIGHTNESS_FILE"
      else
        LB=50
      fi
      # Increment (max 100)
      [ "$LB" -lt 100 ] && LB=$((LB + 25))
      [ "$LB" -gt 100 ] && LB=100
      echo "$LB" > "$BRIGHTNESS_FILE"

      # Trigger instant apply
      systemctl --user start aucc-apply-brightness.service

      pony-notify Lightbar "$LB%"
      '')

    (pkgs.writeShellScriptBin "fn-lightbar-down" ''
      #!/usr/bin/env bash
      BRIGHTNESS_FILE="$XDG_RUNTIME_DIR/lightbar-brightness"

      # Read current or default to 50
      if [ -f "$BRIGHTNESS_FILE" ]; then
        read -r LB < "$BRIGHTNESS_FILE"
      else
        LB=50
      fi
      # Decrement (min 0)
      [ "$LB" -gt 0 ] && LB=$((LB - 25))
      [ "$LB" -lt 0 ] && LB=0
      echo "$LB" > "$BRIGHTNESS_FILE"

      # Trigger instant apply
      systemctl --user start aucc-apply-brightness.service

      pony-notify Lightbar "$LB%"
      '')

    (pkgs.writeShellScriptBin "aucc-cpu-monitor" ''
      #!/usr/bin/env bash
      # Get CPU usage from /proc/stat
      read -r cpu user nice system idle iowait irq softirq _rest < /proc/stat
      TOTAL1=$((user + nice + system + idle + iowait + irq + softirq))
      IDLE1=$idle
      sleep 1
      read -r cpu user nice system idle iowait irq softirq _rest < /proc/stat
      TOTAL2=$((user + nice + system + idle + iowait + irq + softirq))
      IDLE2=$idle

      TOTAL_DIFF=$((TOTAL2 - TOTAL1))
      IDLE_DIFF=$((IDLE2 - IDLE1))

      if [ "$TOTAL_DIFF" -gt 0 ]; then
        CPU=$((100 * (TOTAL_DIFF - IDLE_DIFF) / TOTAL_DIFF))
      else
        CPU=0
      fi

      LIGHTBAR="/sys/class/leds/rgb:lightbar"
      BRIGHTNESS_FILE="$XDG_RUNTIME_DIR/lightbar-brightness"
      STATE_FILE="$XDG_RUNTIME_DIR/lighting-state"

      # Read lightbar brightness preference (default: 50)
      if [ -f "$BRIGHTNESS_FILE" ]; then
        read -r LB_BRIGHT < "$BRIGHTNESS_FILE"
      else
        LB_BRIGHT=50
      fi

      # Determine colors based on CPU usage
      # Blue+green at idle, adding red as CPU increases
      if [ "$CPU" -lt 20 ]; then
        COLOR1="blue"; COLOR2="green"
        RGB_R=0; RGB_G=200; RGB_B=255
      elif [ "$CPU" -lt 40 ]; then
        COLOR1="teal"; COLOR2="lightgreen"
        RGB_R=64; RGB_G=180; RGB_B=200
      elif [ "$CPU" -lt 60 ]; then
        COLOR1="purple"; COLOR2="yellow"
        RGB_R=160; RGB_G=140; RGB_B=180
      elif [ "$CPU" -lt 80 ]; then
        COLOR1="purple"; COLOR2="orange"
        RGB_R=200; RGB_G=80; RGB_B=140
      else
        COLOR1="violet"; COLOR2="red"
        RGB_R=255; RGB_G=40; RGB_B=100
      fi

      # Build new state string (colors + lightbar brightness)
      NEW_STATE="$COLOR1 $COLOR2 $RGB_R $RGB_G $RGB_B $LB_BRIGHT"

      # Read previous state
      OLD_STATE=""
      if [ -f "$STATE_FILE" ]; then
        OLD_STATE=$(cat "$STATE_FILE")
      fi

      # Only update hardware if state changed
      if [ "$NEW_STATE" != "$OLD_STATE" ]; then
        aucc -H $COLOR1 $COLOR2
        echo "$RGB_R $RGB_G $RGB_B" > $LIGHTBAR/multi_intensity 2>/dev/null
        echo $LB_BRIGHT > $LIGHTBAR/brightness 2>/dev/null
        echo "$NEW_STATE" > "$STATE_FILE"
      fi
      '')

  ];

  # CPU monitor keyboard + lightbar service
  # Note: Keyboard brightness is hardware-controlled (Fn keys), software only sets colors
  systemd.user.services.aucc-cpu-monitor = {
    description = "AUCC CPU Monitor - keyboard and lightbar show CPU usage";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "aucc-cpu-monitor-exec" ''
        # Get CPU usage from /proc/stat
        read -r cpu user nice system idle iowait irq softirq _rest < /proc/stat
        TOTAL1=$((user + nice + system + idle + iowait + irq + softirq))
        IDLE1=$idle
        sleep 1
        read -r cpu user nice system idle iowait irq softirq _rest < /proc/stat
        TOTAL2=$((user + nice + system + idle + iowait + irq + softirq))
        IDLE2=$idle

        TOTAL_DIFF=$((TOTAL2 - TOTAL1))
        IDLE_DIFF=$((IDLE2 - IDLE1))

        if [ "$TOTAL_DIFF" -gt 0 ]; then
          CPU=$((100 * (TOTAL_DIFF - IDLE_DIFF) / TOTAL_DIFF))
        else
          CPU=0
        fi

        LIGHTBAR="/sys/class/leds/rgb:lightbar"
        BRIGHTNESS_FILE="$XDG_RUNTIME_DIR/lightbar-brightness"
        STATE_FILE="$XDG_RUNTIME_DIR/lighting-state"

        # Read lightbar brightness preference (default: 50)
        if [ -f "$BRIGHTNESS_FILE" ]; then
          read -r LB_BRIGHT < "$BRIGHTNESS_FILE"
        else
          LB_BRIGHT=50
        fi

        # Determine colors based on CPU usage
        # Blue+green at idle, adding red as CPU increases
        if [ "$CPU" -lt 20 ]; then
          COLOR1="blue"; COLOR2="green"
          RGB_R=0; RGB_G=200; RGB_B=255
        elif [ "$CPU" -lt 40 ]; then
          COLOR1="teal"; COLOR2="lightgreen"
          RGB_R=64; RGB_G=180; RGB_B=200
        elif [ "$CPU" -lt 60 ]; then
          COLOR1="purple"; COLOR2="yellow"
          RGB_R=160; RGB_G=140; RGB_B=180
        elif [ "$CPU" -lt 80 ]; then
          COLOR1="purple"; COLOR2="orange"
          RGB_R=200; RGB_G=80; RGB_B=140
        else
          COLOR1="violet"; COLOR2="red"
          RGB_R=255; RGB_G=40; RGB_B=100
        fi

        # Build new state string (colors + lightbar brightness)
        NEW_STATE="$COLOR1 $COLOR2 $RGB_R $RGB_G $RGB_B $LB_BRIGHT"

        # Read previous state
        OLD_STATE=""
        if [ -f "$STATE_FILE" ]; then
          OLD_STATE=$(cat "$STATE_FILE")
        fi

        # Only update hardware if state changed
        if [ "$NEW_STATE" != "$OLD_STATE" ]; then
          ${pkgs.avell-unofficial-control-center}/bin/aucc -H $COLOR1 $COLOR2
          echo "$RGB_R $RGB_G $RGB_B" > $LIGHTBAR/multi_intensity 2>/dev/null
          echo $LB_BRIGHT > $LIGHTBAR/brightness 2>/dev/null
          echo "$NEW_STATE" > "$STATE_FILE"
        fi
      ''}";
    };
  };

  # Instant lightbar brightness apply - no CPU calculation, just apply new brightness
  systemd.user.services.aucc-apply-brightness = {
    description = "Apply lightbar brightness immediately";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "aucc-apply-brightness-exec" ''
        LIGHTBAR="/sys/class/leds/rgb:lightbar"
        BRIGHTNESS_FILE="$XDG_RUNTIME_DIR/lightbar-brightness"
        STATE_FILE="$XDG_RUNTIME_DIR/lighting-state"

        # Read lightbar brightness preference (default: 50)
        if [ -f "$BRIGHTNESS_FILE" ]; then
          read -r LB_BRIGHT < "$BRIGHTNESS_FILE"
        else
          LB_BRIGHT=50
        fi

        # Read colors from state file, or use defaults
        if [ -f "$STATE_FILE" ]; then
          read -r COLOR1 COLOR2 RGB_R RGB_G RGB_B _ < "$STATE_FILE"
        else
          COLOR1="blue"; COLOR2="green"
          RGB_R=0; RGB_G=200; RGB_B=255
        fi

        # Apply lightbar brightness (keyboard brightness is hardware-controlled)
        echo "$RGB_R $RGB_G $RGB_B" > $LIGHTBAR/multi_intensity 2>/dev/null
        echo $LB_BRIGHT > $LIGHTBAR/brightness 2>/dev/null

        # Update state file with new brightness
        echo "$COLOR1 $COLOR2 $RGB_R $RGB_G $RGB_B $LB_BRIGHT" > "$STATE_FILE"
      ''}";
    };
  };

  systemd.user.timers.aucc-cpu-monitor = {
    description = "Run AUCC CPU Monitor every 2 seconds";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "10s";
      OnUnitActiveSec = "2s";
      AccuracySec = "1s";
    };
  };

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
