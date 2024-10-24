{ config, pkgs, ... }: {
  xdg.configFile."kitty/colors/gruvbox.conf".source = ./colors/gruvbox.conf;

  programs.kitty = {
    enable = true;
    font.name = "Iosevka Nerd Font";
    font.size = 13.5;
    settings = {
      confirm_os_window_close = 0;
      cursor_blink_interval = 0;
      cursor_shape = "block";
      shell_integration =
        "no-cursor"; # https://github.com/kovidgoyal/kitty/issues/4458
      copy_on_select = "clipboard";
      scrollback_lines = 10000;
      enable_audio_bell = "no";
      selection_foreground = "#E7EBF1";
      selection_background = "#333A4C";
    };
    extraConfig = ''
      include colors/gruvbox.conf
    '';
  };

  home.packages = with pkgs; [ kitty ];

}
