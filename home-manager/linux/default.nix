{
  userSettings,
  inputs,
  pkgs,
  ...
}:

{
  # Import the modules
  imports = [
    inputs.nix-colors.homeManagerModule
    ../common/programs/zathura.nix
    ../common/programs/xdg.nix
    ../common/programs/mpv
    ../common/programs/photos.nix
    ../common/options.nix
    ../linux/wm/hyprland
    ../common/terminal/kitty
    ../common/shell/zsh.nix
    ../common/browser/brave.nix
    ../common/programs
    ../../overlays
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
    pnpm

    rustup

    typescript-go

    #other
    # bruno
    wkhtmltopdf
    chromium
    libreoffice
    postman
    redis
    slack
    gnumake
    zrok
    terraform
    obs-studio
    redisinsight
    witr
    aria2
    ollama

    # unfree
    mongodb-compass
    ngrok
  ];

  colorScheme = inputs.nix-colors.colorSchemes.gruvbox-dark-hard;

  # check ./options.nix for details on this
  custom.wallpaper.swaybg.enable = true;

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };

  home.username = userSettings.username;
  home.homeDirectory = "/home/" + userSettings.username;

  home.stateVersion = "26.05";
  programs.home-manager.enable = true;
}
