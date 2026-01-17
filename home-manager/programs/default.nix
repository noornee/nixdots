{ pkgs, ... }:
{
  imports = [
    ./lf
    ./mpv
    ./zellij
    ./font.nix
    ./gtk.nix
    ./git.nix
    # ./i18n.nix
    ./xdg.nix
    ./photos.nix
    # ./ncmpcpp.nix
    ./fastfetch.nix
    ./tmux.nix
    ./zathura.nix
  ];

  home.packages = with pkgs; [
    pulseaudio
    pavucontrol

    #utils
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
    jmtpfs
    p7zip
    fzf
    clipse
    tree-sitter
    lsof
    wev

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
    rustup

    #other
    # bruno
    libreoffice
    postman
    redis
    slack
    gnumake
    zrok
    terraform
    obs-studio
    redisinsight

    # unfree
    mongodb-compass
    ngrok
  ];

}
