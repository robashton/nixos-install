{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  inputs.private = { url = "git+ssh://git@github.com/robashton/nixos-install-private"; };

  inputs.neovim = { url = "/home/robashton/src/flake-neovim"; };

  outputs = { self, nixpkgs, private, neovim }: {
    nixosConfigurations.ashton-nuc = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ pkgs, ... }: {
          system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
          nix.extraOptions = "experimental-features = nix-command flakes";

          nixpkgs.overlays = [
             (_: _: { ashton-private = private.legacyPackages.x86_64-linux; })
             (_: _: { ashton-neovim = neovim.packages.x86_64-linux.default; })
          ];

        })
        ./configuration.nix {}
      ];
    };
  };
}
