{ config, pkgs, lib, private, ... }:
let
  home-manager = builtins.fetchGit {
    url = "https://github.com/nix-community/home-manager.git";
    rev = "20561be440a11ec57a89715480717baf19fe6343";
    ref = "release-25.11";
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
