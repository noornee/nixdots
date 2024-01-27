{ config, pkgs, ... }:

{

  xdg.configFile."mpv/scripts/mpv-cut/main.lua".source = ./scripts/mpv-cut/main.lua;

  programs.mpv = {
    enable = true;
    bindings = {
      l = "seek 5";
      h = "seek -5";
      k = "add volume 2";
      j = "add volume -2";
    };

    config = {
      save-position-on-quit = true;
      screenshot-directory = "~/media/pictures/mpv/";
      screenshot-template = "%F_%03n";
    };

  };

}
