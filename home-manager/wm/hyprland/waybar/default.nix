{ config, pkgs, ... }:
let
  Custom = import ./style.nix { inherit config; };
in
{
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
    settings = [
      {
        # HDMI OUTPUT
        layer = "top";
        output = "DP-3";
        position = "bottom";
        modules-center = [ "hyprland/workspaces" ];
      }
      {
        # Laptop
        layer = "top";
        output = "LVDS-1";
        position = "top";
        height = 40;

        modules-left = [
          "custom/padd"
          "custom/l_end"
          "custom/nix"
          "hyprland/workspaces"
          "hyprland/window"
          "custom/r_end"
          "custom/l_end"
          "cpu"
          "memory"
          "temperature"
          "custom/r_end"
          "custom/padd"
        ];

        modules-center = [
          "custom/padd"
          "custom/l_end"
          "clock"
          "custom/r_end"
          "custom/padd"
        ];

        modules-right = [
          "custom/padd"
          "custom/l_end"
          "battery"
          "pulseaudio"
          "custom/r_end"
          "custom/l_end"
          "tray"
          "custom/r_end"
          "custom/notification"
          "custom/padd"
        ];

        "hyprland/workspaces" = {
          format = "{name}: {icon} ";
          format-icons = {
            "1" = "";
            "2" = "";
            "3" = "";
            "4" = "";
            "5" = "";
            "urgent" = "";
            "focused" = "";
            "default" = "";
          };
        };

        "hyprland/window" = {
          format = "{}";
          separate-outputs = true;
        };


        "custom/nix" = {
          format = "<span font='15'> </span>";
          tooltip = false;
        };


        cpu = {
          interval = 10;
          format = "󰍛 {usage}%";
          format-alt = "{icon0}{icon1}{icon2}{icon3}";
        };

        memory = {
          interval = 30;
          format = "󰾆 {percentage}%";
          format-alt = "󰾅 {used}GB";
          max-length = 30;
          tooltip = true;
          tooltip-format = " {used:0.1f}GB/{total:0.1f}GB";
        };

        temperature = {
          format = "{temperatureC}°C ";
        };

        clock = {
          format = " {:%I:%M %p 󰃭 %a %d}";
          format-alt = "{:󰥔 %H:%M  %b %Y}";
          tooltip-format = "<tt><big>{calendar}</big></tt>";
          calendar = {
            format = {
              today = "<span color='#ff6699'><b><u>{}</u></b></span>";
            };
          };
        };

        battery = {
          states = {
            good = 95;
            warning = 30;
            critical = 20;
          };
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          format-plugged = " {capacity}%";
          format-alt = "{time} {icon}";
          format-icons = [ "󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
        };

        pulseaudio = {
          format = "{icon} {volume}";
          format-muted = "";
          on-click = "pavucontrol -t 3";
          tooltip-format = "{icon} {desc} // {volume}%";
          scroll-step = 5;
          format-icons = {
            headphone = "";
            hands-free = "";
            headse = "";
            phone = "";
            portable = "";
            car = "";
            default = [ "" "" "" ];
          };
        };

        tray = {
          icon-size = 15;
          spacing = 9;
        };

        "custom/notification" = {
          tooltip = false;
          format = "{icon} {}";
          format-icons = {
            notification = "<span foreground='red'><sup></sup></span>";
            none = "";
            dnd-notification = "<span foreground='red'><sup></sup></span>";
            dnd-none = "";
            inhibited-notification = "<span foreground='red'><sup></sup></span>";
            inhibited-none = "";
            dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
            dnd-inhibited-none = "";
          };
          return-type = "json";
          exec-if = "which swaync-client";
          exec = "swaync-client -swb";
          on-click = "swaync-client -t -sw";
          escape = true;
        };


        # PADDING
        "custom/l_end" = {
          format = " ";
          interval = "once";
          tooltip = false;
        };

        "custom/r_end" = {
          format = " ";
          interval = "once";
          tooltip = false;
        };

        "custom/sl_end" = {
          format = " ";
          interval = "once";
          tooltip = false;
        };

        "custom/sr_end" = {
          format = " ";
          interval = "once";
          tooltip = false;
        };

        "custom/rl_end" = {
          format = " ";
          interval = "once";
          tooltip = false;
        };

        "custom/rr_end" = {
          format = " ";
          interval = "once";
          tooltip = false;
        };

        "custom/padd" = {
          format = "  ";
          interval = "once";
          tooltip = false;
        };
      }
    ];
    style = Custom.styles;
  };
}
