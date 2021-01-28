{ pkgs, lib, ... }:

let
  customPlugins = {};
  customPlugins.vim-coffee-script = pkgs.vimUtils.buildVimPlugin {
    name = "vim-coffee-script";
    src = pkgs.fetchurl {
      url = "https://github.com/kchmck/vim-coffee-script/archive/9e3b4de2a476caeb6ff21b5da20966d7c67a98bb.tar.gz";
      sha256 = "0naprfh3lbfjxg2yii8xjwqvsypvcfna4aagh6dwpac78jldxlz7";
    };
  };
  customPlugins.vim-jade = pkgs.vimUtils.buildVimPlugin {
    name = "vim-jade";
    src = pkgs.fetchurl {
      url = "https://github.com/digitaltoad/vim-jade/archive/ea39cd942cf3194230cf72bfb838901a5344d3b3.tar.gz";
      sha256 = "0rmghq18jbmvzsbbbz447i8l5gaww0js6z031bglf49iarx73bsl";
    };
  };
  customPlugins.vim-stylus = pkgs.vimUtils.buildVimPlugin {
    name = "vim-stylus";
    src = pkgs.fetchurl {
      url = "https://github.com/wavded/vim-stylus/archive/0514757a4795843978517ee73d7fa7d8bf2e5545.tar.gz";
      sha256 = "1aglg9i2hr1pbk1rz9hh8dy94bzsjzpas5rlrvxm5rjl45vfsrg9";
    };
  };
  customPlugins.syntastic = pkgs.vimUtils.buildVimPlugin {
    name = "syntastic";
    src = pkgs.fetchurl {
      url = "https://github.com/scrooloose/syntastic/archive/63741646a9e87bbe105674747555aded6f52c490.tar.gz";
      sha256 = "0gvp4vx19jlbyd8hcfbi6yza8fk4hxf86n3znjf7x48zykv7zqkn";
    };
  };
  customPlugins.vim-sensible = pkgs.vimUtils.buildVimPlugin {
    name = "vim-sensible";
    src = pkgs.fetchurl {
      url = "https://github.com/tpope/vim-sensible/archive/2d9f34c09f548ed4df213389caa2882bfe56db58.tar.gz";
      sha256 = "1p0ffk1vvs22k4jpwn5g28ssqz2ri0ljnksw3xqwbmc2bwyf88hs";
    };
  };
  customPlugins.vim-rails = pkgs.vimUtils.buildVimPlugin {
    name = "vim-rails";
    src = pkgs.fetchurl {
      url = "https://github.com/tpope/vim-rails/archive/2c42236cf38c0842dd490095ffd6b1540cad2e29.tar.gz";
      sha256 = "0hzgi2ga9fz5wcqsnpmaz8yzah2ypphwpi077846qbc2r6pal8jg";
    };
  };
  customPlugins.ack-vim = pkgs.vimUtils.buildVimPlugin {
    name = "ack-vim";
    src = pkgs.fetchurl {
      url = "https://github.com/mileszs/ack.vim/archive/36e40f9ec91bdbf6f1adf408522a73a6925c3042.tar.gz";
      sha256 = "12mjj45wdmv3w3k89xcjz9b49f3y92ynqkh7d519bhzb8ndhvd1n";
    };
  };
  customPlugins.vim-fugitive = pkgs.vimUtils.buildVimPlugin {
    name = "vim-fugitive";
    src = pkgs.fetchurl {
      url = "https://github.com/tpope/vim-fugitive/archive/1a77f1c00e12e8460f39098ec3289c5433d32512.tar.gz";
      sha256 = "1zf1ac0kpffjbfk65kjgly3q47s86limxc33mkc9278ndz8njbq6";
    };
  };
  customPlugins.tslime-vim = pkgs.vimUtils.buildVimPlugin {
    name = "tslime-vim";
    src = pkgs.fetchurl {
      url = "https://github.com/jgdavey/tslime.vim/archive/9b2b99e409336584103b83c597fdb6234875ae25.tar.gz";
      sha256 = "1407brcaim9fwjvvcxqfaad7fmjxxhj0vhbf37az0hr5jwzrmp09";
    };
  };
  customPlugins.vim-dispatch = pkgs.vimUtils.buildVimPlugin {
    name = "vim-dispatch";
    src = pkgs.fetchurl {
      url = "https://github.com/tpope/vim-dispatch/archive/fe6a34322829e466a7e8ce710a6ac5eabddff9fd.tar.gz";
      sha256 = "0l6id8pcy9jrnvf2qzc24yxfd9slglis5j40mlpn59ymad4q8bia";
    };
  };
  customPlugins.vim-nodejs-errorformat = pkgs.vimUtils.buildVimPlugin {
    name = "vim-nodejs-errorformat";
    src = pkgs.fetchurl {
      url = "https://github.com/felixge/vim-nodejs-errorformat/archive/1bacf395ec6aed6340481e7855f2e59f12552fdc.tar.gz";
      sha256 = "0maqyxs9yvv25mk6nwp2jf9jglyhrnx095qxh4q957y6llf1ysf9";
    };
  };
  customPlugins.vim-jst = pkgs.vimUtils.buildVimPlugin {
    name = "vim-jst";
    src = pkgs.fetchurl {
      url = "https://github.com/briancollins/vim-jst/archive/eb25d585c9ff0f5152cea4c64c2db2228c7347bf.tar.gz";
      sha256 = "067q0fdrqzqmg9gx4hfrnn7l6i6ayn4k7ashk6l7qb30w9jxkiyr";
    };
  };
  customPlugins.vim-javascript = pkgs.vimUtils.buildVimPlugin {
    name = "vim-javascript";
    src = pkgs.fetchurl {
      url = "https://github.com/pangloss/vim-javascript/archive/3c90d0cc37bb8b78422f647e62587f498a5dd7bd.tar.gz";
      sha256 = "117qsfnqnfc4n27nrid0bfsv05s275f4hj022dvajdacw6cvfdfw";
    };
  };
  customPlugins.vim-surround = pkgs.vimUtils.buildVimPlugin {
    name = "vim-surround";
    src = pkgs.fetchurl {
      url = "https://github.com/tpope/vim-surround/archive/f51a26d3710629d031806305b6c8727189cd1935.tar.gz";
      sha256 = "1srr8k9gyqkq3sh9bwn5k500w0fcrcvpinvznkbmn8lvgvklqimb";
    };
  };
  customPlugins.vim-clojure-static = pkgs.vimUtils.buildVimPlugin {
    name = "vim-clojure-static";
    src = pkgs.fetchurl {
      url = "https://github.com/guns/vim-clojure-static/archive/fae5710a0b79555fe3296145be4f85148266771a.tar.gz";
      sha256 = "0wirlqiix8szk3a6irwwilvll1x17zp02ff9nb1wzy127nj2id6g";
    };
  };
  customPlugins.vim-fireplace = pkgs.vimUtils.buildVimPlugin {
    name = "vim-fireplace";
    src = pkgs.fetchurl {
      url = "https://github.com/tpope/vim-fireplace/archive/433ff6468d8ee0be5cbcf5bbd940f9ce2acf0f79.tar.gz";
      sha256 = "1pr9p4ly9wdr32ygv9vxkfh4lhizgaaq9hihn1lpjmb0z9jfmlky";
    };
  };
  customPlugins.paredit-vim = pkgs.vimUtils.buildVimPlugin {
    name = "paredit-vim";
    src = pkgs.fetchurl {
      url = "https://github.com/vim-scripts/paredit.vim/archive/791c3a0cc3155f424fba9409a9520eec241c189c.tar.gz";
      sha256 = "0qpyi0k87sv91zil1qx4g9m8rvh4ngvahqxljsw8ab707qm1np4k";
    };
  };
  customPlugins.ctrlp-vim = pkgs.vimUtils.buildVimPlugin {
    name = "ctrlp-vim";
    src = pkgs.fetchurl {
      url = "https://github.com/kien/ctrlp.vim/archive/564176f01d7f3f7f8ab452ff4e1f5314de7b0981.tar.gz";
      sha256 = "13z329b77d62qhccm3cybgqmlga48l60xw57bydhzyr1pp7hqkhf";
    };
  };
  customPlugins.vim-redl = pkgs.vimUtils.buildVimPlugin {
    name = "vim-redl";
    src = pkgs.fetchurl {
      url = "https://github.com/dgrnbrg/vim-redl/archive/98382630e191f22ea8df8b85cf04f48e687d8cfb.tar.gz";
      sha256 = "15jgrkp9zwjd4npgz4c4gkhz642h1c7l9kjy7m4f7fahcnkqss3m";
    };
  };
  customPlugins.nerdtree = pkgs.vimUtils.buildVimPlugin {
    name = "nerdtree";
    src = pkgs.fetchurl {
      url = "https://github.com/scrooloose/nerdtree/archive/14af89743ac1c31ff9bb43682025eda50333a7d5.tar.gz";
      sha256 = "0p9311i0mig76imif7hm3a53mjdblm9xhjwh8jw2yfwlyrlbdbg9";
    };
  };
  customPlugins.vim-solarized = pkgs.vimUtils.buildVimPlugin {
    name = "vim-solarized";
    src = pkgs.fetchurl {
      url = "https://github.com/altercation/vim-colors-solarized/archive/528a59f26d12278698bb946f8fb82a63711eec21.tar.gz";
      sha256 = "1drgf7d8q3llrdn1yr5l8yxjcbn57vadz24jiid0lh794vr15pid";
    };
  };
  customPlugins.vim-airline = pkgs.vimUtils.buildVimPlugin {
    name = "vim-airline";
    src = pkgs.fetchurl {
      url = "https://github.com/bling/vim-airline/archive/91a8ada0f9fc589b57fe8aa459c8961c3a27287e.tar.gz";
      sha256 = "106njksy82gk77x6f6sq585y7a6cj7b1fch9bxvxhh2zccrgn8ic";
    };
  };
  customPlugins.vim-jsx = pkgs.vimUtils.buildVimPlugin {
    name = "vim-jsx";
    src = pkgs.fetchurl {
      url = "https://github.com/mxw/vim-jsx/archive/8879e0d9c5ba0e04ecbede1c89f63b7a0efa24af.tar.gz";
      sha256 = "173n58jg3ppskn4vjr4ddvx13f26789fwa2g02rpngwl6kdq4150";
    };
  };
  customPlugins.erlang-motions-vim = pkgs.vimUtils.buildVimPlugin {
    name = "erlang-motions-vim";
    src = pkgs.fetchurl {
      url = "https://github.com/edkolev/erlang-motions.vim/archive/e2eca9762b2071437ee7cb15aa774b569c9bbf43.tar.gz";
      sha256 = "1av1xfll2gbgpqbhsa54a2kndcm5k7rrbs8g4m521360i3d1cvvr";
    };
  };
  customPlugins.ghcmod-vim = pkgs.vimUtils.buildVimPlugin {
    name = "ghcmod-vim";
    src = pkgs.fetchurl {
      url = "https://github.com/eagletmt/ghcmod-vim/archive/1d192d13d68ab59f9f46497a0909bf24a7b7dfff.tar.gz";
      sha256 = "1lvza0ih03d8zs645xj8cyf2ry89x92z84swcms25wam8k7ks99v";
    };
  };
  customPlugins.neco-ghc = pkgs.vimUtils.buildVimPlugin {
    name = "neco-ghc";
    src = pkgs.fetchurl {
      url = "https://github.com/eagletmt/neco-ghc/archive/b4ea02c537975a5a2bf00cb5f24cd784b2b6f5ad.tar.gz";
      sha256 = "0xfb0lnjmgd69wbnphhwwxcqbdpslgls9jiwr15p70abrw3vrwbf";
    };
  };
  customPlugins.haskell-vim = pkgs.vimUtils.buildVimPlugin {
    name = "haskell-vim";
    src = pkgs.fetchurl {
      url = "https://github.com/neovimhaskell/haskell-vim/archive/b1ac46807835423c4a4dd063df6d5b613d89c731.tar.gz";
      sha256 = "13zn25dvk16cw6a1y5rvc1680ry77w3ifhgami8hhfhh65j3mcwp";
    };
  };
  customPlugins.vimproc-vim = pkgs.vimUtils.buildVimPlugin {
    name = "vimproc-vim";
    src = pkgs.fetchurl {
      url = "https://github.com/Shougo/vimproc.vim/archive/8f40d86ab938d5df8c1c9824320621ae9f0d5609.tar.gz";
      sha256 = "057nraajxpdy72kabcnjxlhxnz8n7r05rrl2nanc5g6yphzwzw84";
    };
  };
  customPlugins.vim-erlang-runtime = pkgs.vimUtils.buildVimPlugin {
    name = "vim-erlang-runtime";
    src = pkgs.fetchurl {
      url = "https://github.com/vim-erlang/vim-erlang-runtime/archive/e14fdf13eee58bb9836a3c3c24abc8ec60746918.tar.gz";
      sha256 = "1fb2a48zpifwb9jfaayswqlxwc73fzgn5hapm8s6vgspdx4vf0nv";
    };
  };
  customPlugins.vim-erlang-tags = pkgs.vimUtils.buildVimPlugin {
    name = "vim-erlang-tags";
    src = pkgs.fetchurl {
      url = "https://github.com/vim-erlang/vim-erlang-tags/archive/a5bc6a90a166073d74e5103f40735740ae40a3cb.tar.gz";
      sha256 = "1kz1fqqigvnd5vngka13p6q6pj4gwsr9r80hyqv98iy8w9fa4960";
    };
  };
  customPlugins.vim-erlang-compiler = pkgs.vimUtils.buildVimPlugin {
    name = "vim-erlang-compiler";
    src = pkgs.fetchurl {
      url = "https://github.com/vim-erlang/vim-erlang-compiler/archive/17e47d28141c961e567b39d8d9956cbdb6e720d0.tar.gz";
      sha256 = "0xv0cl6bklx1aaqjwx2bjz6fg3i8z6lfjvb6l8lfwp966s1fgqby";
    };
  };
  customPlugins.elm-vim = pkgs.vimUtils.buildVimPlugin {
    name = "elm-vim";
    src = pkgs.fetchurl {
      url = "https://github.com/ElmCast/elm-vim/archive/4b71facd77297cb33bbb3b14894676cff0a9bd1d.tar.gz";
      sha256 = "14i877rvdnv9hj7wczgrnhrnkf979c55vvhzfqgbikr7yvvh97rd";
    };
  };
  customPlugins.purescript-vim = pkgs.vimUtils.buildVimPlugin {
    name = "purescript-vim";
    src = pkgs.fetchurl {
      url = "https://github.com/raichoo/purescript-vim/archive/fada016149e37c0d1e0e7c766104867384263b12.tar.gz";
      sha256 = "007zgmnnipwzkkxjn4d9qnrggzxvjb5346ndmvq4nrcgaai3i79y";
    };
  };
  customPlugins.vim-colorschemes = pkgs.vimUtils.buildVimPlugin {
    name = "vim-colorschemes";
    src = pkgs.fetchurl {
      url = "https://github.com/flazz/vim-colorschemes/archive/fd8f122cef604330c96a6a6e434682dbdfb878c9.tar.gz";
      sha256 = "1i6difpzn8vbmn78dkvrv5c2bm3b5lzzjhrjhkynrg2wc45dg82c";
    };
  };
  customPlugins.vim-psc-ide = pkgs.vimUtils.buildVimPlugin {
    name = "vim-psc-ide";
    src = pkgs.fetchurl {
      url = "https://github.com/FrigoEU/psc-ide-vim/archive/5fb4e329e5c0c7d80f0356ab4028eee9c8bd3465.tar.gz";
      sha256 = "147mbrvmqwyf0yabjqs69wy8k8nsc862cp2cavh5nzmw3qa61jwv";
    };
  };
  customPlugins.vim-lsp = pkgs.vimUtils.buildVimPlugin {
    name = "vim-lsp";
    src = pkgs.fetchurl {
      url = "https://github.com/prabirshrestha/vim-lsp/archive/e1adf0f84ec232905d9cd155111fae33607ea2fb.tar.gz";
      sha256 = "08k7zw0p4sb5akb6g5pzq0vv7hx8hb0c3zlwv888h8dqyhps88vw";
    };
  };
  customPlugins.vim-lsp-settings = pkgs.vimUtils.buildVimPlugin {
    name = "vim-lsp-settings";
    configurePhase = ''
      rm -rf Makefile test 
    '';
    src = pkgs.fetchurl {
    url = "https://github.com/robashton/vim-lsp-settings/archive/3217b5c0636153177b0af8d8d655233196bca2ea.tar.gz";
    sha256 = "187r1cz6mvw6wxa89jgrfdk1qfdw7s5wha7vapxqp4wcmhdhiz5p";
    };
  };

  customVim = (pkgs.vim_configurable.customize {
        name = "vim";
        vimrcConfig.vam.knownPlugins = customPlugins // pkgs.vimPlugins;
        vimrcConfig.customRC = (builtins.readFile ./files/vimrc);
        vimrcConfig.vam.pluginDictionaries = [ 
          { names = [
            "vim-coffee-script"
            "vim-stylus"
            "syntastic"
            "vim-sensible"
            "vim-rails"
            "ack-vim"
            "vim-fugitive"
            "tslime-vim"
            "vim-dispatch"
            "vim-nodejs-errorformat"
            "vim-jst"
            "vim-javascript"
            "vim-surround"
            "vim-clojure-static"
            "vim-fireplace"
            "paredit-vim"
            "ctrlp-vim"
            "vim-redl"
            "nerdtree"
            "vim-solarized"
            "vim-airline"
            "vim-jsx"
            "ghcmod-vim"
            "neco-ghc"
            "haskell-vim"
            "vimproc-vim"
            "elm-vim"
            "vim-colorschemes"
            "purescript-vim"
            "vim-lsp"
            ]; }
        ];
      });
in
 {
    programs.vim = {
      enable = false;
      plugins = [];
      settings = { ignorecase = true; };
      extraConfig = (builtins.readFile ./files/vimrc);
    };

    home.packages = (with pkgs; [
      customVim
    ]);
}
