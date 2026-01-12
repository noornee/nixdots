{ config, pkgs, ... }: {
  home.packages = with pkgs; [ xdg-utils ];

  programs.zathura = {
    enable = true;
    options = { selection-clipboard = "clipboard"; };
  };

  xdg.mimeApps.defaultApplications = {
    "application/pdf" = [ "org.pwmt.zathura.desktop" ];
  };

}
