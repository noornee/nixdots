{ config, pkgs, userSettings, inputs, ... }:

{
  # Import the modules
  imports = [
    inputs.nix-colors.homeManagerModule

    ./options.nix
    ./wm/hyprland
    ./terminal/kitty
    ./shell/zsh.nix
    ./browser/brave.nix
    ./programs
    ../overlays
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

  home.stateVersion = "23.11";
  programs.home-manager.enable = true;
}
