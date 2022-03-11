{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";

  outputs = { self, nixpkgs }: {
    nixosConfigurations.ashton-nuc = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ pkgs, ... }: {
          system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
          nix.extraOptions = "experimental-features = nix-command flakes";
        })
        ./configuration.nix
      ];
    };
  };
}
