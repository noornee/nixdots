{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # lua
    lua
    lua-language-server
    stylua

    #go
    go
    gopls
    gofumpt

    #nix
    nixpkgs-fmt
    nix-init
    nixd

    #python
    python3
    python3.pkgs.pip

    nodejs
    rustup
  ];


  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
