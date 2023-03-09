# vim: set sts=2 ts=2 sw=2 expandtab :

{ config, pkgs, lib, ... }:
 {

  users.extraGroups.stears = {};

  users.users.stears = {
    isNormalUser = true;
    extraGroups = [ "docker" "wireshark" "video" "tmux" ];
    createHome = true;
    home = "/home/stears";
    group = "stears";

    openssh.authorizedKeys.keys = [
      (import ./files/pubkey-philip-yk.nix)
    ];
  };


  home-manager.users.stears = {
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
