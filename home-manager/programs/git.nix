{ config, pkgs, userSettings, ... }:

{
  programs.git = {
    enable = true;
    userName = userSettings.username;
    userEmail = userSettings.email;
  };
}
