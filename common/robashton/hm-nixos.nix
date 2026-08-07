{ pkgs, lib, desktop ? true, ... }:
{
  programs.home-manager = {
    enable = true;
  };

  home.packages = (with pkgs; [
    mediainfo

    # gitAndTools.tig
    tig
  ]) ++ (lib.optionals desktop (with pkgs; [
    simplescreenrecorder

    # ktouch
    spotify
    playerctl
    imagemagick
    electrum
    gimp

    khal

    ffmpeg-full
    vlc
    sox
    audacity
    #linphone
    #ekiga

    # okular

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

    # For the laptops
    acpi

    # So we get access to udiskie-mount
    udiskie
  ]));

  programs.vim = {
    enable = false;
    plugins = [];
    settings = { ignorecase = true; };
    extraConfig = (builtins.readFile ./files/vimrc);
  };

  programs.bash = {
    enable = true;
  };

  home.file = {
    ".ssh/id_rsa".text = pkgs.ashton-private.id_rsa;
    ".ssh/id_ed25519".text = pkgs.ashton-private.id_ed25519;
    ".ssh/config".source = ../files/sshconfig;
  } // lib.optionalAttrs desktop {
    ".config/wallpapers" = {
      source = ./files/wallpapers;
      recursive = true;
    };

    ".config/lockscreen" = {
      source = ./files/lockscreen;
      recursive = true;
    };

    ".config/alacritty/alacritty.toml".source = ./files/alacritty.toml;
  };

  services.udiskie = {
    enable = desktop;
  };
}

