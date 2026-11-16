{
  config,
  pkgs,
  lib,
  ...
}:

let
  borders = "${pkgs.jankyborders}/bin/borders";
  kittyApp = "${config.programs.kitty.package}/Applications/kitty.app";

  # border colour shows the binding mode (re-running borders updates the running one)
  modeBorder = pkgs.writeShellScript "aerospace-mode-border" ''
    case "$(${config.programs.aerospace.package}/bin/aerospace list-modes --current)" in
      service) color=0xfffabd2f ;; # gruvbox yellow
      lock) color=0xfffb4934 ;; # gruvbox red
      *) color=0xffe2e2e3 ;; # normal
    esac
    exec ${borders} active_color=$color
  '';

  # 1..10 -> { "cmd-1" = "workspace 1"; ... "cmd-0" = "workspace 10"; }
  workspaces = lib.range 1 10;
  keyFor = n: if n == 10 then "0" else toString n;
  workspaceBinds = lib.listToAttrs (
    map (n: lib.nameValuePair "cmd-${keyFor n}" "workspace ${toString n}") workspaces
  );
  moveToWorkspaceBinds = lib.listToAttrs (
    map (n: lib.nameValuePair "cmd-shift-${keyFor n}" "move-node-to-workspace ${toString n}") workspaces
  );
  # cmd-alt-N: bring workspace N to the monitor you're on (instead of jumping to it)
  summonWorkspaceBinds = lib.listToAttrs (
    map (n: lib.nameValuePair "cmd-alt-${keyFor n}" "summon-workspace ${toString n}") workspaces
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

      # service mode = yellow border, lock mode = red, back to normal in main
      on-mode-changed = [ "exec-and-forget ${modeBorder}" ];

      gaps = {
        inner.horizontal = 15;
        inner.vertical = 15;
        outer.left = 13;
        outer.bottom = 13;
        outer.top = 13;
        outer.right = 13;
      };

      mode.main.binding =
        workspaceBinds
        // moveToWorkspaceBinds
        // summonWorkspaceBinds
        // {
          # See: https://nikitabobko.github.io/AeroSpace/commands#layout
          cmd-backtick = "layout tiles horizontal vertical"; # togglesplit; press again to flip direction
          cmd-g = "layout accordion horizontal vertical"; # togglegroup; press again to flip direction

          cmd-backspace = "close";

          # Launched via `open` (not the kitty binary) so macOS treats Kitty as its own
          # app: permission prompts say "kitty", not "AeroSpace".
          cmd-enter = "exec-and-forget open -na ${kittyApp}";

          # at a screen edge, focus carries on to the next monitor
          cmd-h = [
            "focus --boundaries all-monitors-outer-frame left"
            "move-mouse window-lazy-center"
          ];
          cmd-j = [
            "focus --boundaries all-monitors-outer-frame down"
            "move-mouse window-lazy-center"
          ];
          cmd-k = [
            "focus --boundaries all-monitors-outer-frame up"
            "move-mouse window-lazy-center"
          ];
          cmd-l = [
            "focus --boundaries all-monitors-outer-frame right"
            "move-mouse window-lazy-center"
          ];

          # swap places with the neighbour (keeps the layout, unlike `move`)
          cmd-shift-h = "swap left";
          cmd-shift-j = "swap down";
          cmd-shift-k = "swap up";
          cmd-shift-l = "swap right";

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
          "if".during-aerospace-startup = false; # only new windows, not on restart/reload
          run = "move-node-to-workspace 3";
        }
        {
          "if".app-id = "net.whatsapp.WhatsApp";
          "if".during-aerospace-startup = false; # only new windows, not on restart/reload
          run = "move-node-to-workspace 4";
        }
        {
          "if".app-id = "com.postmanlabs.mac";
          "if".during-aerospace-startup = false; # only new windows, not on restart/reload
          run = "move-node-to-workspace 2";
        }
        {
          "if".app-id = "com.anthropic.claudefordesktop";
          "if".during-aerospace-startup = false; # only new windows, not on restart/reload
          run = "move-node-to-workspace 5";
        }
        {
          "if".app-id = "com.tinyspeck.slackmacgap";
          "if".during-aerospace-startup = false; # only new windows, not on restart/reload
          run = "move-node-to-workspace 6";
        }
      ];
    };
  };
}
