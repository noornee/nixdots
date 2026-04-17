{ config, pkgs, lib, ... }:
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

	  # reload source-file
	  bind r source-file ~/.config/tmux/tmux.conf

	  # switch between panes
      bind -n M-k select-pane -U
      bind -n M-j select-pane -D
      bind -n M-l select-pane -L
      bind -n M-h select-pane -R

	  # switch between windows <Alt-H> || <Alt-L>
      bind -n M-H select-window -p
      bind -n M-L select-window -n

      # Set new panes to open in current directory
      bind v split-window -v -c "#{pane_current_path}"
      bind h split-window -h -c "#{pane_current_path}"

      # panes
      set -g pane-border-style bg=default,fg=colour8
      set -g pane-active-border-style bg=default,fg=colour7

      # statusbar
      set -g status-position bottom
      set -g status-justify left
      set -g status-style 'bg=colour235 fg=colour137 dim'
      set -g status-left ""
      set -g status-right ""

      setw -g window-status-current-style 'fg=colour46 bg=colour237 bold'
      setw -g window-status-current-format ' #I#[fg=colour249]:#[fg=colour255]#W#[fg=colour249]#F '

      setw -g window-status-style 'fg=colour9 bg=colour235'
      setw -g window-status-format ' #I#[fg=colour237]:#[fg=colour250]#W#[fg=colour244]#F '

      # messages
      set -g message-style 'fg=colour232 bg=colour3 bold'
    '';
    # plugins = with pkgs;[
    #   {
    #     plugin = tmuxPlugins.resurrect;
    #     extraConfig = "set -g @resurrect-strategy-nvim 'session'";
    #   }
    # ];
  };


}
