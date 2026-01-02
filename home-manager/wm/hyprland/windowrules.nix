{ ... }: {
  wayland.windowManager.hyprland = {
    settings = {
      windowrule = [
        # opacity rules
        "opacity 1.0 override 1.0 override, match:class ^(mpv)$"
        "opacity 0.95 override 0.9 override, match:class ^(org.pwmt.zathura)$"
        "opacity 0.95 override 0.9 override, workspace 3, match:class ^(brave-browser)$"
        "opacity 0.95 override 0.9 override, workspace 4, match:class ^(Slack)$"

        # float rules
        "float on, match:class ^(pavucontrol)$"
        "float on, center on, match:title ^(Open Files)$"
        "float on, center on, size (monitor_w*0.5) (monitor_h*0.5), match:title (.*wants to open)$"
        "float on, center on, size (monitor_w*0.6) (monitor_h*0.6), match:title ^(neorg-note)$"

        "match:class xdg-desktop-portal-gtk float on, size <50% <50%"
      ];
    };
  };
}
