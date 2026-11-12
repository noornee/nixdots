# Notify when a command finishes and you're not looking at it:
#   - it ran 10s or more (e.g. `nix build`), or it failed / crashed
#   - and its pane isn't in front of you (other zellij tab or pane, other workspace,
#     or kitty not focused)
# Success = normal notification, failure = critical (red, stays until dismissed).
# Clicking the notification jumps to the kitty window (and the zellij pane).
# Cost on normal commands: two tiny builtin-only hooks (~20µs). Everything else
# only runs after slow or failed commands.

zmodload zsh/datetime # $EPOCHSECONDS

_cmd_notify_threshold=10 # seconds

# gruvbox colours for the notification body (swaync renders pango markup)
_cmd_notify_label_color='#bdae93'
_cmd_notify_red='#fb4934'

_cmd_notify_preexec() {
  _cmd_notify_cmd=$1
  _cmd_notify_dir=$PWD
  _cmd_notify_start=$EPOCHSECONDS
}

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

_cmd_notify_precmd() {
  local exit_code=$? # must be first, before anything changes $?
  [[ -z $_cmd_notify_start ]] && return

  local took=$(( EPOCHSECONDS - _cmd_notify_start ))
  _cmd_notify_start=
  (( took < _cmd_notify_threshold && exit_code == 0 )) && return

  _cmd_notify_watching && return

  local dur
  if (( took >= 3600 )); then dur="$(( took / 3600 ))h $(( took % 3600 / 60 ))m"
  elif (( took >= 60 )); then dur="$(( took / 60 ))m $(( took % 60 ))s"
  else dur="${took}s"; fi

  local dir=${(D)_cmd_notify_dir} # ~ instead of /home/...

  # where it ran
  _cmd_notify_windows
  local -a wins=($reply) spaces
  local w addr= zellij=
  for w in $wins; do spaces+=(${w%%$'\t'*}); done
  spaces=(${(u)spaces}) # unique
  (( $#wins )) && addr=${${wins[1]#*$'\t'}%%$'\t'*}

  if [[ -n $ZELLIJ ]]; then
    local tab=$(zellij action list-panes --json 2>/dev/null |
      jq -r --argjson id "$ZELLIJ_PANE_ID" \
        '.[] | select(.is_plugin | not) | select(.id == $id) | .tab_name' 2>/dev/null)
    zellij="$ZELLIJ_SESSION_NAME${tab:+ › $tab}"
  fi

  # body is pango markup: escape values, keep the command to one line / 300 chars
  local cmd=${_cmd_notify_cmd//$'\n'/ ⏎ }
  (( ${#cmd} > 300 )) && cmd="${cmd[1,300]}…"
  _cmd_notify_esc() { REPLY=${1//&/&amp;}; REPLY=${REPLY//</&lt;}; REPLY=${REPLY//>/&gt;}; }

  local -a lines
  _cmd_notify_line() { # key value [color]
    _cmd_notify_esc "$2"
    local v=$REPLY
    [[ -n $3 ]] && v="<span foreground='$3'><b>$v</b></span>"
    lines+=("<span foreground='$_cmd_notify_label_color'><b>${(r:7:)1}</b></span> $v")
  }
  _cmd_notify_line "cmd:" "$cmd"
  _cmd_notify_line "dir:" "$dir"
  _cmd_notify_line "took:" "$dur"
  (( exit_code != 0 )) && _cmd_notify_line "exit:" "$exit_code" "$_cmd_notify_red"
  (( $#spaces )) && _cmd_notify_line "ws:" "${(j:, :)spaces}"
  [[ -n $zellij ]] && _cmd_notify_line "zellij:" "$zellij"

  local summary="✓ Command finished" urgency=normal
  (( exit_code != 0 )) && summary="✗ Command failed" urgency=critical

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

autoload -Uz add-zsh-hook
add-zsh-hook preexec _cmd_notify_preexec
# run before the prompt's own hooks, so $? is still the command's exit code
precmd_functions=(_cmd_notify_precmd ${precmd_functions:#_cmd_notify_precmd})
