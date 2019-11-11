{ pkgs, ... }:

{
  configuration = {
    hosts = import ./sources/nixos-install-priv/hosts.nix;
  };
}
