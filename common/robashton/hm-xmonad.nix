{ pkgs, ... }:
{
  services.dunst = {
    enable = true;

    settings = {
      global = {
        font = "Cantarell 11";
        transparency = 0;

        # Frame + layout
        frame_width = 2;
        frame_color = "#ff9ad5";      # default frame (used if urgency-specific not set)
        separator_color = "frame";
        padding = 10;
        horizontal_padding = 12;
        corner_radius = 10;

        # Icons
        enable_icons = true;
        icon_position = "left";
        # Add your icon dirs if needed:
        # icon_path = "/home/robashton/.icons:/usr/share/icons";
      };

      urgency_low = {
        background = "#fff0fb";  # very light pink
        foreground = "#5a3050";  # soft plum
        frame_color = "#ffb3f1"; # pastel pink border
      };

      urgency_normal = {
        background = "#f0f6ff";  # soft blue
        foreground = "#34495e";  # dark slate text
        frame_color = "#c4b5fd"; # lavender border
      };

      urgency_critical = {
        background = "#ffe4e6";  # soft red/pink
        foreground = "#7f1d1d";  # dark red text
        frame_color = "#fb7185"; # stronger pink border
      };
    };
  };

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
        import XMonad.Config.Gnome
        import XMonad.Hooks.EwmhDesktops

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
            originalConfig = ewmh def
          in
            originalConfig
              { terminal = alacrittyPath
              , layoutHook = noBorders $ layoutHook originalConfig
              }
              `additionalKeys`
              [
                 ((0                         , xF86XK_AudioRaiseVolume), spawn "fn-volume-up")
               , ((0                         , xF86XK_AudioLowerVolume), spawn "fn-volume-down")
               -- Lightbar brightness (Mod+PgUp/PgDown) - keyboard brightness is hardware-controlled
               , (((modMask originalConfig)  , xK_Page_Up),              spawn "fn-lightbar-up")
               , (((modMask originalConfig)  , xK_Page_Down),            spawn "fn-lightbar-down")
               , ((0                         , xF86XK_MonBrightnessDown), spawn "fn-brightness-down")
               , ((0                         , xF86XK_MonBrightnessUp),   spawn "fn-brightness-up")
               , ((0                         , xF86XK_AudioMute),        spawn "fn-volume-mute")
               , ((0                         , xF86XK_AudioNext),        spawn "${pkgs.playerctl}/bin/playerctl next")
               , ((0                         , xF86XK_AudioPrev),        spawn "${pkgs.playerctl}/bin/playerctl previous")
               , ((0                         , xF86XK_AudioPlay),        spawn "${pkgs.playerctl}/bin/playerctl play-pause")
               , ((0                         , xF86XK_AudioStop),        spawn "${pkgs.playerctl}/bin/playerctl stop")

              -- , (((modMask originalConfig)  , xK_l),                    spawn "xdg-screensaver lock")
              -- , (((modMask originalConfig)  , xK_s),                    spawn "gnome-screenshot -i")
              -- , (((modMask originalConfig)  , xK_c),                    spawn "mate-calc")
              ]

        toggleStrutsKey XConfig {XMonad.modMask = modMask} =
          (modMask, xK_b)

        xmobarPath = "${pkgs.haskellPackages.xmobar}/bin/xmobar"

        alacrittyPath = "${pkgs.alacritty}/bin/alacritty"
    '';
  };
}

