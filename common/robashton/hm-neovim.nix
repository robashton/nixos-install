{ pkgs, lib, ... }:

let
  standardPlugins = pkgs.vimPlugins;
  customPlugins = import ./vim-plugins.nix { inherit pkgs; };

  pinnedNixHash = "43152ffb579992dc6e0e55781436711f7bdfab1e";

  pinnedNix =
    builtins.fetchGit {
      name = "nixpkgs-pinned";
      url = "https://github.com/NixOS/nixpkgs.git";
      rev = "${pinnedNixHash}";
    };

  nixPackages = import pinnedNix{};

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

    ( writeScriptBin "codelldb" ''
      #!${pkgs.bash}/bin/bash
      ${nixPackages.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/.codelldb-wrapped_ \
      --liblldb ${nixPackages.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/lldb/lib/liblldb.so $@
    ''
    )
  ];


 home.file.".config/nvim/extra.lua".source = ./files/neovim.lua;

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

      # Generic LSP help
      (plugin "neovim/nvim-lspconfig")
      (plugin "nvim-lua/lsp_extensions.nvim")

      # More LSP overlay shit (and debug support)
      (pluginGit "64af19183e51911886f3fc82b23cb2430ababcaf" "robashton/rust-tools.nvim")

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


