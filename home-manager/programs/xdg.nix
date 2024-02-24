{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    xdg-utils
  ];

  xdg = {
    enable = true;
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "image/jpeg" = [ "imv.desktop" ];
        "image/png" = [ "imv.desktop" ];
        "video/mp4" = [ "mpv.desktop" ];
        "video/webm" = [ "mpv.desktop" ];
        "video/mkv" = [ "mpv.desktop" ];
      };
    };
  };

}
