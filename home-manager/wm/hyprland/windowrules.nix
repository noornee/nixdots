{ ... }:
{
  wayland.windowManager.hyprland = {
    settings = {
      windowrule = [
        # opacity rules
        "opacity 1.0 override 1.0 override,^(mpv)$"
        "opacity 0.95 override 0.9 override,^(org.pwmt.zathura)$"
        "opacity 0.95 override 0.9 override,^(Brave-browser)$"
        "opacity 0.95 override 0.9 override,^(Slack)$"
        "opacity 0.95 override 0.9 override,^(Insomnia)$"
      ];

      windowrulev2 = [
        # opacity rules
        "opacity 0.95 override 0.90,class:^(libreoffice-impress)$"
        "opacity 0.95 override 0.80,class:^(bruno)$"

        # workspace rules
        "workspace 3,class:^(Brave-browser)$"
        "workspace 4,class:^(Slack)$"

        # float rules
        "float,class:^(pavucontrol)$"
        "float,center,title:^(Open Files)$"
      ];

    };
  };
}
