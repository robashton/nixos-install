{ config, lib, pkgs, ... }:
{

  services.logind.settings = {
    Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "suspend";
      HandleLidSwitchDocked = "suspend";
      LidSwitchIgnoreInhibited = "no";
    };
  };

  # services.acpid = {
  #   enable = true;
  #   handlers.lid-suspend = {
  #     event = "button/lid.*";
  #     action = "${pkgs.systemd}/bin/systemctl suspend";
  #   };
  # };

  # Optional sanity: if you're using GNOME power-profiles, keep them off since we use TLP
  services.power-profiles-daemon.enable = lib.mkDefault false;
}

