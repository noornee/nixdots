# cmd-notify, linux part: hyprland + notify-send (swaync)
# Success = normal notification, failure = critical (red, stays until dismissed).

# gruvbox colours for the notification body (swaync renders pango markup)
_cmd_notify_label_color='#bdae93'
_cmd_notify_red='#fb4934'

# $reply = pids from this shell up to init
_cmd_notify_ancestors() {
  reply=()
  local pid=$$ stat
  while (( pid > 1 )); do
    reply+=($pid)
    stat=$(</proc/$pid/stat) 2>/dev/null || return
    pid=${${(s: :)${stat##*) }}[2]} # ppid: 2nd field after "(comm) "
  done
}

# $reply = kitty windows showing this shell, as "workspace<TAB>address<TAB>title"
#   plain kitty: the window whose process is one of our ancestors
#   zellij: windows titled "<session> | ..." (zellij's servers aren't children of kitty)
_cmd_notify_windows() {
  local clients=$(hyprctl -j clients 2>/dev/null) out
  if [[ -n $ZELLIJ ]]; then
    out=$(jq -r --arg s "$ZELLIJ_SESSION_NAME | " \
      '.[] | select(.class == "kitty" and (.title | startswith($s)))
           | "\(.workspace.name)\t\(.address)\t\(.title)"' <<<$clients 2>/dev/null)
  else
    _cmd_notify_ancestors
    out=$(jq -r --argjson pids "[${(j:,:)reply}]" \
      '.[] | select(.class == "kitty" and (.pid as $p | $pids | index($p)))
           | "\(.workspace.name)\t\(.address)\t\(.title)"' <<<$clients 2>/dev/null)
  fi
  reply=(${(f)out})
}

# are you looking at this shell? (kitty focused, on the workspace you're viewing,
# and in zellij: a client focused on this pane)
_cmd_notify_watching() {
  local -a win
  # on an empty workspace hyprland still reports the last focused window,
  # so also check it's on the workspace you're viewing
  win=("${(@f)$(hyprctl -j activewindow 2>/dev/null | jq -r '.class // "", .pid // 0, .workspace.id // 0, .address // ""')}")
  local ws=$(hyprctl -j activeworkspace 2>/dev/null | jq -r '.id // -1')
  [[ ${win[1]} == kitty && ${win[3]} == $ws ]] || return 1

  if [[ -n $ZELLIJ ]]; then
    # the focused kitty must be one showing this session (not just any kitty)...
    _cmd_notify_windows
    local w found=0
    for w in $reply; do [[ ${${w#*$'\t'}%%$'\t'*} == ${win[4]} ]] && found=1; done
    (( found )) || return 1
    # ...and a zellij client must be focused on this pane
    [[ $(zellij action list-clients 2>/dev/null) == *" terminal_${ZELLIJ_PANE_ID} "* ]]
  elif [[ -n $TMUX ]]; then
    return 0 # tmux: a focused kitty is the best we can tell
  else
    _cmd_notify_ancestors
    (( ${reply[(Ie)${win[2]}]} ))
  fi
}

# body is pango markup: escape values
_cmd_notify_esc() { REPLY=${1//&/&amp;}; REPLY=${REPLY//</&lt;}; REPLY=${REPLY//>/&gt;}; }

_cmd_notify_line() { # key value [red]
  _cmd_notify_esc "$2"
  local v=$REPLY
  [[ -n $3 ]] && v="<span foreground='$_cmd_notify_red'><b>$v</b></span>"
  lines+=("<span foreground='$_cmd_notify_label_color'><b>${(r:7:)1}</b></span> $v")
}

_cmd_notify_send() { # summary exit_code address
  local summary=$1 urgency=normal addr=$3
  (( $2 != 0 )) && urgency=critical

  # in the background: wait for a click, then jump to the window (and zellij pane)
  local pane=${ZELLIJ:+terminal_$ZELLIJ_PANE_ID}
  {
    local action=$(notify-send --app-name=terminal --urgency=$urgency \
      --action="default=Go to window" "$summary" "${(F)lines}")
    [[ $action == default ]] || return
    [[ -n $addr ]] && hyprctl eval "hl.dispatch(hl.dsp.focus({ window = \"address:$addr\" }))" >/dev/null
    [[ -n $pane ]] && zellij action focus-pane-id "$pane" >/dev/null 2>&1
  } &!
}
