{ config, lib, pkgs, ... }:
{
  #### Basic power management scaffolding ####

  # Turn on generic power management hooks
  powerManagement.enable = true;

  # Let the kernel use a sane default governor; TLP will override on AC/BAT.
  powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";

  # Don't fight with power-profiles-daemon; TLP will be in charge instead.
  services.power-profiles-daemon.enable = lib.mkForce false;


  #### TLP: laptop power tuning (AC vs battery profiles) ####

  services.tlp = {
    enable = true;

    settings = {
      # Start in battery profile unless overridden
      TLP_DEFAULT_MODE = "BAT";
      TLP_PERSISTENT_DEFAULT = 1;

      # CPU governors
      CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      # CPU energy/performance preference (if supported)
      CPU_ENERGY_PERF_POLICY_ON_AC  = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      # Platform profiles (if supported by firmware)
      PLATFORM_PROFILE_ON_AC  = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      # PCIe ASPM (aggressive power saving on battery)
      PCIE_ASPM_ON_AC  = "default";
      PCIE_ASPM_ON_BAT = "powersupersave";

      # Runtime power management for PCI devices
      RUNTIME_PM_ON_AC  = "auto";
      RUNTIME_PM_ON_BAT = "auto";

      # USB autosuspend (good for power; set to 0 if any USB device misbehaves)
      USB_AUTOSUSPEND = 1;

      # SATA link power management
      SATA_LINKPWR_ON_AC  = "med_power_with_dipm";
      SATA_LINKPWR_ON_BAT = "min_power";

      # Audio power saving (seconds of idle before powering codec down)
      SOUND_POWER_SAVE_ON_AC  = 1;
      SOUND_POWER_SAVE_ON_BAT = 1;

      # WiFi power saving
      WIFI_PWR_ON_AC  = "off";
      WIFI_PWR_ON_BAT = "on";

      # Optional: battery charge thresholds (if supported)
      # START_CHARGE_THRESH_BAT0 = 40;
      # STOP_CHARGE_THRESH_BAT0  = 80;
    };
  };


  #### ASUS platform control (asusctl / asusd) ####
  # This laptop's firmware does NOT expose the generic
  # /sys/firmware/acpi/platform_profile interface, so TLP's
  # PLATFORM_PROFILE_ON_BAT setting above is a no-op here. ASUS ROG hardware
  # gates CPU/GPU power limits through asus-nb-wmi's throttle_thermal_policy
  # instead, which asusd drives. This gives us the `asusctl` CLI + daemon.
  #
  # Set a low-power profile on battery by hand with:
  #   asusctl profile -P Quiet        (also: Balanced, Performance)
  # asusd does not auto-switch on AC/BAT on its own; wire a udev/systemd hook
  # if we want that automatic.
  services.asusd = {
    enable = true;
    enableUserService = true;
  };


  #### Powertop: auto-tune kernel power knobs ####

  powerManagement.powertop.enable = true;
  # Optional: keep powertop installed for interactive tuning
  environment.systemPackages = [
    pkgs.powertop
  ];


  #### Terminal transparency toggle based on power state ####
  # On AC: transparent (0.8), On battery: opaque (1.0) to save GPU power
  # Devices without batteries always report AC, so stay transparent

  environment.etc."power-opacity-update.sh" = {
    mode = "0755";
    text = ''
      #!/bin/sh
      # Determine if on AC power (any AC adapter online = on AC)
      ON_AC=0
      FOUND_AC=0

      for ac in /sys/class/power_supply/*; do
        if [ -f "$ac/type" ] && [ "$(cat "$ac/type")" = "Mains" ]; then
          FOUND_AC=1
          if [ -f "$ac/online" ] && [ "$(cat "$ac/online")" = "1" ]; then
            ON_AC=1
            break
          fi
        fi
      done

      # No AC adapters found = desktop = always "on AC"
      if [ "$FOUND_AC" = "0" ]; then
        ON_AC=1
      fi

      if [ "$ON_AC" = "1" ]; then
        OPACITY="0.8"
      else
        OPACITY="1.0"
      fi

      # Update power.toml for each user with an alacritty config dir
      for home in /home/*; do
        user=$(basename "$home")
        config_dir="$home/.config/alacritty"
        power_file="$config_dir/power.toml"

        if [ -d "$config_dir" ]; then
          echo "[window]" > "$power_file"
          echo "opacity = $OPACITY" >> "$power_file"
          chown "$user:users" "$power_file" 2>/dev/null || true
        fi
      done
    '';
  };

  # Trigger on AC adapter plug/unplug: opacity update + ASUS profile switch.
  # The profile switch talks to asusd over dbus, which is unreliable from
  # udev's short-lived sandbox, so we kick a systemd oneshot instead of
  # running asusctl inline here.
  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", ATTR{type}=="Mains", RUN+="${pkgs.bash}/bin/bash /etc/power-opacity-update.sh"
    SUBSYSTEM=="power_supply", ATTR{type}=="Mains", RUN+="${pkgs.systemd}/bin/systemctl --no-block start asus-profile.service"
  '';

  # Set the ASUS platform profile from the current power state.
  # Quiet on battery (caps CPU/GPU power limits — the real battery lever),
  # Balanced on AC. Change "Balanced" to "Performance" here if you'd rather
  # trade fan noise for headroom while plugged in. Runs on boot and on every
  # AC plug/unplug (via the udev rule above).
  systemd.services.asus-profile = {
    description = "Set ASUS platform profile based on power state";
    wantedBy = [ "multi-user.target" ];
    after = [ "asusd.service" ];
    wants = [ "asusd.service" ];
    path = [ pkgs.asusctl ];
    serviceConfig.Type = "oneshot";
    script = ''
      ON_AC=0
      FOUND_AC=0
      for ac in /sys/class/power_supply/*; do
        if [ -f "$ac/type" ] && [ "$(cat "$ac/type")" = "Mains" ]; then
          FOUND_AC=1
          if [ -f "$ac/online" ] && [ "$(cat "$ac/online")" = "1" ]; then
            ON_AC=1
            break
          fi
        fi
      done
      # No AC adapter present at all = treat as plugged in (desktop-ish).
      if [ "$FOUND_AC" = "0" ]; then ON_AC=1; fi

      if [ "$ON_AC" = "1" ]; then
        asusctl profile -P Balanced
      else
        asusctl profile -P Quiet
      fi
    '';
  };

  # Run once at boot to set initial state
  systemd.services.power-opacity-init = {
    description = "Set terminal opacity based on power state";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-udev-settle.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash /etc/power-opacity-update.sh";
    };
  };

}


