{ config, pkgs, userSettings, ... }:

{
  # Import the modules
  imports = [
    ./wm/hyprland
    ./terminal/kitty
    ./shell/zsh.nix
    ./browser/brave.nix
    ./programs
  ];

  home.username = userSettings.username;
  home.homeDirectory = "/home/" + userSettings.username;

  services.syncthing.enable = true;

  home.stateVersion = "23.11";
  programs.home-manager.enable = true;
}
