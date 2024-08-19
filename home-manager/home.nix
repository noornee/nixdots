{ config, pkgs, userSettings, inputs, ... }:

{
  # Import the modules
  imports = [
    inputs.nix-colors.homeManagerModule

    ./modules/options.nix
    ./wm/hyprland
    ./terminal/kitty
    ./shell/zsh.nix
    ./browser/brave.nix
    ./programs
  ];

  colorScheme = inputs.nix-colors.colorSchemes.gruvbox-dark-hard;

  # check ./modules/options.nix for details on this
  custom.wallpaper.swaybg.enable = true;

  home.username = userSettings.username;
  home.homeDirectory = "/home/" + userSettings.username;

  home.stateVersion = "23.11";
  programs.home-manager.enable = true;
}
