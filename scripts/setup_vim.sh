#!/usr/bin/env bash

set -e

NAMES=()

function install_plugin {
  git clone $1 $2 > /dev/null 2>/dev/null
  pushd $2 > /dev/null
  local hash=$(git log -n 1 | head -n 1 | grep commit | awk '{print $2}')
  local url=$(echo $1 | sed s/\\.git$//)/archive/$hash.tar.gz
  local sha256=$(nix-prefetch-url $url 2> /dev/null) 
  echo "customPlugins.$2 = pkgs.vimUtils.buildVimPlugin { "
  echo "  name = \"$2\";"
  echo "  src = pkgs.fetchurl { "
  echo "    url = \"$url\"; "
  echo "    sha256 = \"$sha256\"; "
  echo "  }; "
  echo "}; "
  popd > /dev/null
  rm -rf $2 > /dev/null 2>/dev/null
}


echo "{ pkgs }:"
echo ""
echo $NAMES

#install_plugin "https://github.com/kchmck/vim-coffee-script.git" "vim-coffee-script"
#install_plugin "https://github.com/digitaltoad/vim-jade.git" "vim-jade"
#install_plugin "https://github.com/wavded/vim-stylus.git" "vim-stylus"
#install_plugin "https://github.com/scrooloose/syntastic.git" "syntastic"
#install_plugin "https://github.com/tpope/vim-sensible.git" "vim-sensible"
#install_plugin "https://github.com/tpope/vim-rails.git"	"vim-rails"
#install_plugin "https://github.com/mileszs/ack.vim.git"	"ack-vim"
#install_plugin "https://github.com/tpope/vim-fugitive.git" "vim-fugitive"
#install_plugin "https://github.com/jgdavey/tslime.vim.git" "tslime-vim"
#install_plugin "https://github.com/tpope/vim-dispatch.git" "vim-dispatch"
#install_plugin "https://github.com/felixge/vim-nodejs-errorformat.git" "vim-nodejs-errorformat"
#install_plugin "https://github.com/briancollins/vim-jst.git" "vim-jst"
#install_plugin "https://github.com/pangloss/vim-javascript.git" "vim-javascript"
#install_plugin "https://github.com/tpope/vim-surround.git" "vim-surround"
#install_plugin "https://github.com/guns/vim-clojure-static.git" "vim-clojure-static"
#install_plugin "https://github.com/tpope/vim-fireplace.git" "vim-fireplace"
#install_plugin "https://github.com/vim-scripts/paredit.vim.git" "paredit-vim"
#install_plugin "https://github.com/kien/ctrlp.vim.git" "ctrlp-vim"
#install_plugin "https://github.com/dgrnbrg/vim-redl.git" "vim-redl"
#install_plugin "https://github.com/scrooloose/nerdtree.git" "nerdtree"
#install_plugin "https://github.com/altercation/vim-colors-solarized.git" "vim-solarized"
#install_plugin "https://github.com/bling/vim-airline.git" "vim-airline"
#install_plugin "https://github.com/mxw/vim-jsx.git" "vim-jsx"
#install_plugin "https://github.com/edkolev/erlang-motions.vim.git" "erlang-motions-vim"
#install_plugin "https://github.com/eagletmt/ghcmod-vim.git" "ghcmod-vim"
#install_plugin "https://github.com/eagletmt/neco-ghc.git" "neco-ghc"
#install_plugin "https://github.com/neovimhaskell/haskell-vim.git" "haskell-vim"
#install_plugin "https://github.com/Shougo/vimproc.vim.git" "vimproc-vim"
#install_plugin "https://github.com/vim-erlang/vim-erlang-runtime" "vim-erlang-runtime"
#install_plugin "https://github.com/vim-erlang/vim-erlang-tags" "vim-erlang-tags"
#install_plugin "https://github.com/vim-erlang/vim-erlang-compiler" "vim-erlang-compiler"
#install_plugin "https://github.com/ElmCast/elm-vim.git" "elm-vim"
#install_plugin "https://github.com/raichoo/purescript-vim.git" "purescript-vim"
#install_plugin "https://github.com/flazz/vim-colorschemes.git" "vim-colorschemes" 
#install_plugin "https://github.com/FrigoEU/psc-ide-vim.git" "vim-psc-ide" 
#install_plugin "https://github.com/prabirshrestha/vim-lsp.git" "vim-lsp" 
install_plugin "https://github.com/robashton/vim-lsp-settings.git" "vim-lsp-settings" 
