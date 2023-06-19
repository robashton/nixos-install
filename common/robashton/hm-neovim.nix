{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    universal-ctags
    ashton-neovim
  ];

 home.file.".config/nvim/codelldb".source  = pkgs.vscode-extensions.vadimcn.vscode-lldb;

}


