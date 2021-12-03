# vim: set sts=2 ts=2 sw=2 expandtab :

{ config, pkgs, lib, ... }:
 {

  users.extraGroups.nicholaw = {};

  users.users.nicholaw = {
    isNormalUser = true;
    extraGroups = [ "docker" "wireshark" "video" "tmux" ];
    createHome = true;
    home = "/home/nicholaw";
    group = "nicholaw";

    openssh.authorizedKeys.keys = [
      (import ./files/pubkey.nix)
    ];
  };


  home-manager.users.nicholaw = {
    home.packages = (with pkgs; [
    ]);

    programs.vim = {
      enable = false;
      plugins = [];
      settings = { ignorecase = true; };
      extraConfig = (builtins.readFile ./files/vimrc);
    };

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
