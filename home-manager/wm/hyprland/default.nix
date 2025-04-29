{ config, pkgs, lib, ... }:
let cfg = config.custom;
in {
  imports = [
    ./swaync
    ./waybar
    ./keybinds.nix
    ./animations.nix
    ./windowrules.nix
    ./wallpaper.nix
  ];

  # xdg.dataFile is ~/.local/share/
  xdg.dataFile."icons".source = ./assets;

  home.packages = with pkgs; [
    waybar
    swaybg
    wl-clipboard
    wf-recorder
    bemenu
    grim
    slurp
    satty

    #notification
    dunst
    libnotify
    nwg-look

    kooha # screen recorder
  ];

  custom.shell.profileExtra = ''
    if [[ $(tty) = /dev/tty1 ]]; then
    	if uwsm check may-start; then
    		exec uwsm start hyprland-uwsm.desktop
    	fi
    fi
  '';

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    xwayland.enable = true;

    # https://wiki.hyprland.org/Useful-Utilities/Systemd-start/#installation
    # conflicts with programs.hyprland.withUWSM in nixos
    systemd.enable = false;
    settings = {

      monitor = [ "LVDS-1,1920x1080@60,0x0,1" ];

      exec-once = [
        "${if cfg.wallpaper.swaybg.enable then ''
          "$XDG_CONFIG_HOME/swaybg/swaybg"
        '' else
          ""}"
        "uwsm app waybar"
        "uwsm app nm-applet --indicator"
        "uwsm app clipse -listen"
      ];

      env = [
        "HYPRCURSOR_THEME,rose-pine-hyprcursor"
        "HYPRCURSOR_SIZE,24"
        "XCURSOR_THEME,BreezeX-Black"
        "XCURSOR_SIZE,24"
      ];

      input = {
        kb_layout = "us";
        kb_options = "caps:swapescape"; # remaps capslock to esc
        follow_mouse = 1;
        sensitivity = 0;
        touchpad = { natural_scroll = false; };
      };

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 1;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
      };

      decoration = {
        rounding = 0;
        inactive_opacity = 0.8;
        active_opacity = 0.9;

        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };

        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          new_optimizations = true;
          ignore_opacity = true;
        };

      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      gestures = { workspace_swipe = false; };

      group = {
        groupbar = {
          font_size = 8;
          height = 20;
          font_family = "JetBrainsMonoNL NF ExtraBold";
          "col.active" = "rgba(1d2021ff)";
          "col.locked_active" = "rgba(1d2111ff)";
        };
      };

      misc = {
        focus_on_activate = true;
        # if swaybg is enabled, disable hyprland logo
        disable_hyprland_logo = lib.mkIf (cfg.wallpaper.swaybg.enable) true;
        new_window_takes_over_fullscreen = 2;
      };

      debug = { disable_logs = false; };
    };
  };
}
