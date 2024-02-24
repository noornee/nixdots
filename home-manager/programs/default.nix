{ pkgs, ... }:
{
  imports = [
    ./lf
    ./mpv
    ./dev.nix
    ./font.nix
    ./gtk.nix
    ./git.nix
    ./i18n.nix
    ./xdg.nix
    ./photos.nix
    ./ncmpcpp.nix
  ];

  home.packages = with pkgs; [
    pulseaudio
    pavucontrol

    #archives
    zip
    unzip
    unrar

    #doc viewer
    zathura
    libreoffice

    #utils
    jq
    tree
    bat
    tmux
    yt-dlp
    lazygit
    neofetch
    htop
    ripgrep
    ffmpeg
    jmtpfs

    # other
    bruno # best postman alt
    redis

    # unfree softwares
    mongodb-compass
    ngrok
  ];
}
