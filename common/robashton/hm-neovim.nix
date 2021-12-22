{ pkgs, lib, ... }:

let
  standardPlugins = pkgs.vimPlugins;
  customPlugins = import ./vim-plugins.nix { inherit pkgs; };

  neovim = import (builtins.fetchTarball {
      url = https://github.com/nix-community/neovim-nightly-overlay/archive/116189ff27ac056faa8ec3f7ecc6dc3f6f565b67.tar.gz;
    });

  pinnedNixHash = "6c0804f1b0fce6831773f042afcab68df793ecb0";

  pinnedNix =
    builtins.fetchGit {
      name = "nixpkgs-pinned";
      url = "https://github.com/NixOS/nixpkgs.git";
      rev = "${pinnedNixHash}";
    };

  nixPackages = import pinnedNix{ overlays = [
    neovim
    ];
  };

  neovim-nightly = import (builtins.fetchTarball "https://github.com/nix-community/neovim-nightly-overlay/archive/116189ff27ac056faa8ec3f7ecc6dc3f6f565b67.tar.gz") {};

  pluginGit = ref: repo: pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "${lib.strings.sanitizeDerivationName repo}";
    version = ref;
    src = builtins.fetchGit {
      url = "https://github.com/${repo}.git";
      ref = ref;
    };
  };

  # always installs latest version
  plugin = pluginGit "HEAD";

in
{
  home.packages = with pkgs; [
    universal-ctags
  ];

 home.file.".config/nvim/codelldb".source  = nixPackages.vscode-extensions.vadimcn.vscode-lldb;

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    package = nixPackages.neovim-unwrapped;

    plugins = [

      # Global Plugins
      standardPlugins.ack-vim
      standardPlugins.ctrlp
      standardPlugins.editorconfig-vim
      standardPlugins.nerdtree
      standardPlugins.vim-surround
#      standardPlugins.vim-fugitive
      standardPlugins.vim-airline
      standardPlugins.tagbar
#      standardPlugins.vim-gutentags
      standardPlugins.indentLine

      # Specific Languages
      customPlugins.elm-vim
      customPlugins.purescript-vim
      customPlugins.vim-jsx
      standardPlugins.typescript-vim
      standardPlugins.vim-markdown
      standardPlugins.vim-nix
      (plugin "frazrepo/vim-rainbow")

      # Generic LSP help
      (plugin "neovim/nvim-lspconfig")
      (plugin "nvim-lua/lsp_extensions.nvim")

      # More LSP overlay shit (and debug support)
      # (pluginGit "64af19183e51911886f3fc82b23cb2430ababcaf" "robashton/rust-tools.nvim")
      (plugin "simrat39/rust-tools.nvim")

      # Generic debug help tools
      (plugin "nvim-lua/popup.nvim")
      (plugin "nvim-lua/plenary.nvim")
      (plugin "nvim-telescope/telescope.nvim")

      # The actual debugger
      (plugin "mfussenegger/nvim-dap")

      # Extensions for debugger
      (plugin "rcarriga/nvim-dap-ui")
      (plugin "theHamsta/nvim-dap-virtual-text")

      # Rusty stuff
      (plugin "hrsh7th/nvim-cmp")
      (plugin "hrsh7th/cmp-nvim-lsp")
      (plugin "hrsh7th/cmp-vsnip")
      (plugin "hrsh7th/cmp-path")
      (plugin "hrsh7th/cmp-buffer")
      (plugin "hrsh7th/vim-vsnip")

      # Rust Bits
      #standardPlugins.ale
      #standardPlugins.deoplete-nvim
      #standardPlugins.deoplete-rust
      standardPlugins.vim-toml

      # Colour Schemes
      customPlugins.vim-colorschemes
      customPlugins.vim-solarized
    ];
    extraConfig = (builtins.readFile ./files/vimrc);
  };
}


