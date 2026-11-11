{
  userSettings,
  inputs,
  pkgs,
  lib,
  ...
}:

{
  # Import the modules
  imports = [
    inputs.nix-colors.homeManagerModule
    # ../common/programs/lf
    ../common/programs/mpv
    ../common/programs/zathura.nix
    ../common/programs/xdg.nix
    ../common/programs/gtk.nix
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
    wkhtmltopdf
    # libreoffice
    chromium
    obs-studio
    wev
    # redisinsight
    openssl
    pinentry-curses
    wtype # xdotool for wayland
  ];

  # ssh agent = gcr-ssh-agent from gnome keyring (nixos config); point every shell at it
  home.sessionVariables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gcr/ssh";

  # low battery notifications: warning at 30%, critical at 10%, suspend at 2%
  services.batsignal.enable = true;
  systemd.user.services.batsignal.Service.ExecStart =
    lib.mkForce "${pkgs.batsignal}/bin/batsignal -w 30 -c 10 -d 2 -D 'systemctl suspend' -I battery-caution-symbolic";

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
