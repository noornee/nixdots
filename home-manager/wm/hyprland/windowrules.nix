{ ... }:
{
  wayland.windowManager.hyprland = {
    settings = {
      windowrule = [
        "opacity 1.0 override 1.0 override,^(mpv)$"
      ];

      windowrulev2 = [
        # opacity rules
        "opacity 0.95 override 0.80 override,class:^(Brave-browser)$"
        "opacity 0.95 override 0.90,class:^(libreoffice-impress)$"
        "opacity 0.95 override 0.80,class:^(bruno)$"
        "opacity 0.95 override 0.80,class:^(org.pwmt.zathura)$"

        # workspace rules
        "workspace 3,class:^(Brave-browser)$"

        # float rules
        "float,class:^(pavucontrol)$"
        "float,center,title:^(Open Files)$"
      ];

    };
  };
}
