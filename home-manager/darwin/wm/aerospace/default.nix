{
  config,
  pkgs,
  lib,
  ...
}:

let
  borders = "${pkgs.jankyborders}/bin/borders";
  sketchybar = "${pkgs.sketchybar}/bin/sketchybar";
  kitty = "${config.programs.kitty.package}/bin/kitty";

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

      workspace-to-monitor-force-assignment."11" = "secondary";

      after-startup-command = [
        "exec-and-forget ${borders}"
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
          cmd-backtick = "layout tiles horizontal vertical"; # togglesplit; press again to flip direction
          cmd-g = "layout accordion horizontal vertical"; # togglegroup; press again to flip direction

          cmd-backspace = "close";

          # --single-instance: new windows open inside the already-running Kitty, so the
          # Dock shows one Kitty icon instead of one per window.
          cmd-enter = "exec-and-forget ${kitty} --single-instance --directory ~";

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

          # Float / tile the focused window (Hyprland super+v; cmd+v is Paste)
          # cmd-shift-v = "layout floating tiling";

          # Workspace 11 = second screen / TV
          alt-y = "workspace 11";
          alt-shift-y = "move-node-to-workspace 11";

          # Scratchpad
          alt-s = "workspace --auto-back-and-forth S"; # press again to go back
          cmd-alt-s = "move-node-to-workspace S";

          alt-tab = "workspace-back-and-forth";
          alt-shift-tab = "move-workspace-to-monitor --wrap-around next";

          # fullscreen & size
          cmd-m = "fullscreen";
          cmd-shift-f = "macos-native-fullscreen";
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

      # Window rules
      on-window-detected = [
        # Small utility apps float instead of tiling
        {
          "if".app-id = "com.apple.systempreferences";
          run = "layout floating";
        }
        {
          "if".app-id = "com.apple.calculator";
          run = "layout floating";
        }
        {
          "if".app-id = "com.apple.archiveutility";
          run = "layout floating";
        }
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
