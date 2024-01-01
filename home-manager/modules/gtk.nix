{ config, pkgs, ... }:

{
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
    };
  };
}
