{ pkgs, lib, ... }:

let
  modules = [
    ./hm-nixos.nix
    ./hm-tmux.nix
    ./hm-neovim.nix
    ./hm-git.nix
    ./hm-xmonad.nix
    ./hm-direnv.nix
    ./hm-emacs.nix
    ./hm-wayland.nix
  ];


  moduleResults = builtins.map runModule modules;

  runModule = module: import module { inherit pkgs lib; };

  combined = builtins.foldl' mergeResult emptyAcc moduleResults;

  emptyAcc = { home = {
    stateVersion = "23.11";
    packages = []; }; };

  # This is a deep set merge, right-hand-side wins,
  # it's not perfect but it should do
  mergeResult =
    acc: moduleResult:
      let

        # Need to manually merge packages because recursiveUpdate doesn't know how to merge lists
        modulePackages = lib.attrsets.attrByPath [ "home" "packages" ] [] moduleResult;
        currentPackages = acc.home.packages;
        allPackages = modulePackages ++ currentPackages;

        # The inject them into the module result, because its version would win over the version in the accumulator
        moduleResultPatched = lib.recursiveUpdate moduleResult { home = { packages = allPackages; }; };

      in
        lib.recursiveUpdate acc moduleResultPatched;

in
  combined

