{ config, pkgs, lib, ... }:
let
  cfg = config.custom;
in
{
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

    kooha # screen recorder
  ];

  custom.shell.profileExtra = ''
    if [[ -z "$DISPLAY" ]] && [[ $(tty) = /dev/tty1 ]]; then
    	exec Hyprland 2>/dev/null
    fi
  '';

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    xwayland.enable = true;
    settings = {

      monitor = [
        "LVDS-1,1920x1080@60,0x0,1"
      ];

      exec-once = [
        ''${
          if cfg.wallpaper.swaybg.enable then ''
		  "$XDG_CONFIG_HOME/swaybg/swaybg"
		  ''
		  else ''''
		}''
        "waybar"
        # "fcitx5 -d"
        "nm-applet --indicator"
        # "[workspace 1 silent] setsid kitty -e tmux new -s 'workspace 󱔡 '"
        # "[workspace 3 silent] brave --profile-directory=Default"
      ];

      env = [
        "XCURSOR_SIZE,12"
        "WLR_NO_HARDWARE_CURSORS,1"
      ];

      input = {
        kb_layout = "us";
        kb_options = "caps:swapescape"; # remaps capslock to esc
        follow_mouse = 1;
        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
        touchpad = {
          natural_scroll = false;
        };
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
        drop_shadow = true;
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
        inactive_opacity = 0.8;
        active_opacity = 0.9;

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

      gestures = {
        workspace_swipe = false;
      };

      misc = {
        focus_on_activate = true;
        # if swaybg is enabled, disable hyprland logo
        disable_hyprland_logo = lib.mkIf (cfg.wallpaper.swaybg.enable) true;
      };
    };
  };
}
