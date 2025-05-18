{ ... }: {
  wayland.windowManager.hyprland = {
    settings = {
      windowrule = [
        # opacity rules
        "opacity 1.0 override 1.0 override,class:^(mpv)$"
        "opacity 0.95 override 0.9 override,class:^(org.pwmt.zathura)$"
        "opacity 0.95 override 0.9 override,class:^(brave-browser)$"
        "opacity 0.95 override 0.9 override,class:^(Slack)$"

        # workspace rules
        "workspace 3,class:^(brave-browser)$"
        "workspace 4,class:^(Slack)$"

        # float rules
        "float,class:^(pavucontrol)$"
        "float,center,title:^(Open Files)$"
      ];
    };
  };
}
