{ config, pkgs, userSettings, inputs, ... }:

{
  # Import the modules
  imports = [
    inputs.nix-colors.homeManagerModule

    ./wm/hyprland
    ./terminal/kitty
    ./shell/zsh.nix
    ./browser/brave.nix
    ./programs
  ];


  colorScheme = inputs.nix-colors.colorSchemes.gruvbox-dark-hard;

  home.username = userSettings.username;
  home.homeDirectory = "/home/" + userSettings.username;

  services.syncthing.enable = true;

  home.stateVersion = "23.11";
  programs.home-manager.enable = true;
}
