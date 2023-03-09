# vim: set sts=2 ts=2 sw=2 expandtab :

{ config, pkgs, lib, ... }:
 {

  users.extraGroups.steve = {};

  users.users.steve = {
    isNormalUser = true;
    extraGroups = [ "docker" "wireshark" "video" "tmux" ];
    createHome = true;
    home = "/home/steve";
    group = "steve";

    openssh.authorizedKeys.keys = [
      (import ./files/pubkey.nix)
    ];
  };


  home-manager.users.nicholaw = {
    home.packages = (with pkgs; [
    ]);
    home.stateVersion = "22.11";

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
