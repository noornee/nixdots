{ ... }:
let
  mainMod = "SUPER";
in
{
  imports = [
    ./scripts.nix # shell scripts for the keybinds
  ];

  wayland.windowManager.hyprland = {
    settings = {
      # https://wiki.hyprland.org/Configuring/Variables/#binds
      binds = {
        workspace_back_and_forth = true;
        allow_workspace_cycles = true;
      };

      bind = [
        "${mainMod},W, killactive"
        "${mainMod},W, killactive,"
        "${mainMod}_ALT, Q, exit,"
        "${mainMod},V, togglefloating"
        "${mainMod},V, centerwindow, 1"
        "${mainMod},F, fullscreen, 0" # fullscreen
        "${mainMod},M, fullscreen, 1" # monocle
        "${mainMod},P, pseudo"
        "${mainMod}_SHIFT, P, pin"
        "${mainMod},grave, togglesplit"
        "${mainMod},Space, exec, bemenu-run"
        "${mainMod},N, exec, swaync-client -t -sw"
        "${mainMod},Return, exec, kitty"

        #https://www.reddit.com/r/hyprland/comments/zyrrtp/how_do_i_switch_back_and_forth_between_two/
        "${mainMod},TAB,workspace,previous"

        # special workspace (scratchpad)
        "${mainMod}_ALT, S, movetoworkspace, special"
        "${mainMod}, S, togglespecialworkspace,"

        # Move focus with mainMod + direction
        "${mainMod}, h, movefocus, l"
        "${mainMod}, l, movefocus, r"
        "${mainMod}, k, movefocus, u"
        "${mainMod}, j, movefocus, d"

        # swap position
        "${mainMod} SHIFT, h, swapwindow, l"
        "${mainMod} SHIFT, l, swapwindow, r"
        "${mainMod} SHIFT, k, swapwindow, u"
        "${mainMod} SHIFT, j, swapwindow, d"

        # resizeactive window
        "${mainMod}_ALT SHIFT, l, resizeactive, 10 -10"
        "${mainMod}_ALT SHIFT, h, resizeactive, -10 10"
        "${mainMod}_ALT SHIFT, k, resizeactive, 10 -10"
        "${mainMod}_ALT SHIFT, j, resizeactive, -10 10"

        # Switch workspaces with mainMod + [0-9]
        "${mainMod}, 1, workspace, 1"
        "${mainMod}, 2, workspace, 2"
        "${mainMod}, 3, workspace, 3"
        "${mainMod}, 4, workspace, 4"
        "${mainMod}, 5, workspace, 5"
        "${mainMod}, 6, workspace, 6"
        "${mainMod}, 7, workspace, 7"
        "${mainMod}, 8, workspace, 8"
        "${mainMod}, 9, workspace, 9"
        "${mainMod}, 0, workspace, 10"

        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        "${mainMod} SHIFT, 1, movetoworkspacesilent, 1"
        "${mainMod} SHIFT, 2, movetoworkspacesilent, 2"
        "${mainMod} SHIFT, 3, movetoworkspacesilent, 3"
        "${mainMod} SHIFT, 4, movetoworkspacesilent, 4"
        "${mainMod} SHIFT, 5, movetoworkspacesilent, 5"
        "${mainMod} SHIFT, 6, movetoworkspacesilent, 6"
        "${mainMod} SHIFT, 7, movetoworkspacesilent, 7"
        "${mainMod} SHIFT, 8, movetoworkspacesilent, 8"
        "${mainMod} SHIFT, 9, movetoworkspacesilent, 9"
        "${mainMod} SHIFT, 0, movetoworkspacesilent, 10"

        # Scroll through existing workspaces with mainMod + scroll
        "${mainMod}, mouse_down, workspace, e+1"
        "${mainMod}, mouse_up, workspace, e-1"
      ];

      bindm = [
        "${mainMod}, mouse:272, movewindow"
        "${mainMod}, mouse:273, resizewindow"
      ];

      binde = [
        # media controls
        ", XF86AudioMute, exec, pactl set-sink-mute 0 toggle"
        ", XF86AudioRaiseVolume, exec, volume up"
        ", XF86AudioLowerVolume, exec, volume down"

        # brightness controls
        ", XF86MonBrightnessUp, exec, brightness up"
        ", XF86MonBrightnessDown, exec, brightness down"

        # screenshot
        ", Print, exec, grimshot"
      ];

    };
  };
}
