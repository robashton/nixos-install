{ config, pkgs, lib, ... }:
let
  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    rev = "fc87ac92afe8df28850196d7ab5a1242cbef5dba";
    ref = "master";
  };
in
 {
  imports = [
    "${home-manager}/nixos"
  ];

  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
    }))
  ];

  nix.trustedUsers = [
    "robashton"
  ];

  users.extraGroups.robashton = {
    gid = 1000;
  };

  users.users.robashton = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" "wireshark" "video" "tmux"];
    createHome = true;
    home = "/home/robashton";
    group = "robashton";

    openssh.authorizedKeys.keys = [
      (import ./files/pubkey-ashton-xps.nix)
    ];
  };

  home-manager.users.robashton = import ./hm.nix { inherit pkgs lib; };
}
