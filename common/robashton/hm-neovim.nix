{ pkgs, lib, ... }:

let
  standardPlugins = pkgs.vimPlugins;
  customPlugins = import ./vim-plugins.nix { inherit pkgs; };

#  # Some version of 0.6 cos 0.7 breaks all our plugins for now
#  neovim = import (builtins.fetchTarball {
#      url = https://github.com/nix-community/neovim-nightly-overlay/archive/5ab33071cc20422d0108c7e86d50cd8543e8475d.tar.gz;
#    });
#
#  pinnedNixHash = "7a91fdd124546889cfc08765bb3e0be71f07aa49";
#
#  pinnedNix =
#    builtins.fetchGit {
#      name = "nixpkgs-pinned";
#      url = "https://github.com/NixOS/nixpkgs.git";
#      rev = "${pinnedNixHash}";
#      allRefs = true;
#    };
#
#  nixPackages = import pinnedNix{ overlays = [
#    neovim
#    ];
#  };

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

 home.file.".config/nvim/codelldb".source  = pkgs.vscode-extensions.vadimcn.vscode-lldb;
 home.file.".config/nvim/extra.lua".source = ./files/neovim.lua;

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    package = pkgs.neovim-unwrapped;

    plugins = [

      # Global Plugins
      standardPlugins.ack-vim
      standardPlugins.ctrlp
      standardPlugins.editorconfig-vim
      standardPlugins.nerdtree
      standardPlugins.vim-surround
#      standardPlugins.vim-fugitive
#      (pluginGit "vim-airline/vim-airline" "5891a3f7bedb5d0b23a546189a607836913814bb")
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
      standardPlugins.vim-qml
#      (pluginGit "frazrepo/vim-rainbow" "a6c7fd5a2b0193b5dbd03f62ad820b521dea3290")
#      (plugin "szw/vim-maximizer")

      # Generic LSP help
#      (plugin "neovim/nvim-lspconfig")
#      (plugin "nvim-lua/lsp_extensions.nvim")

      # More LSP overlay shit (and debug support)
      # (pluginGit "64af19183e51911886f3fc82b23cb2430ababcaf" "robashton/rust-tools.nvim")
#      (plugin "simrat39/rust-tools.nvim")

      # Generic debug help tools
#      (plugin "nvim-lua/popup.nvim")
#      (plugin "nvim-lua/plenary.nvim")
#      (plugin "nvim-telescope/telescope.nvim")

      # The actual debugger
#      (plugin "mfussenegger/nvim-dap")

      # Extensions for debugger
#      (plugin "rcarriga/nvim-dap-ui")
#      (plugin "theHamsta/nvim-dap-virtual-text")

      # Rusty stuff
#      (plugin "hrsh7th/nvim-cmp")
#      (plugin "hrsh7th/cmp-nvim-lsp")
#      (plugin "hrsh7th/cmp-vsnip")
#      (plugin "hrsh7th/cmp-path")
#      (plugin "hrsh7th/cmp-buffer")
#      (plugin "hrsh7th/vim-vsnip")

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


