# vim: set sts=2 ts=2 sw=2 expandtab :

{ config, pkgs, lib, ... }:
 {

  users.extraGroups.alex = {};

  users.users.alex = {
    isNormalUser = true;
    extraGroups = [ "docker" "wireshark" "video" "tmux" ];
    createHome = true;
    home = "/home/alex";
    group = "alex";
  };


  home-manager.users.alex = {
    home.packages = (with pkgs; [
    ]);
    home.stateVersion = "22.11";

    # Need bash enabled so that direnv can add its
    # config
    programs.bash = {
      enable = true;
    };

    programs.direnv = {
      enable = true;
      enableBashIntegration = true;
    };

    programs.home-manager = {
      enable = true;
    };
  };
}
