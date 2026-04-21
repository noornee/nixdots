{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.tmux = {
    enable = true;
    mouse = true;
    terminal = lib.mkIf (config.programs.kitty.enable) "xterm-kitty";
    keyMode = "vi";
    historyLimit = 5000;
    escapeTime = 0;
    baseIndex = 1; # index panes and windows starts from 1
    extraConfig = ''

      set -g status-position bottom
      set -g status-style bg=colour235,fg=colour137,dim

      set -g status-left-length 20

      set -g status-left "#[fg=colour46,bold] [#S] #[fg=colour235,nobold]"

      # Add minimal padding before first window
      setw -g window-status-format "  #I:#W "
      setw -g window-status-current-format "  #I:#W "


      # Active window style
      setw -g window-status-current-style 'fg=colour46,bold,bg=colour237'
      setw -g window-status-current-format ' #I #[fg=colour249]:#[fg=colour255]#W#[fg=colour249]#F '

      # Inactive window style
      setw -g window-status-style 'fg=colour250,bg=colour235'
      setw -g window-status-format ' #I #[fg=colour237]:#[fg=colour250]#W#[fg=colour244]#F '

      # Pane borders
      set -g pane-border-style bg=default,fg=colour8
      set -g pane-active-border-style bg=default,fg=colour7

      # -----------------------
      # MESSAGES
      # -----------------------
      set -g message-style 'fg=colour232,bg=colour3,bold'

      # -----------------------
      # MOUSE, KEYS, AND BEHAVIOR
      # -----------------------
      set -g mouse on
      set -g focus-events off
      setw -g aggressive-resize off
      setw -g clock-mode-style 12
      set -s escape-time 0
      set -g history-limit 5000
      set -g status-keys vi
      set -g mode-keys vi

      # -----------------------
      # KEYBINDINGS
      # -----------------------
      # Reload config
      bind r source-file ~/.config/tmux/tmux.conf

      # Pane navigation
      bind -n M-k select-pane -U
      bind -n M-j select-pane -D
      bind -n M-l select-pane -L
      bind -n M-h select-pane -R

      # Window navigation
      # switch between windows <Alt-h> || <Alt-l>
      bind -n M-h select-window -p
      bind -n M-l select-window -n

      # Split panes in current path
      bind v split-window -v -c "#{pane_current_path}"
      bind h split-window -h -c "#{pane_current_path}"
    '';
    # plugins = with pkgs;[
    #   {
    #     plugin = tmuxPlugins.resurrect;
    #     extraConfig = "set -g @resurrect-strategy-nvim 'session'";
    #   }
    # ];
  };

}
