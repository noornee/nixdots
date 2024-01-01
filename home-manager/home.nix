{ config, pkgs, ... }:

{
  # Import the modules
  imports = [
    ./modules/lf/lf.nix
    ./modules/git.nix
    ./modules/gtk.nix
    ./modules/zsh.nix
    ./modules/misc.nix
  ];

  home.username = "noornee";
  home.homeDirectory = "/home/noornee";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    kitty
    jq
    wl-clipboard

    # font
    iosevka
    (nerdfonts.override { fonts = [ "Iosevka" "JetBrainsMono" ]; })

    pistol
    ffmpegthumbnailer
    neofetch
    dunst
    brillo
    pulseaudio
    pavucontrol
    waybar
    swaybg
    bemenu

    lua
    lua-language-server
    stylua
    go
    gopls

    brave
    mpv
    ffmpeg
    jmtpfs
    nixpkgs-fmt
    rnix-lsp
    bat
    tmux
    libnotify # notify-send
    unzip
    zip
    yt-dlp
	grim
	slurp
	lazygit
  ];

  fonts.fontconfig.enable = true;


  home.stateVersion = "23.11";
  programs.home-manager.enable = true;
}
