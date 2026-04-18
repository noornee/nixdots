{ pkgs, ... }:
let
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  xdg.configFile."kitty/colors/gruvbox.conf".source = ./colors/gruvbox.conf;
  programs.kitty = {
    enable = true;
    font.name = if isDarwin then "Iosevka Nerd Font Mono" else "Iosevka Nerd Font";
    font.size = if isDarwin then 16 else 13.5;

    settings = {
      confirm_os_window_close = 0;
      cursor_blink_interval = 0;
      cursor_shape = "block";
      shell_integration = "no-cursor";
      copy_on_select = "clipboard";
      scrollback_lines = 10000;
      enable_audio_bell = "no";
      selection_foreground = "#E7EBF1";
      selection_background = "#333A4C";
      macos_option_as_alt = if isDarwin then "both" else "";
    };

    extraConfig = ''
      include colors/gruvbox.conf
    '';
  };

  home.packages = with pkgs; [ kitty ];
}
