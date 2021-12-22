{
  outputs = { self, nixpkgs }: {
    nixosConfigurations.ashton-nuc = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./configuration.nix ];
    };
  };
}
