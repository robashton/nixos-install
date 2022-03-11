{ pkgs, lib, ... }:

let
  private = import ../private { inherit pkgs; };
in
{
  programs.home-manager = {
    enable = true;
  };

  home.packages = (with pkgs; [
    simplescreenrecorder

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
    #linphone
    #ekiga

    okular

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

    # For the laptops
    acpi

    # So we get access to udiskie-mount
    udiskie
  ]);

  programs.vim = {
    enable = false;
    plugins = [];
    settings = { ignorecase = true; };
    extraConfig = (builtins.readFile ./files/vimrc);
  };

  programs.bash = {
    enable = true;
  };

  home.file.".config/wallpapers" = {
    source = ./files/wallpapers;
    recursive = true;
  };

  home.file.".config/lockscreen" = {
    source = ./files/lockscreen;
    recursive = true;
  };

  home.file.".ssh/id_rsa".source = ../private/sources/nixos-install-priv/id_rsa;
  home.file.".ssh/id_ed25519".source = ../private/sources/nixos-install-priv/id_ed25519;
  home.file.".config/alacritty/alacritty.yml".source = ./files/alacritty.yml;

  services.udiskie = {
    enable = true;
  };
}

