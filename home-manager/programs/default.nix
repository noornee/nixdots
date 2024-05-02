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
    ./neofetch.nix
    ./tmux.nix
  ];

  home.packages = with pkgs; [
    pulseaudio
    pavucontrol

    #doc viewer
    zathura
    libreoffice

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

    # other
    bruno # best postman alt
    redis
    nh

    # unfree softwares
    mongodb-compass
    ngrok
  ];
}
