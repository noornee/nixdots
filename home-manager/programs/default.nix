{ pkgs, ... }: {
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
  ];

  home.packages = with pkgs; [
    pulseaudio
    pavucontrol

    #doc viewer
    zathura
    # libreoffice

    #utils
    jq
    eza
    tree
    bat
    tmux
    yt-dlp
    lazygit
    htop
    ripgrep
    ffmpeg
    jmtpfs
    p7zip
    fzf
    clipse
    redisinsight

    # lua
    lua
    lua-language-server
    stylua
    luarocks

    #go
    go
    gopls
    gofumpt
    golangci-lint

    #nix
    nixpkgs-fmt # repo is archived
    nixfmt-classic # official nix formatter
    # nix-init
    nixd
    nil
    nh

    #python
    # python3
    # python3.pkgs.pip

    nodejs
    rustup

    #other
    # bruno
    postman
    redis
    slack
    gnumake
    zrok

    # unfree
    mongodb-compass
    ngrok
  ];

}
