{ config, pkgs, lib, private, ... }:
let
  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    rev = "2f23fa308a7c067e52dfcc30a0758f47043ec176";
    ref = "release-24.05";
  };
in
 {
  imports = [
    "${home-manager}/nixos"
  ];

  nix.settings.trusted-users = [
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

  home-manager.users.robashton = import ./hm.nix { inherit pkgs lib private; };
}
