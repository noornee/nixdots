# cmd-notify, macOS part: aerospace + terminal-notifier
# Success = silent, failure = "Basso" sound. Plain-text body.
# Plain kitty: all kitty windows are one process, so we ask kitty itself (remote
# control, see terminal/kitty) which OS window holds $KITTY_WINDOW_ID.

# $reply = platform window id of the kitty OS window holding this shell
#   (that's aerospace's window-id), or empty
_cmd_notify_kitty_os_window() {
  reply=()
  [[ -n $KITTY_WINDOW_ID && -n $KITTY_LISTEN_ON ]] || return
  reply=(${(f)"$(kitty @ ls --match id:$KITTY_WINDOW_ID 2>/dev/null |
    jq -r '.[].platform_window_id // empty' 2>/dev/null)"})
}

# $reply = kitty windows showing this shell, as "workspace<TAB>window-id<TAB>title"
#   plain kitty: the OS window holding $KITTY_WINDOW_ID
#   zellij: windows titled "<session> | ..."
_cmd_notify_windows() {
  local out
  if [[ -n $ZELLIJ ]]; then
    out=$(aerospace list-windows --all --json \
      --format '%{window-id} %{workspace} %{app-name} %{window-title}' 2>/dev/null |
      jq -r --arg s "$ZELLIJ_SESSION_NAME | " \
        '.[] | select(.["app-name"] == "kitty" and (.["window-title"] | startswith($s)))
             | "\(.workspace)\t\(.["window-id"])\t\(.["window-title"])"' 2>/dev/null)
  else
    _cmd_notify_kitty_os_window
    (( $#reply )) || return
    out=$(aerospace list-windows --all --json \
      --format '%{window-id} %{workspace} %{app-name} %{window-title}' 2>/dev/null |
      jq -r --argjson id "${reply[1]}" \
        '.[] | select(.["window-id"] == $id)
             | "\(.workspace)\t\(.["window-id"])\t\(.["window-title"])"' 2>/dev/null)
  fi
  reply=(${(f)out})
}

# are you looking at this shell? (kitty focused, and it's this shell's kitty
# window / zellij pane). aerospace only reports a focused window on the
# workspace you're viewing, so no separate workspace check is needed.
_cmd_notify_watching() {
  local -a win
  win=("${(@s:|:)$(aerospace list-windows --focused --format '%{app-name}|%{window-id}' 2>/dev/null)}")
  [[ ${win[1]} == kitty ]] || return 1

  if [[ -n $ZELLIJ ]]; then
    # the focused kitty must be one showing this session (not just any kitty)...
    _cmd_notify_windows
    local w found=0
    for w in $reply; do [[ ${${w#*$'\t'}%%$'\t'*} == ${win[2]} ]] && found=1; done
    (( found )) || return 1
    # ...and a zellij client must be focused on this pane
    [[ $(zellij action list-clients 2>/dev/null) == *" terminal_${ZELLIJ_PANE_ID} "* ]]
  elif [[ -n $TMUX ]]; then
    return 0 # tmux: a focused kitty is the best we can tell
  else
    # this shell's kitty window must be the active tab + split of the focused OS window
    [[ -n $KITTY_WINDOW_ID && -n $KITTY_LISTEN_ON ]] || return 1
    kitty @ ls --match id:$KITTY_WINDOW_ID 2>/dev/null | jq -e --argjson w "${win[2]}" \
      'any(.[]; .platform_window_id == $w
                and any(.tabs[]; .is_active and any(.windows[]; .is_active)))' >/dev/null 2>&1
  fi
}

_cmd_notify_line() { # key value [red]   (plain text, no colours)
  lines+=("${(r:7:)1} $2")
}

_cmd_notify_send() { # summary exit_code window-id
  local -a args=(-title "$1" -message "${(F)lines}")
  (( $2 != 0 )) && args+=(-sound Basso)

  # on click, a fresh /bin/sh runs this: no $PATH or zellij env, so spell it all out
  local -a click
  [[ -n $3 ]] && click+=("${(qq)commands[aerospace]} focus --window-id $3")
  if [[ -n $ZELLIJ ]]; then
    click+=("${(qq)commands[zellij]} --session ${(qq)ZELLIJ_SESSION_NAME} action focus-pane-id terminal_$ZELLIJ_PANE_ID")
  elif [[ -n $KITTY_WINDOW_ID && -n $KITTY_LISTEN_ON ]]; then
    click+=("${(qq)commands[kitty]} @ --to ${(qq)KITTY_LISTEN_ON} focus-window --match id:$KITTY_WINDOW_ID")
  fi
  (( $#click )) && args+=(-execute "${(j: ; :)click} >/dev/null 2>&1")

  terminal-notifier $args >/dev/null 2>&1 &!
}
