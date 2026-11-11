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

      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 7;
        }
      ];

      # profile picture: at ~/.face
      image = [
        {
          path = "${config.home.homeDirectory}/.face";
          size = 130;
          rounding = -1; # circle
          border_size = 3;
          border_color = "rgb(${palette.base0D})";
          position = "0, 290";
          halign = "center";
          valign = "center";
        }
      ];

      label = [
        {
          text = "$TIME";
          font_size = 90;
          font_family = "JetBrainsMonoNL NF ExtraBold";
          color = "rgb(${palette.base05})";
          position = "0, 120";
          halign = "center";
          valign = "center";
        }
        {
          text = "cmd[update:2000] ${nowPlaying}";
          font_size = 14;
          font_family = "JetBrainsMonoNL NF";
          color = "rgb(${palette.base04})";
          position = "0, 40";
          halign = "center";
          valign = "bottom";
        }
      ];

      input-field = [
        {
          size = "300, 50";
          outline_thickness = 2;
          outer_color = "rgb(${palette.base0D})";
          inner_color = "rgb(${palette.base00})";
          font_color = "rgb(${palette.base05})";
          check_color = "rgb(${palette.base0A})";
          fail_color = "rgb(${palette.base08})";
          placeholder_text = "password...";
          fail_text = "<i>$FAIL</i> <b>($ATTEMPTS)</b>"; # e.g. "authentication failed (2)"
          fade_on_empty = false;
          position = "0, -40";
          halign = "center";
          valign = "center";
        }
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
          on-timeout = "${brightnessctl} -s set 10%";
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
