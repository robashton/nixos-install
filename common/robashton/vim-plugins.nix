{ pkgs }:

let
  inherit (pkgs) fetchurl;
  inherit (pkgs.vimUtils) buildVimPlugin;

  result = {};

  result.vim-coffee-script = buildVimPlugin {
    name = "vim-coffee-script";
    src = pkgs.fetchurl {
      url = "https://github.com/kchmck/vim-coffee-script/archive/28421258a8dde5a50deafbfc19cd9873cacfaa79.tar.gz";
      sha256 = "0vlbkdl3hfi7yamy19l8h0811z73nmm06zc93qbdpivszrn50lrp";
    };
  };
  result.vim-jade = buildVimPlugin {
    name = "vim-jade";
    src = pkgs.fetchurl {
      url = "https://github.com/digitaltoad/vim-jade/archive/ea39cd942cf3194230cf72bfb838901a5344d3b3.tar.gz";
      sha256 = "0rmghq18jbmvzsbbbz447i8l5gaww0js6z031bglf49iarx73bsl";
    };
  };
  result.vim-stylus = buildVimPlugin {
    name = "vim-stylus";
    src = pkgs.fetchurl {
      url = "https://github.com/wavded/vim-stylus/archive/0514757a4795843978517ee73d7fa7d8bf2e5545.tar.gz";
      sha256 = "1aglg9i2hr1pbk1rz9hh8dy94bzsjzpas5rlrvxm5rjl45vfsrg9";
    };
  };
  result.syntastic = buildVimPlugin {
    name = "syntastic";
    src = pkgs.fetchurl {
      url = "https://github.com/scrooloose/syntastic/archive/97bf9ec720662af51ae403b6dfe720d4a24bfcbc.tar.gz";
      sha256 = "0xrhn9klg6rsl9c5094c348pb4igsvmrg0hf0aiwimdfwbwchz5c";
    };
  };
  result.vim-sensible = buildVimPlugin {
    name = "vim-sensible";
    src = pkgs.fetchurl {
      url = "https://github.com/tpope/vim-sensible/archive/2d9f34c09f548ed4df213389caa2882bfe56db58.tar.gz";
      sha256 = "1p0ffk1vvs22k4jpwn5g28ssqz2ri0ljnksw3xqwbmc2bwyf88hs";
    };
  };
  result.vim-rails = buildVimPlugin {
    name = "vim-rails";
    src = pkgs.fetchurl {
      url = "https://github.com/tpope/vim-rails/archive/03a5c3e85411db1488cdfd1029d2a91f9327c8a2.tar.gz";
      sha256 = "14r385dzxfgknhxv6l6f24gx98jqpbp2a062468d02k2hrh38sir";
    };
  };
  result.ack-vim = buildVimPlugin {
    name = "ack-vim";
    src = pkgs.fetchurl {
      url = "https://github.com/mileszs/ack.vim/archive/36e40f9ec91bdbf6f1adf408522a73a6925c3042.tar.gz";
      sha256 = "12mjj45wdmv3w3k89xcjz9b49f3y92ynqkh7d519bhzb8ndhvd1n";
    };
  };
  result.vim-fugitive = buildVimPlugin {
    name = "vim-fugitive";
    src = pkgs.fetchurl {
      url = "https://github.com/tpope/vim-fugitive/archive/a67e1f8189938c44f295fc97e6c9dd13b727b1e3.tar.gz";
      sha256 = "0m28y00182md58hqpz9jpm0yjbfl59bpan7m9y9c8lf3aa99zpz5";
    };
  };
  result.tslime-vim = buildVimPlugin {
    name = "tslime-vim";
    src = pkgs.fetchurl {
      url = "https://github.com/jgdavey/tslime.vim/archive/9b2b99e409336584103b83c597fdb6234875ae25.tar.gz";
      sha256 = "1407brcaim9fwjvvcxqfaad7fmjxxhj0vhbf37az0hr5jwzrmp09";
    };
  };
  result.vim-dispatch = buildVimPlugin {
    name = "vim-dispatch";
    src = pkgs.fetchurl {
      url = "https://github.com/tpope/vim-dispatch/archive/c88f1b1e4fd428d826fa38c272ed80b6518d37eb.tar.gz";
      sha256 = "01l3il06gw256i7pixfnpxxmzya9k27flxsfw2dwr9icv4c0zqkn";
    };
  };
  result.vim-nodejs-errorformat = buildVimPlugin {
    name = "vim-nodejs-errorformat";
    src = pkgs.fetchurl {
      url = "https://github.com/felixge/vim-nodejs-errorformat/archive/1bacf395ec6aed6340481e7855f2e59f12552fdc.tar.gz";
      sha256 = "0maqyxs9yvv25mk6nwp2jf9jglyhrnx095qxh4q957y6llf1ysf9";
    };
  };
  result.vim-jst = buildVimPlugin {
    name = "vim-jst";
    src = pkgs.fetchurl {
      url = "https://github.com/briancollins/vim-jst/archive/eb25d585c9ff0f5152cea4c64c2db2228c7347bf.tar.gz";
      sha256 = "067q0fdrqzqmg9gx4hfrnn7l6i6ayn4k7ashk6l7qb30w9jxkiyr";
    };
  };
  result.vim-javascript = buildVimPlugin {
    name = "vim-javascript";
    src = pkgs.fetchurl {
      url = "https://github.com/pangloss/vim-javascript/archive/f8345cdb6734aefa5c0f9cb128c9efd005410a43.tar.gz";
      sha256 = "1aa5k7y6yyavz3i480kdlmvp4hl28vcgf2pdd1gdb7xb8jfkidsi";
    };
  };
  result.vim-surround = buildVimPlugin {
    name = "vim-surround";
    src = pkgs.fetchurl {
      url = "https://github.com/tpope/vim-surround/archive/f51a26d3710629d031806305b6c8727189cd1935.tar.gz";
      sha256 = "1srr8k9gyqkq3sh9bwn5k500w0fcrcvpinvznkbmn8lvgvklqimb";
    };
  };
  result.vim-clojure-static = buildVimPlugin {
    name = "vim-clojure-static";
    src = pkgs.fetchurl {
      url = "https://github.com/guns/vim-clojure-static/archive/fae5710a0b79555fe3296145be4f85148266771a.tar.gz";
      sha256 = "0wirlqiix8szk3a6irwwilvll1x17zp02ff9nb1wzy127nj2id6g";
    };
  };
  result.vim-fireplace = buildVimPlugin {
    name = "vim-fireplace";
    src = pkgs.fetchurl {
      url = "https://github.com/tpope/vim-fireplace/archive/c9a155b88d629221628937eadb64a3e87f8d82d9.tar.gz";
      sha256 = "1kv9v0siydff1yj8nivp2g5jvqg0j328mcdk0v9qinl784rpf3gj";
    };
  };
  result.paredit-vim = buildVimPlugin {
    name = "paredit-vim";
    src = pkgs.fetchurl {
      url = "https://github.com/vim-scripts/paredit.vim/archive/791c3a0cc3155f424fba9409a9520eec241c189c.tar.gz";
      sha256 = "0qpyi0k87sv91zil1qx4g9m8rvh4ngvahqxljsw8ab707qm1np4k";
    };
  };
  result.ctrlp-vim = buildVimPlugin {
    name = "ctrlp-vim";
    src = pkgs.fetchurl {
      url = "https://github.com/kien/ctrlp.vim/archive/564176f01d7f3f7f8ab452ff4e1f5314de7b0981.tar.gz";
      sha256 = "13z329b77d62qhccm3cybgqmlga48l60xw57bydhzyr1pp7hqkhf";
    };
  };
  result.vim-redl = buildVimPlugin {
    name = "vim-redl";
    src = pkgs.fetchurl {
      url = "https://github.com/dgrnbrg/vim-redl/archive/98382630e191f22ea8df8b85cf04f48e687d8cfb.tar.gz";
      sha256 = "15jgrkp9zwjd4npgz4c4gkhz642h1c7l9kjy7m4f7fahcnkqss3m";
    };
  };
  result.nerdtree = buildVimPlugin {
    name = "nerdtree";
    src = pkgs.fetchurl {
      url = "https://github.com/scrooloose/nerdtree/archive/7eee457efae1bf9b96d7a266ac097639720a68fe.tar.gz";
      sha256 = "1v7ag227y28z2nq1p0fmj4bfjgwkdpskxldkz70mn1rn9sg76a8p";
    };
  };
  result.vim-solarized = buildVimPlugin {
    name = "vim-solarized";
    src = pkgs.fetchurl {
      url = "https://github.com/altercation/vim-colors-solarized/archive/528a59f26d12278698bb946f8fb82a63711eec21.tar.gz";
      sha256 = "1drgf7d8q3llrdn1yr5l8yxjcbn57vadz24jiid0lh794vr15pid";
    };
  };
  result.vim-airline = buildVimPlugin {
    name = "vim-airline";
    src = pkgs.fetchurl {
      url = "https://github.com/bling/vim-airline/archive/2e29ab965625d1315f0ad070c928794baea3d66f.tar.gz";
      sha256 = "1r10dml3plq6mdak9fnqf8lra965q4xini2wlp98r301jl4imqkx";
    };
  };
  result.vim-jsx = buildVimPlugin {
    name = "vim-jsx";
    src = pkgs.fetchurl {
      url = "https://github.com/mxw/vim-jsx/archive/8879e0d9c5ba0e04ecbede1c89f63b7a0efa24af.tar.gz";
      sha256 = "173n58jg3ppskn4vjr4ddvx13f26789fwa2g02rpngwl6kdq4150";
    };
  };
  result.erlang-motions-vim = buildVimPlugin {
    name = "erlang-motions-vim";
    src = pkgs.fetchurl {
      url = "https://github.com/edkolev/erlang-motions.vim/archive/e2eca9762b2071437ee7cb15aa774b569c9bbf43.tar.gz";
      sha256 = "1av1xfll2gbgpqbhsa54a2kndcm5k7rrbs8g4m521360i3d1cvvr";
    };
  };
  result.ghcmod-vim = buildVimPlugin {
    name = "ghcmod-vim";
    src = pkgs.fetchurl {
      url = "https://github.com/eagletmt/ghcmod-vim/archive/1d192d13d68ab59f9f46497a0909bf24a7b7dfff.tar.gz";
      sha256 = "1lvza0ih03d8zs645xj8cyf2ry89x92z84swcms25wam8k7ks99v";
    };
  };
  result.neco-ghc = buildVimPlugin {
    name = "neco-ghc";
    src = pkgs.fetchurl {
      url = "https://github.com/eagletmt/neco-ghc/archive/699897c2f4ba82c4fd2be6b93c9a2e8e548efe4e.tar.gz";
      sha256 = "0vznbbs1ggh3ac8d2hxs105jc7nmx6j189mmpv8b1fcn7lf7907m";
    };
  };
  result.haskell-vim = buildVimPlugin {
    name = "haskell-vim";
    src = pkgs.fetchurl {
      url = "https://github.com/neovimhaskell/haskell-vim/archive/f35d02204b4813d1dbe8b0e98cc39701a4b8e15e.tar.gz";
      sha256 = "1hlnz8dm6p70f7g770mp18jnjk9qim2lbpwz62334g8vf7dlin5g";
    };
  };
  result.vimproc-vim = buildVimPlugin {
    name = "vimproc-vim";
    src = pkgs.fetchurl {
      url = "https://github.com/Shougo/vimproc.vim/archive/8f40d86ab938d5df8c1c9824320621ae9f0d5609.tar.gz";
      sha256 = "057nraajxpdy72kabcnjxlhxnz8n7r05rrl2nanc5g6yphzwzw84";
    };
  };
  result.vim-erlang-runtime = buildVimPlugin {
    name = "vim-erlang-runtime";
    src = pkgs.fetchurl {
      url = "https://github.com/vim-erlang/vim-erlang-runtime/archive/461717a931a7d985ac0ac8f4d856a7564b4d3f18.tar.gz";
      sha256 = "0bfa4jvbagfmd50sw0505iqym3r0h4yxllvw0724gjfpls945y3k";
    };
  };
  result.vim-erlang-tags = buildVimPlugin {
    name = "vim-erlang-tags";
    src = pkgs.fetchurl {
      url = "https://github.com/vim-erlang/vim-erlang-tags/archive/d7eaa8f6986de0f266dac48b7dcfbf41d67ce611.tar.gz";
      sha256 = "165yykk1m6zqhnjkybiks3cvnlz1qpzk723ynxm4n7xvwaggqcgy";
    };
  };
  result.vim-erlang-compiler = buildVimPlugin {
    name = "vim-erlang-compiler";
    src = pkgs.fetchurl {
      url = "https://github.com/vim-erlang/vim-erlang-compiler/archive/b334e956026f61c0bf289ffdf37ce9b2aefe01e1.tar.gz";
      sha256 = "1zqnnk7ry8bd5gz1z36yw87xx67dzd3mzdv3x5jqfcbgpz7xxcd1";
    };
  };
  result.elm-vim = buildVimPlugin {
    name = "elm-vim";
    src = pkgs.fetchurl {
      url = "https://github.com/ElmCast/elm-vim/archive/4b71facd77297cb33bbb3b14894676cff0a9bd1d.tar.gz";
      sha256 = "14i877rvdnv9hj7wczgrnhrnkf979c55vvhzfqgbikr7yvvh97rd";
    };
  };
  result.purescript-vim = buildVimPlugin {
    name = "purescript-vim";
    src = pkgs.fetchurl {
      url = "https://github.com/raichoo/purescript-vim/archive/d493b57406d2742f6f6c6545de5a3492f2e5b888.tar.gz";
      sha256 = "1ajshrgp04msgyc9g1q21ki86afs28mbwy75pi8jc82rqa3yvwdn";
    };
  };
  result.vim-colorschemes = buildVimPlugin {
    name = "vim-colorschemes";
    src = pkgs.fetchurl {
      url = "https://github.com/flazz/vim-colorschemes/archive/fd8f122cef604330c96a6a6e434682dbdfb878c9.tar.gz";
      sha256 = "1i6difpzn8vbmn78dkvrv5c2bm3b5lzzjhrjhkynrg2wc45dg82c";
    };
  };
  result.nvim-lspconfig = buildVimPlugin {
    name = "nvim-lspconfig";
    src = pkgs.fetchurl {
      url = "https://github.com/neovim/nvim-lspconfig/archive/aa0b9fd746d73a5ebbc72c732c645e96423d4504.tar.gz";
      sha256 = "130qcpmz5k5mfsz2cfz12dxcfkg7rfn56nmnrqadza1ibqb7x895";
    };
  };

in
  result
