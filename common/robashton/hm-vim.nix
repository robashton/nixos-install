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
      url = "https://github.com/scrooloose/syntastic/archive/28bb72adbe5c610bdc07407ddb83898919e4645c.tar.gz"; 
      sha256 = "06f6pih8biazg13hknmfpp9w0x7jhyv7qsg20p6kvabxnzwigagi"; 
    }; 
  }; 
  customPlugins.vim-sensible = pkgs.vimUtils.buildVimPlugin { 
    name = "vim-sensible";
    src = pkgs.fetchurl { 
      url = "https://github.com/tpope/vim-sensible/archive/4a7159a30061b26aec9ac367823094e7fd0f6a5b.tar.gz"; 
      sha256 = "0aq2m50w5skldgm2kfdz07l4syggqjjl3r3wg6l8k9ngxmm5q9gs"; 
    }; 
  }; 
  customPlugins.vim-rails = pkgs.vimUtils.buildVimPlugin { 
    name = "vim-rails";
    src = pkgs.fetchurl { 
      url = "https://github.com/tpope/vim-rails/archive/0c7f985d2d6e62fcd5603dd4028850858fea204d.tar.gz"; 
      sha256 = "1y05n5bhnvlp1mc6nzx6c83kcpwypy555m1vm4qywbmfpllhikwv"; 
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
      url = "https://github.com/tpope/vim-fugitive/archive/f6acae50ea4d8ec1bb1497cb886d80298b54831b.tar.gz"; 
      sha256 = "0ipzjq7yvc8mywnkzhhkb0gigzw1yjig3wcjdz98mfkwazs3gxf0"; 
    }; 
  }; 
  customPlugins.tslime-vim = pkgs.vimUtils.buildVimPlugin { 
    name = "tslime-vim";
    src = pkgs.fetchurl { 
      url = "https://github.com/jgdavey/tslime.vim/archive/28e9eba642a791c6a6b044433dce8e5451b26fb0.tar.gz"; 
      sha256 = "0b9xl5rzaq5d5380qsy4ms5iza537vjw7gwqb8bgcy0nww29bqa3"; 
    }; 
  }; 
  customPlugins.vim-dispatch = pkgs.vimUtils.buildVimPlugin { 
    name = "vim-dispatch";
    src = pkgs.fetchurl { 
      url = "https://github.com/tpope/vim-dispatch/archive/4bd1ecd7f38206ef26c37d7d142df58c4237d9dc.tar.gz"; 
      sha256 = "19k19icwrllcrj9kg7llx7n44nmsqi7qf7b4mhz9fizc67n78n73"; 
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
      url = "https://github.com/pangloss/vim-javascript/archive/b6c8c8419240bdd29b5eb51a47d488fd390deed5.tar.gz"; 
      sha256 = "09r4agb6nvngzq76lyjah4phfrfqzk7ysq0za0ndcy4miz4kqrvs"; 
    }; 
  }; 
  customPlugins.vim-surround = pkgs.vimUtils.buildVimPlugin { 
    name = "vim-surround";
    src = pkgs.fetchurl { 
      url = "https://github.com/tpope/vim-surround/archive/fab8621670f71637e9960003af28365129b1dfd0.tar.gz"; 
      sha256 = "1x1s9mz7xgxvvnf6fa4gv2g3ink520s1nnsdxx5hnqwxlcpw52ra"; 
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
      url = "https://github.com/tpope/vim-fireplace/archive/ea9fa306a731a105511cc5faecbaf7d58c94dfcf.tar.gz"; 
      sha256 = "0r25a4vdb3sqvx7jk44fsgq4x1zc87r773ckl0bjy1qv47466119"; 
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
      url = "https://github.com/scrooloose/nerdtree/archive/fec3e57ad23e4c268d07181d6afb858925b647a1.tar.gz"; 
      sha256 = "0z3h7w74hdjl723gnlssz3wx8g7rdfr38k6nv5413g3ch4602qn6"; 
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
      url = "https://github.com/bling/vim-airline/archive/e4e4ba3c7b6f510ae10be2dfcac83e12afbd26e9.tar.gz"; 
      sha256 = "1pi0zg8rxkqpm54svpyqrapq712i866lmh9gccajbnhx17i9qppl"; 
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
      url = "https://github.com/eagletmt/neco-ghc/archive/682869aca5dd0bde71a09ba952acb59c543adf7d.tar.gz"; 
      sha256 = "0bzlhydx7sjv6lfw417wj1dbc41kpdgnrv8s74gx629acpzi3c4r"; 
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
      url = "https://github.com/Shougo/vimproc.vim/archive/47b54dd23eeb0a7fa81529d3768b27b979821b30.tar.gz"; 
      sha256 = "10gmz5qxsapvpvydybsx52x0lskc5bl5yil0cf36hb3kbfc2ryrj"; 
    }; 
  }; 
  customPlugins.vim-erlang-runtime = pkgs.vimUtils.buildVimPlugin { 
    name = "vim-erlang-runtime";
    src = pkgs.fetchurl { 
      url = "https://github.com/vim-erlang/vim-erlang-runtime/archive/bba638c6ff658201fd6cd3cacc96cd4c7f63258c.tar.gz"; 
      sha256 = "0cdbm3g5yjm0r8fwkqczdk653d7byd7x7zhrajn6z05bs4h76ifb"; 
    }; 
  }; 
  customPlugins.vim-erlang-tags = pkgs.vimUtils.buildVimPlugin { 
    name = "vim-erlang-tags";
    src = pkgs.fetchurl { 
      url = "https://github.com/vim-erlang/vim-erlang-tags/archive/4b332f438776058894b065121d0c0e9f2c8b2130.tar.gz"; 
      sha256 = "0z0ymwwr37fdx0cxsamv68076f0a5842xfgj5z44mriisyiirw5p"; 
    }; 
  }; 
  customPlugins.vim-erlang-compiler = pkgs.vimUtils.buildVimPlugin { 
    name = "vim-erlang-compiler";
    src = pkgs.fetchurl { 
      url = "https://github.com/vim-erlang/vim-erlang-compiler/archive/7ca6f2a9ed97a41891bc48cfb798efc51d240cc0.tar.gz"; 
      sha256 = "0vn860nx1j7hdpqn3csdwz7lfqjplkih96ym9rvh7ipzy4g5m63d"; 
    }; 
  }; 
  customPlugins.elm-vim = pkgs.vimUtils.buildVimPlugin { 
    name = "elm-vim";
    src = pkgs.fetchurl { 
      url = "https://github.com/ElmCast/elm-vim/archive/165107a9fd2b20c8f050fc4f977b4e41c790b1e7.tar.gz"; 
      sha256 = "0wck28h39lxl2gm60px4v1sfif779kbgpwfydlfr98k6crchb5sf"; 
    }; 
  }; 
  customPlugins.purescript-vim = pkgs.vimUtils.buildVimPlugin { 
    name = "purescript-vim";
    src = pkgs.fetchurl { 
      url = "https://github.com/raichoo/purescript-vim/archive/67ca4dc4a0291e5d8c8da48bffc0f3d2c9739e7f.tar.gz"; 
      sha256 = "0428afn4l5m11p8barscs1xa52gippyyl50kz9dr2j57kgy43ya2"; 
    }; 
  }; 

  customPlugins.vim-colorschemes = pkgs.vimUtils.buildVimPlugin {
    name = "vim-colorschemes";
    src = pkgs.fetchurl {
      url = "https://github.com/flazz/vim-colorschemes/archive/9e7ab1cfec5d3db85aa1c4e87329fd869ecf94e9.tar.gz";
      sha256 = "1dgg18nx32hs68az76pj0k7d2ijhms5hpicn985wlmsmmlhmkdar";
    };
  };

  customPlugins.vim-psc-ide = pkgs.vimUtils.buildVimPlugin {
    name = "vim-psc-ide"; src = pkgs.fetchurl {
      url = "https://github.com/FrigoEU/psc-ide-vim/archive/5fb4e329e5c0c7d80f0356ab4028eee9c8bd3465.tar.gz";
      sha256 = "147mbrvmqwyf0yabjqs69wy8k8nsc862cp2cavh5nzmw3qa61jwv";
    };
  };

  customPlugins.vim-lsp = pkgs.vimUtils.buildVimPlugin {
    name = "vim-lsp";
    src = pkgs.fetchurl {
      url = "https://github.com/prabirshrestha/vim-lsp/archive/bb765bb7aff26ef4d71cc28de2b57b730c3d4482.tar.gz";
      sha256 = "1cb6s6pc5krlvvj8mkp54wz3i3hqra22bjdcvn1nk9fhf5hn65jd";
    };
  };

  customVim = (pkgs.vim_configurable.customize {
        name = "vim";
        vimrcConfig.vam.knownPlugins = customPlugins // pkgs.vimPlugins;
        vimrcConfig.customRC = (builtins.readFile ./files/vimrc);
        vimrcConfig.vam.pluginDictionaries = [ 
          { names = [
            "vim-coffee-script"
            "vim-jade"
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
            "erlang-motions-vim"
            "ghcmod-vim"
            "neco-ghc"
            "haskell-vim"
            "vimproc-vim"
            "vim-erlang-runtime"
            "vim-erlang-tags"
            "vim-erlang-compiler"
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
