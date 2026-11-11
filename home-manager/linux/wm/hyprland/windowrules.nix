{ ... }:
{
  wayland.windowManager.hyprland.extraConfig = /* lua */ ''
    ---------------------
    ---- WINDOW RULES ----
    ---------------------
    -- ignore maximize requests from apps (otherwise they open "monocle"-style as if SUPER+M was pressed)
    hl.window_rule({
      name           = "suppress-maximize-events",
      match          = { class = ".*" },
      suppress_event = "maximize",
    })

    -- opacity rules
    hl.window_rule({ match = { class = "^(mpv)$" },             opacity = "1.0 override 1.0 override" })
    hl.window_rule({ match = { class = "^(org.pwmt.zathura)$" }, opacity = "0.95 override 0.9 override" })
    hl.window_rule({ match = { class = "^(brave-browser)$" },   opacity = "0.95 override 0.9 override", workspace = 3 })
    hl.window_rule({ match = { class = "^(Slack)$" },           opacity = "0.95 override 0.9 override", workspace = 4 })

    -- float rules
    hl.window_rule({ match = { class = "^(org.pulseaudio.pavucontrol|pavucontrol)$" }, float = true })
    hl.window_rule({ match = { title = "^(Open Files)$" }, float = true, center = true })
    hl.window_rule({
      match  = { title = "(.*wants to open)$" },
      float  = true,
      center = true,
      size   = { "monitor_w * 0.5", "monitor_h * 0.5" },
    })
    hl.window_rule({
      match  = { title = "^(neorg-note)$" },
      float  = true,
      center = true,
      size   = { "monitor_w * 0.6", "monitor_h * 0.6" },
    })
    hl.window_rule({ 
    	match = { class = "xdg-desktop-portal-gtk" }, 
    	float = true, 
    	max_size = { "monitor_w * 0.5", "monitor_h * 0.5" },
    })
  '';
}
