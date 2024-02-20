{ config, pkgs, userSettings, ... }:

{
  # Import the modules
  imports = [
    ./wm/hyprland
    ./terminal/kitty
    ./shell/zsh.nix
    ./programs/lf
    ./programs/mpv
    ./programs/git.nix
    ./programs/gtk.nix
    ./programs/xdg.nix
    ./programs/i18n.nix
    ./programs/font.nix
    ./programs/photos.nix #image viewer
  ];

  home.username = userSettings.username;
  home.homeDirectory = "/home/" + userSettings.username;

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    jq
    tree

    ffmpegthumbnailer
    neofetch
    htop
    brillo
    pulseaudio
    pavucontrol
    zathura

    lua
    lua-language-server
    stylua

    go
    gopls
    gofumpt

    python3
    nodejs

    rustup

    brave
    ffmpeg
    jmtpfs
    nixpkgs-fmt
    rnix-lsp
    bat
    tmux
    unzip
    zip
    yt-dlp
    lazygit

    ripgrep

    bruno

    ncmpcpp
    mpd
    mpc-cli

    brightnessctl

    libreoffice
    # syncthing

    # unfree softwares
    mongodb-compass
    ngrok

  ];


  services.syncthing.enable = true;

  home.stateVersion = "23.11";
  programs.home-manager.enable = true;
}
