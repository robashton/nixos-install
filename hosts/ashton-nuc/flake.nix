{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
  inputs.private = { url = "git+ssh://git@github.com/robashton/nixos-install-private"; };

  outputs = { self, nixpkgs, private }: {
    nixosConfigurations.ashton-nuc = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ pkgs, ... }: {
          system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
          nix.extraOptions = "experimental-features = nix-command flakes";

          nixpkgs.overlays = [
             (_: _: { ashton-private = private.legacyPackages.x86_64-linux; })
          ];

        })
        ./configuration.nix {}
      ];
    };
  };
}
