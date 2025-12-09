{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  inputs.private = { url = "git+ssh://git@github.com/robashton/nixos-install-private"; };

  inputs.neovim = { url = "git+ssh://git@github.com/robashton/flake-neovim"; };
  inputs.hx = { url = "git+ssh://git@github.com/robashton/flake-helix"; };

  outputs = { self, nixpkgs, private, neovim, hx }: {
    nixosConfigurations.ashton-xps = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ pkgs, ... }: {
          system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
          nix.extraOptions = "experimental-features = nix-command flakes";

          nixpkgs.overlays = [
             (_: _: { ashton-private = private.legacyPackages.x86_64-linux; })
             (_: _: { ashton-neovim = neovim.packages.x86_64-linux.default; })
             (_: _: { ashton-hx = hx.packages.x86_64-linux.default; })
          ];

        })
        ./configuration.nix {}
      ];
    };
  };
}
