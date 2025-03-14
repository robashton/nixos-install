{ pkgs, ... }:
{
  xsession.enable = true;
  xsession.windowManager.xmonad = {
    enable = true;
    enableContribAndExtras = true;
    config = pkgs.writeText "xmonad.hs" ''
        import XMonad
        import XMonad.Layout.NoBorders

        import XMonad.Hooks.DynamicLog
        import XMonad.Layout.Fullscreen

        import XMonad.Util.EZConfig(additionalKeys)
        import Graphics.X11.ExtraTypes.XF86

        main = do
          updatedConfig <-
            statusBar xmobarPath myPP toggleStrutsKey $ fullscreenSupport myConfig

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
              , (((modMask originalConfig)  , xK_s),                    spawn "gnome-screenshot -i")
              , (((modMask originalConfig)  , xK_c),                    spawn "mate-calc")
              ]

        toggleStrutsKey XConfig {XMonad.modMask = modMask} =
          (modMask, xK_b)

        xmobarPath = "${pkgs.haskellPackages.xmobar}/bin/xmobar"

        alacrittyPath = "${pkgs.alacritty}/bin/alacritty"
    '';
  };
}

