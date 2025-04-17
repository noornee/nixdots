{ pkgs, ... }:
let
  keybinds = import ./keybinds.nix { };
  layouts = import ./layouts.nix { inherit pkgs; };
in {

  xdg.configFile."zellij/layouts/zjstatus.kdl".text = ''
    ${layouts.zjstatus}
  '';

  xdg.configFile."zellij/config.kdl".text = # kdl
    ''
      ${keybinds.zellij-keybinds}

      plugins {
      	session-manager location="zellij:session-manager"
      }

      themes {
      	gruvbox {
      		fg 		"#f8f8f2"
      		bg      "#1A1A1D"
      		red		"#cc241d"
      		black   "#282828"
      		green	"#98971a"
      		yellow	"#d79921"
      		blue	"#33a598"
      		magenta	"#b16286"
      		cyan	"#689d6a"
      		white	"#a89984"
      		orange  "#D65D0E"
      	}
      }

      theme "gruvbox"
      default_layout "zjstatus"
      mouse_mode false
      simplified_ui true
      pane_frames false
      show_startup_tips false
    '';

  programs.zellij = { enable = true; };
}
