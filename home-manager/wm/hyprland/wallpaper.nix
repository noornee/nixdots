{ config, pkgs, lib, ... }:
let cfg = config.custom;
in {

  home.packages = with pkgs; [ swaybg ];

  custom.wallpaper.swaybg.startupScript = ''
    #!/usr/bin/env bash
    swaybg -i "$XDG_DATA_HOME/wallpaper" -m fill
  '';

  xdg.dataFile."wallpaper" = {
    enable = cfg.wallpaper.swaybg.enable;
    source = ./assets/wallpaper.jpg;
  };

  programs.zsh.envExtra =
    lib.mkIf (config.programs.zsh.enable && cfg.wallpaper.swaybg.enable) ''
      if [[ ! -d "$HOME/.config/swaybg" ]]; then
      	SWAYBG_DIR="$HOME/.config/swaybg"
      	mkdir -p "$SWAYBG_DIR"
      content=$(cat <<EOF
      ${cfg.wallpaper.swaybg.startupScript}
      EOF
      )
      	echo -e "$content" > "$SWAYBG_DIR/swaybg"

      	# make script file executable
      	chmod +x "$SWAYBG_DIR/swaybg"
      fi
    '';
}
