# vim: set sts=2 ts=2 sw=2 expandtab :

{ config, pkgs, ... }:

{
  home-manager.users.robashton = {
    home.file.".xmobarrc".source = ./files/xmobarrc;
  };
}

