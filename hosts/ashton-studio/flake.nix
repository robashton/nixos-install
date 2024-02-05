{
  description = "Simple Setup for Rob's Mac Studio";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-23.05;
    nixpkgs-unstable.url = github:nixos/nixpkgs/nixpkgs-unstable;
    darwin.url = github:lnl7/nix-darwin;
    home-manager.url = github:nix-community/home-manager;


    private = { url = "git+ssh://git@github.com/robashton/nixos-install-private"; };
    neovim = { url = "git+ssh://git@github.com/robashton/flake-neovim"; };
    hx = { url = "git+ssh://git@github.com/robashton/flake-helix"; };

    private.inputs.nixpkgs.follows = "nixpkgs-unstable";
    neovim.inputs.nixpkgs.follows = "nixpkgs-unstable";
    darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, darwin, home-manager, ... }@inputs: {
    darwinConfigurations.ashton-studio = darwin.lib.darwinSystem {
      specialArgs = {
        nix-env-config.os = "darwin";
        hostname = "ashton-studio";
      };
      system = "aarch64-darwin";
      modules = [
        home-manager.darwinModules.home-manager
        ({ pkgs, ... }: {
          system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
          nix.extraOptions = "experimental-features = nix-command flakes";
          nixpkgs.overlays = [
             (_: _: { ashton-private = inputs.private.legacyPackages.aarch64-darwin; })
             (_: _: { ashton-neovim = inputs.neovim.packages.aarch64-darwin.default; })
             (_: _: { ashton-hx = inputs.hx.packages.aarch64-darwin.default; })
          ];
        })
        ./macos.nix
      ];
    };
  };
}
