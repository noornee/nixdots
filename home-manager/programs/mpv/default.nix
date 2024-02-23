{ pkgs, ... }:
let mpv-cut = pkgs.mpvScripts.callPackage ./scripts/mpv-cut { };
in
{
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
    scripts = [
      mpv-cut
    ];
  };
}
