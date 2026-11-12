# Notify when a command finishes and you're not looking at it:
#   - it ran 10s or more (e.g. `nix build`), or it failed / crashed
#   - and its pane isn't in front of you (other zellij tab or pane, other workspace,
#     or kitty not focused)
# Clicking the notification jumps to the kitty window (and the zellij pane).
# Cost on normal commands: two tiny builtin-only hooks (~20µs). Everything else
# only runs after slow or failed commands.
#
# This file is the shared part. The OS file (cmd-notify-linux.zsh / -darwin.zsh)
# provides:
#   _cmd_notify_watching          are you looking at this shell? (status)
#   _cmd_notify_windows           $reply = windows showing this shell, "workspace<TAB>id<TAB>title"
#   _cmd_notify_line key value [color]   append a body line to $lines
#   _cmd_notify_send summary exit_code window_id   send it (in the background)

zmodload zsh/datetime # $EPOCHSECONDS

_cmd_notify_threshold=10 # seconds

_cmd_notify_preexec() {
  _cmd_notify_cmd=$1
  _cmd_notify_dir=$PWD
  _cmd_notify_start=$EPOCHSECONDS
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
  local w id= zellij=
  for w in $wins; do spaces+=(${w%%$'\t'*}); done
  spaces=(${(u)spaces}) # unique
  (( $#wins )) && id=${${wins[1]#*$'\t'}%%$'\t'*}

  if [[ -n $ZELLIJ ]]; then
    local tab=$(zellij action list-panes --json 2>/dev/null |
      jq -r --argjson id "$ZELLIJ_PANE_ID" \
        '.[] | select(.is_plugin | not) | select(.id == $id) | .tab_name' 2>/dev/null)
    zellij="$ZELLIJ_SESSION_NAME${tab:+ › $tab}"
  fi

  # keep the command to one line / 300 chars
  local cmd=${_cmd_notify_cmd//$'\n'/ ⏎ }
  (( ${#cmd} > 300 )) && cmd="${cmd[1,300]}…"

  local -a lines # filled by _cmd_notify_line
  _cmd_notify_line "cmd:" "$cmd"
  _cmd_notify_line "dir:" "$dir"
  _cmd_notify_line "took:" "$dur"
  (( exit_code != 0 )) && _cmd_notify_line "exit:" "$exit_code" red
  (( $#spaces )) && _cmd_notify_line "ws:" "${(j:, :)spaces}"
  [[ -n $zellij ]] && _cmd_notify_line "zellij:" "$zellij"

  local summary="✓ Command finished"
  (( exit_code != 0 )) && summary="✗ Command failed"

  _cmd_notify_send "$summary" $exit_code "$id"
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec _cmd_notify_preexec
# run before the prompt's own hooks, so $? is still the command's exit code
precmd_functions=(_cmd_notify_precmd ${precmd_functions:#_cmd_notify_precmd})
