{ config, pkgs, ... }:
let
  palette = config.colorScheme.palette;
  hyprctl = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl";
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  dpms = state: "${hyprctl} dispatch 'hl.dsp.dpms({ action = \"${state}\" })'";

  # "󰎈  artist - title" for whatever is playing, empty when nothing is
  nowPlaying = pkgs.writeShellScript "hyprlock-now-playing" ''
    song=$(${pkgs.playerctl}/bin/playerctl metadata --format '{{ artist }} - {{ title }}' 2>/dev/null)
    [ -n "$song" ] && echo "󰎈  $song"
  '';

  # idle dim: save the current level, then halve it. A fixed "set 10%" would
  # brighten the screen whenever it's already below 10%.
  dimScreen = pkgs.writeShellScript "idle-dim" ''
    cur=$(${brightnessctl} get)
    half=$(( cur / 2 ))
    [ "$half" -lt 1 ] && half=1
    ${brightnessctl} -s set "$half"
  '';

  # soft shadow so text stays readable on any background
  shadow = {
    shadow_passes = 2;
    shadow_size = 4;
    shadow_color = "rgba(00000099)";
  };
in
{
  # lock screen (PAM is set up by programs.hyprlock in the nixos config)
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
        fail_timeout = 4000; # keep the "wrong password" message up for 4s
      };

      # fade in on lock, fade out on unlock
      animations = {
        enabled = true;
        bezier = "ease, 0.25, 0.1, 0.25, 1";
        animation = [
          "fadeIn, 1, 4, ease"
          "fadeOut, 1, 4, ease"
        ];
      };

      background = [
        {
          path = "screenshot";
          blur_passes = 2;
          blur_size = 4;
          brightness = 0.6; # darker, so the text stands out
          vibrancy = 0.2;
        }
      ];

      # profile picture: at ~/.face
      image = [
        (
          {
            path = "${config.home.homeDirectory}/.face";
            size = 130;
            rounding = -1; # circle
            border_size = 3;
            border_color = "rgb(${palette.base0D})";
            position = "0, 130";
            halign = "center";
            valign = "center";
          }
          // shadow
        )
      ];

      label = [
        # clock + date in the top right corner
        (
          {
            text = "$TIME";
            font_size = 64;
            font_family = "JetBrainsMonoNL NF ExtraBold";
            color = "rgb(${palette.base05})";
            position = "-50, -30";
            halign = "right";
            valign = "top";
          }
          // shadow
        )
        (
          {
            text = "cmd[update:60000] date '+%A, %d %B'";
            font_size = 16;
            font_family = "JetBrainsMonoNL NF";
            color = "rgb(${palette.base04})";
            position = "-50, -130";
            halign = "right";
            valign = "top";
          }
          // shadow
        )
        # centre: picture, greeting, password box
        (
          {
            text = "Hi $USER :)";
            font_size = 18;
            font_family = "JetBrainsMonoNL NF";
            color = "rgb(${palette.base0A})";
            position = "0, 30";
            halign = "center";
            valign = "center";
          }
          // shadow
        )
        (
          {
            text = "cmd[update:2000] ${nowPlaying}";
            font_size = 14;
            font_family = "JetBrainsMonoNL NF";
            color = "rgb(${palette.base04})";
            position = "0, 40";
            halign = "center";
            valign = "bottom";
          }
          // shadow
        )
      ];

      input-field = [
        (
          {
            size = "300, 50";
            outline_thickness = 2;
            rounding = 12;
            outer_color = "rgb(${palette.base0D})";
            inner_color = "rgba(${palette.base00}cc)"; # slightly see-through
            capslock_color = "rgb(${palette.base09})"; # orange border while caps lock is on
            font_color = "rgb(${palette.base05})";
            check_color = "rgb(${palette.base0A})";
            fail_color = "rgb(${palette.base08})";
            placeholder_text = "<i>󰌾  password...</i>";
            dots_spacing = 0.3;
            fail_text = "<i>$FAIL</i> <b>($ATTEMPTS)</b>"; # e.g. "authentication failed (2)"
            fade_on_empty = false;
            position = "0, -40";
            halign = "center";
            valign = "center";
          }
          // shadow
        )
      ];
    };
  };

  # idle: dim at 5m, lock at 10m, screen off at 11m, suspend at 30m
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "${pkgs.procps}/bin/pidof hyprlock || ${config.programs.hyprlock.package}/bin/hyprlock";
        before_sleep_cmd = "loginctl lock-session"; # lock before suspend
        after_sleep_cmd = dpms "on";
      };

      listener = [
        {
          timeout = 300;
          on-timeout = "${dimScreen}";
          on-resume = "${brightnessctl} -r";
        }
        {
          timeout = 600;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 660;
          on-timeout = dpms "off";
          on-resume = dpms "on";
        }
        {
          timeout = 1800;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
}
