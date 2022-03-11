{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    lfs = {
      enable = true;
    };
    userName  = "robashton";
    userEmail = "robashton@codeofrob.com";
  };
}

