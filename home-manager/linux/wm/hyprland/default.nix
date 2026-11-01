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
    configType = "lua";

    extraConfig = /* lua */ ''
      ---@module 'hl'

      ------------------
      ---- MONITORS ----
      ------------------
      hl.monitor({ output = "eDP-1", mode = "1920x1200@60", position = "0x0", scale = 1 })

      -------------------
      ---- AUTOSTART ----
      -------------------
      hl.on("hyprland.start", function()
        ${lib.optionalString cfg.wallpaper.swaybg.enable "hl.exec_cmd(\"${config.xdg.configHome}/swaybg/swaybg\")"}
        hl.exec_cmd("uwsm app -- nm-applet --indicator")
        hl.exec_cmd("uwsm app -- clipse -listen")
      end)

      -------------------------------
      ---- ENVIRONMENT VARIABLES ----
      -------------------------------
      hl.env("HYPRCURSOR_THEME", "rose-pine-hyprcursor")
      hl.env("HYPRCURSOR_SIZE", "24")
      hl.env("XCURSOR_THEME", "BreezeX-Black")
      hl.env("XCURSOR_SIZE", "24")
      hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
      hl.env("TERMINAL", "kitty")

      -----------------------
      ---- LOOK AND FEEL ----
      -----------------------
      hl.config({
        general = {
          gaps_in     = 5,
          gaps_out    = 10,
          border_size = 1,
          layout      = "dwindle",
          col = {
            active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
          },
        },

        decoration = {
          rounding         = 0,
          active_opacity   = 0.9,
          inactive_opacity = 0.8,
          shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = "rgba(1a1a1aee)",
          },
          blur = {
            enabled           = true,
            size              = 3,
            passes            = 1,
            new_optimizations = true,
            ignore_opacity    = true,
          },
        },

        animations = { enabled = true },

        dwindle = { preserve_split = true },

        group = {
          groupbar = {
            font_size   = 11,
            height      = 20,
            gradients   = true,
            font_family = "JetBrainsMonoNL NF ExtraBold",
            col = {
              active          = "rgba(98971aff)",
              inactive        = "rgba(1a1d1aff)",
              locked_active   = "rgba(8c3d3dff)",
              locked_inactive = "rgba(141516ff)",
            },
          },
        },

        input = {
          kb_layout    = "us",
          kb_options   = "caps:swapescape", -- remaps capslock to esc
          follow_mouse = 1,
          sensitivity  = 0,
          touchpad     = { natural_scroll = false },
        },

        misc = {
          focus_on_activate     = true,
          -- if swaybg is enabled, disable hyprland logo
          disable_hyprland_logo = ${lib.boolToString cfg.wallpaper.swaybg.enable},
        },

        ecosystem = {
          no_donation_nag = true,
          no_update_news  = true,
        },

        debug = { disable_logs = false },
      })
    '';
  };
}
