# vim: set sts=2 ts=2 sw=2 expandtab :

{ config, pkgs, lib, ... }:

let
  tmuxPlugins = with pkgs.tmuxPlugins; [
    resurrect
    sessionist
  ];
in
 {

  users.extraGroups.robashton = {
    gid = 1000;
  };

  users.users.robashton = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" "wireshark" "video" ];
    createHome = true;
    home = "/home/robashton";
    uid = 1000;
    group = "robashton";
    shell = "${pkgs.bsh}/bin/bsh";

    openssh.authorizedKeys.keys = [
      (import ./files/pubkey-ashton-xps.nix)
    ];
  };

  home-manager.users.robashton = {
    home.packages = (with pkgs; [
      ktouch
      spotify
      playerctl
      imagemagick
      electrum
      gimp

      khal

      mediainfo
      ffmpeg-full
      vlc
      sox
      audacity
      linphone
      ekiga

      gitAndTools.tig

      powerline-fonts

      # It's useful to be able to control my backlight
      acpilight

      # The best "pure" locker that I've
      # found so far
      i3lock

      # TODO: I don't think I need this explicitly,
      # home-manager's screen-locker uses it
      # internally
      xss-lock

      # xdg-screensaver looks for certain DEs or,
      # falls back to looking for things like
      # xscreensaver (which I don't have), or
      # xautolock, which I do use via
      # home-manager's screen-locker, so make
      # it available to the shell for
      # xdg-screensaver to find
      xautolock

      # So we get access to udiskie-mount
      udiskie
    ]) ++ tmuxPlugins;

    programs.git = {
      enable = true;
      userName  = "robashton";
      userEmail = "robashton@codeofrob.com";
    };

    programs.vim = {
      enable = true;
      plugins = [
        "vim-airline"
        "nerdtree"
        "ctrlp"
        "editorconfig-vim"
        "vim-surround"
        "vim-fugitive"
        "youcompleteme"
        "typescript-vim"
        "ack-vim"
        "ctrlp"
        "elm-vim"
        "haskell-vim"
        "nerdtree"
#        "paredit"
#        "psc-ide-jj"
#        "purescript-vim"
#        "syntastic"
#        "tslime-vim"
#        "vim-airline"
#        "vim-clojure-static"
#        "vim-coffee-script"
#        "vim-dispatch"
#        "vim-easymotion"
#        "vim-erlang-compiler"
#        "vim-erlang-runtime"
#        "vim-erlang-tags"
#        "vim-fireplace"
#        "vim-hdevtools"
#        "vim-javascript"
#        "vim-jst"
#        "vim-jsx"
#        "vim-nodejs-errorformat"
#        "vim-rails"
#        "vim-redl"
#        "vim-sensible"
#        "vim-solarized"
#        "vim-stylus"
#        "vim-surround"
#        "vimproc"
      ];
      settings = { ignorecase = true; };
      extraConfig = (builtins.readFile ./files/vimrc);
    };

    # Need bash enabled so that direnv can add its
    # config
    programs.bash = {
      enable = true;
    };

    programs.direnv = {
      enable = true;
      enableBashIntegration = true;
    };

    programs.home-manager = {
      enable = true;
    };

    # TODO: Does this achieve anything?
    services.screen-locker = {
      enable = true;
      lockCmd = "${pkgs.i3lock}/bin/i3lock -i ~/.config/lockscreen/towelday2013-A.png";
    };

    home.file.".config/wallpapers" = {
      source = ./files/wallpapers;
      recursive = true;
    };

    home.file.".config/lockscreen" = {
      source = ./files/lockscreen;
      recursive = true;
    };

    home.file.".config/alacritty/alacritty.yml".source = ./files/alacritty.yml;

    programs.tmux = {
      enable = true;
      extraConfig = ''
        set -sg escape-time 0
        set -g history-limit 16384

        # Enable true-color for terminal type under which tmux runs
        set -ga terminal-overrides ",xterm-256color:Tc"

        # The terminal type to surface inside of tmux
        set -g default-terminal "xterm-256color"

        ${lib.concatStrings (map (x: "run-shell ${x.rtp}\n") tmuxPlugins)}
      '';
      };

    services.udiskie = {
      enable = true;
    };

    # xsession.initExtra = ''
    #   ${pkgs.feh}/bin/feh --bg-fill ~/.config/wallpapers/towelday2013-A.jpg
    # '';

    # Need this for xsession.initExtra to work, which is used by home-manager's
    # screen-locker to run xss-lock in the background to set X's screen-saver
    xsession.enable = true;

    xsession.windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      config = pkgs.writeText "xmonad.hs" ''
          import XMonad
          import XMonad.Layout.NoBorders

          import XMonad.Hooks.DynamicLog

          import XMonad.Util.EZConfig(additionalKeys)
          import Graphics.X11.ExtraTypes.XF86

          main = do
            updatedConfig <-
              statusBar xmobarPath myPP toggleStrutsKey myConfig

            xmonad updatedConfig

          myPP =
            def
            { ppCurrent = xmobarColor "yellow" "" . wrap "[" "]"
            , ppTitle   = const ""
            , ppLayout  = const ""
            , ppVisible = wrap "(" ")"
            , ppUrgent  = xmobarColor "red" "yellow"
            , ppSep     = " | "
            }

          myConfig =
            let
              originalConfig =
                def
            in
              originalConfig
                { terminal = alacrittyPath
                , layoutHook = noBorders $ layoutHook originalConfig
                }
                `additionalKeys`
                [ ((0                         , xF86XK_AudioRaiseVolume), spawn "amixer -q set Master 5%+")
                , ((0                         , xF86XK_AudioLowerVolume), spawn "amixer -q set Master 5%-")
                , ((0                         , xF86XK_AudioMute),        spawn "amixer -q set Master toggle")
                , ((shiftMask                 , xF86XK_AudioRaiseVolume), spawn "amixer -q set Capture 5%+")
                , ((shiftMask                 , xF86XK_AudioLowerVolume), spawn "amixer -q set Capture 5%-")
                , ((shiftMask                 , xF86XK_AudioMute),        spawn "amixer -q set Capture toggle")
                , ((0                         , xF86XK_AudioNext),        spawn "${pkgs.playerctl}/bin/playerctl next")
                , ((0                         , xF86XK_AudioPrev),        spawn "${pkgs.playerctl}/bin/playerctl previous")
                , ((0                         , xF86XK_AudioPlay),        spawn "${pkgs.playerctl}/bin/playerctl play-pause")
                , ((0                         , xF86XK_AudioStop),        spawn "${pkgs.playerctl}/bin/playerctl stop")

                , (((modMask originalConfig)  , xK_l),                    spawn "xdg-screensaver lock")
                , (((modMask originalConfig)  , xK_o),                    spawn "otp")
                , (((modMask originalConfig)  , xK_s),                    spawn "gnome-screenshot -i")
                , (((modMask originalConfig)  , xK_c),                    spawn "mate-calc")
                , (((modMask originalConfig)  , xK_n),                    spawn "networkmanager_dmenu")

                , (((modMask originalConfig)  , xK_e),                    spawn "st-kb-english")
                , (((modMask originalConfig)  , xK_d),                    spawn "st-kb-german")
                ]

          toggleStrutsKey XConfig {XMonad.modMask = modMask} =
            (modMask, xK_b)

          xmobarPath = "${pkgs.haskellPackages.xmobar}/bin/xmobar"

          alacrittyPath = "${pkgs.alacritty}/bin/alacritty"
      '';
    };
  };

}
