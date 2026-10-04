{
  config,
  pkgs,
  lib,
  ...
}:
let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  xdg.configFile."kitty/colors/gruvbox.conf".source = ./colors/gruvbox.conf;

  # --single-instance: reuse the running kitty, so only one dock icon shows. replaces
  #   macos_hide_from_tasks, which made aerospace open kitty on the wrong workspace sometimes
  xdg.configFile."kitty/macos-launch-services-cmdline" = lib.mkIf isDarwin {
    text = "--single-instance --directory ${config.home.homeDirectory}";
  };
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
      # macos_hide_from_tasks = if isDarwin then "yes" else "";
      background_opacity = if isDarwin then 0.95 else "";
    };

    extraConfig = ''
      include colors/gruvbox.conf
    '';
  };

  home.packages = with pkgs; [ kitty ];
}
