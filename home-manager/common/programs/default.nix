{ pkgs, ... }:
{
  imports = [
    ./lf
    ./zellij
    ./font.nix
    ./git.nix
    ./fastfetch.nix
    ./tmux.nix
  ];

  home.packages = with pkgs; [
    neovim

    #utils
    zoxide
    inetutils
    jq
    eza
    tree
    bat
    tmux
    yt-dlp
    mergiraf
    gh
    htop
    btop
    ripgrep
    ffmpeg
    p7zip
    fzf
    clipse
    tree-sitter
    lsof
    gnupg
    apacheHttpd

    # lua
    lua5_1
    lua5_1.pkgs.luarocks
    lua-language-server
    stylua

    #go
    go
    gopls
    gofumpt
    golangci-lint

    #nix
    nixfmt # official nix formatter
    # nix-init
    nixd
    nil
    nh
    direnv

    #python
    python3
    basedpyright
    # python3.pkgs.pip

    nodejs
    pnpm
    yarn

    rustup

    typescript

    #other
    # bruno
    postman
    redis
    slack
    gnumake
    zrok
    # terraform
    witr
    aria2
    tailscale

    #ollama
    vector
    k6

    # unfree
    mongodb-compass
    ngrok
  ];
}
