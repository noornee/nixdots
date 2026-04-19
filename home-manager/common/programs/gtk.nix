{ config, pkgs, ... }: {
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    cursorTheme = { name = "rose-pine-hyprcursor"; };
    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
    gtk3.extraConfig = { gtk-application-prefer-dark-theme = 1; };
  };
  home.sessionVariables = { GTK_THEME = "Adwaita:dark"; };
}
