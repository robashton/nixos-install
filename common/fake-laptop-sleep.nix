{ config, pkgs, lib, ... }:

{
  #### 1. Tell logind to ignore lid events entirely ####

  services.logind.settings = {
    Login = {
      HandleLidSwitch = "ignore";
      HandleLidSwitchExternalPower = "ignore";
      HandleLidSwitchDocked = "ignore";
      LidSwitchIgnoreInhibited = "no";
    };
  };

  #### 2. Use acpid to implement "fake sleep" on lid close ####

  services.acpid = {
    enable = true;

    # This replaces any previous lid handler we set up earlier.
    handlers.lid-fake-sleep = {
      # ACPI lid events look like "button/lid LID close" / "open"
      event = "button/lid.*";

      action = ''
        #!/bin/sh

        # 1) Lock all active graphical sessions
        ${pkgs.systemd}/bin/loginctl lock-sessions

        # 2) Try to immediately power off displays via DPMS
        #    We iterate sessions, find ones with a DISPLAY, and run xset as that user.
        for sess in $(${pkgs.systemd}/bin/loginctl list-sessions --no-legend | awk '{print $1}'); do
          user=$(${pkgs.systemd}/bin/loginctl show-session "$sess" -p Name --value)
          display=$(${pkgs.systemd}/bin/loginctl show-session "$sess" -p Display --value)

          if [ -n "$display" ] && [ "$display" != "n/a" ]; then
            su - "$user" -c "${pkgs.xorg.xset}/bin/xset -display $display dpms force off" || true
          fi
        done

        # 3) Optional: be a bit more power friendly while the lid is closed
        #    (this is very light-touch and safe; remove if you don't like it)
        for gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
          echo powersave > "$gov" 2>/dev/null || true
        done
      '';
    };
  };
}
