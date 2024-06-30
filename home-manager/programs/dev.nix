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
    nil
    nh

    #python
    python3
    python3.pkgs.pip

    nodejs
    rustup

    #other
    bruno
    insomnia
    postman
    redis

    # unfree
    mongodb-compass
    ngrok
  ];


  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
