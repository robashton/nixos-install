{ pkgs, lib, ... }:

let
  standardPlugins = pkgs.vimPlugins;
  customPlugins = import ./vim-plugins.nix { inherit pkgs; };


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

 home.file.".config/nvim/extra.lua".source = ./files/neovim.lua;

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    package = pkgs.neovim-nightly;

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

#      standardPlugins.coc-nvim
      (plugin "neovim/nvim-lspconfig")


      # Rust Bits
      #standardPlugins.ale
      standardPlugins.deoplete-nvim
      standardPlugins.deoplete-rust
      standardPlugins.vim-toml

      # Colour Schemes
      customPlugins.vim-colorschemes
      customPlugins.vim-solarized
    ];
    extraConfig = (builtins.readFile ./files/vimrc);
  };
}
