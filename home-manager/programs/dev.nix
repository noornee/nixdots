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
    rnix-lsp
    nix-init

    #python
    python3
    pipx

    nodejs
    rustup
  ];
}
