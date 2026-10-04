{
  pkgs,
  lib,
  ...
}:

let
  borders = "${pkgs.jankyborders}/bin/borders";
  sketchybar = "${pkgs.sketchybar}/bin/sketchybar";

  # 1..10 -> { "cmd-1" = "workspace 1"; ... "cmd-0" = "workspace 10"; }
  workspaces = lib.range 1 10;
  keyFor = n: if n == 10 then "0" else toString n;
  workspaceBinds = lib.listToAttrs (
    map (n: lib.nameValuePair "cmd-${keyFor n}" "workspace ${toString n}") workspaces
  );
  moveToWorkspaceBinds = lib.listToAttrs (
    map (n: lib.nameValuePair "cmd-shift-${keyFor n}" "move-node-to-workspace ${toString n}") workspaces
  );
in
{
  xdg.enable = true;

  programs.aerospace = {
    enable = true;
    launchd.enable = true;

    settings = {
      config-version = 2;
      persistent-workspaces = map toString workspaces ++ [ "11" ];

      after-startup-command = [
        "exec-and-forget ${borders}"
        # "exec-and-forget ${sketchybar}"
        # "exec-and-forget ${borders} active_color=0xffd79921 inactive_color=0xff282828 width=3.0"
      ];

      # Normalizations. See: https://nikitabobko.github.io/AeroSpace/guide#normalization
      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = true;

      # See: https://nikitabobko.github.io/AeroSpace/guide#layouts
      accordion-padding = 30;
      default-root-container-layout = "tiles"; # tiles|accordion
      default-root-container-orientation = "auto"; # horizontal|vertical|auto

      key-mapping.preset = "qwerty";

      # Mouse follows focus when focused monitor changes
      on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];

      # Notify Sketchybar about workspace change
      exec-on-workspace-change = [
        "/bin/bash"
        "-c"
        "${sketchybar} --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE PREV_WORKSPACE=$AEROSPACE_PREV_WORKSPACE"
      ];

      gaps = {
        inner.horizontal = 15;
        inner.vertical = 15;
        outer.left = 13;
        outer.bottom = 13;
        outer.top = [
          { monitor."built-in" = 13; }
          47
        ];
        outer.right = 13;
      };

      mode.main.binding =
        workspaceBinds
        // moveToWorkspaceBinds
        // {
          # See: https://nikitabobko.github.io/AeroSpace/commands#layout
          cmd-slash = "layout tiles horizontal vertical";
          cmd-comma = "layout accordion horizontal vertical";

          cmd-backspace = "close";

          cmd-enter = "exec-and-forget open -na Kitty";

          cmd-h = [
            "focus left"
            "move-mouse window-lazy-center"
          ];
          cmd-j = [
            "focus down"
            "move-mouse window-lazy-center"
          ];
          cmd-k = [
            "focus up"
            "move-mouse window-lazy-center"
          ];
          cmd-l = [
            "focus right"
            "move-mouse window-lazy-center"
          ];

          cmd-shift-h = "move left";
          cmd-shift-j = "move down";
          cmd-shift-k = "move up";
          cmd-shift-l = "move right";

          cmd-shift-minus = "resize smart -50";
          cmd-shift-equal = "resize smart +50";

          alt-y = "move-node-to-workspace 11";

          alt-tab = "workspace-back-and-forth";
          alt-shift-tab = "move-workspace-to-monitor --wrap-around next";

          # tiling
          cmd-m = "fullscreen";
          cmd-shift-f = "macos-native-fullscreen";
          cmd-shift-s = "layout v_accordion"; # 'layout stacking' in i3
          cmd-shift-t = "layout h_accordion"; # 'layout tabbed' in i3
          cmd-shift-e = "layout tiles horizontal vertical"; # 'layout toggle split' in i3
          cmd-shift-d = "resize width 1280";

          # modes
          cmd-shift-semicolon = "mode service";
          cmd-shift-g = "mode lock";
        };

      mode.service.binding = {
        r = "reload-config";
        f = [
          "flatten-workspace-tree"
          "mode main"
        ]; # reset layout
        backspace = [
          "close-all-windows-but-current"
          "mode main"
        ];

        cmd-shift-h = [
          "join-with left"
          "mode main"
        ];
        cmd-shift-j = [
          "join-with down"
          "mode main"
        ];
        cmd-shift-k = [
          "join-with up"
          "mode main"
        ];
        cmd-shift-l = [
          "join-with right"
          "mode main"
        ];

        enter = "mode main";
        esc = "mode main";
      };

      mode.lock.binding = {
        enter = "mode main";
        esc = "mode main";
      };

      mode.resize.binding = {
        enter = "mode main";
        esc = "mode main";
      };

      # Window rules
      on-window-detected = [
        {
          "if".app-id = "com.brave.Browser";
          run = "move-node-to-workspace 3";
        }
        {
          "if".app-id = "net.whatsapp.WhatsApp";
          run = "move-node-to-workspace 4";
        }
      ];
    };
  };
}
