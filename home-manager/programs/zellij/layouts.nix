{ pkgs, ... }: {
  zjstatus = # kdl
    ''
      layout {
          default_tab_template {
              children
              pane size=1 borderless=true {
                  plugin location="file://${pkgs.zjstatus}/bin/zjstatus.wasm" {

      				format_space  ""
      				format_left   "#[fg=#33a598,bold]({session}) {tabs}"
      				format_right "{mode}"
      				//format_center "{tabs}"

      				color_cyan	"#689d6a"
      				color_red	"#cc241d"
      				color_white	"#C6C6C6"
      				color_black "#282828"


      				//tab_active   "#[fg=#98971a,bold]{name} "
      				//tab_normal   "#[fg=#a89984]{name} "
      				tab_active   "#[bg=$black,fg=$cyan,bold] {index}:#[bg=$black,fg=#a89984]{name} "
      				tab_normal   "#[fg=$red] {index}:#[fg=#a89984]{name} "

      				hide_frame_for_single_pane "false"

      				mode_normal        "#[bg=#8ec07c,fg=#282828,bold] NORMAL#[bg=#282828,fg=#8ec07c]█"
      				mode_locked        "#[bg=#fb4934,fg=#282828,bold] LOCKED #[bg=#282828,fg=#fb4934]█"
      				mode_resize        "#[bg=#7c6f64,fg=#282828,bold] RESIZE#[bg=#282828,fg=#7c6f64]█"
      				mode_pane          "#[bg=#83a598,fg=#282828,bold] PANE#[bg=#282828,fg=#83a598]█"
      				mode_tab           "#[bg=#d3869b,fg=#282828,bold] TAB#[bg=#282828,fg=#d3869b]█"
      				mode_scroll        "#[bg=#fabd2f,fg=#282828,bold] SCROLL#[bg=#282828,fg=#fabd2f]█"
      				mode_enter_search  "#[bg=#458588,fg=#282828,bold] ENT-SEARCH#[bg=#282828,fg=#458588]█"
      				mode_search        "#[bg=#458588,fg=#282828,bold] SEARCH#[bg=#282828,fg=#458588]█"
      				mode_rename_tab    "#[bg=#d3869b,fg=#282828,bold] RENAME-TAB#[bg=#282828,fg=#d3869b]█"
      				mode_rename_pane   "#[bg=#83a598,fg=#282828,bold] RENAME-PANE#[bg=#282828,fg=#83a598]█"
      				mode_session       "#[bg=#8ec07c,fg=#282828,bold] SESSION#[bg=#282828,fg=#8ec07c]█"
      				mode_move          "#[bg=#d3869b,fg=#282828,bold] MOVE#[bg=#282828,fg=#d3869b]█"
      				mode_prompt        "#[bg=#458588,fg=#282828,bold] PROMPT#[bg=#282828,fg=#458588]█"
      				mode_tmux          "#[bg=#fabd2f,fg=#282828,bold] TMUX#[bg=#282828,fg=#fabd2f]█"
                  }
              }
          }
      }
    '';
}
