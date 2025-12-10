# vim: set sts=2 ts=2 sw=2 expandtab :

{ config, pkgs, lib, ... }:
 {

  users.extraGroups.adrian = {};

  users.users.adrian = {
    isNormalUser = true;
    extraGroups = [ "docker" "wireshark" "video" "tmux" ];
    createHome = true;
    home = "/home/adrian";
    group = "adrian";

    openssh.authorizedKeys.keys = [
      (import ./files/pubkey-adrian.nix)
    ];
  };


  home-manager.users.adrian = {
    home.packages = (with pkgs; [
    ]);
    home.stateVersion = "24.05";

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
