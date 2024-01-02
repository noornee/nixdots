{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "noornee";
    userEmail = "noornee.011@gmail.com";
  };
}
