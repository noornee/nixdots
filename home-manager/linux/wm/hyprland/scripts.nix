{ pkgs, ... }:
let
  volume = pkgs.writeShellScriptBin "volume" ''
    #!/usr/bin/env bash

    function send_notification()
    {
    	vol_level=$(pactl get-sink-volume 0 | awk '{print $5}')
    	dunstify --icon /home/noornee/.local/share/icons/volume.png \
    		--urgency=low \
    		--replace=2 \
    		--timeout=1000 \
    		--hints int:value:$vol_level \
    		"Volume: $vol_level" 

    }

    case $1 in
    	"up")
    		pactl set-sink-volume 0 +10%
    		send_notification $1;;

    	"down")
    		pactl set-sink-volume 0 -10%
    		send_notification $1;;
    esac
  '';

  brightness = pkgs.writeShellScriptBin "brightness" ''
        #!/usr/bin/env bash

        # Get brightness
        get_backlight()
        {
        	echo $(brightnessctl -m | cut -d, -f4 | sed 's/%//')
        }

        # send notification
        function send_notification()
        {
        	dunstify --icon /home/noornee/.local/share/icons/brightness.png \
        		--urgency=low \
        		--replace=1 \
        		--timeout=1000 \
        		--hints int:value:$(get_backlight) \
        		"Brightness: $(get_backlight)%" 

        }

        case $1 in
    		"up")
    			brightnessctl --quiet set 1%+
    			send_notification $1;;
    		"down")
    			current=$(get_backlight)
    			if [[ "$current" -gt 1 ]]; then
    			    brightnessctl --quiet set 1%-
    				send_notification $1
    			fi
    			;;
        esac

  '';

  grimshot = pkgs.writeShellScriptBin "grimshot" ''
    #!/usr/bin/env bash

    SCREENSHOT_DIR="$HOME/media/pictures/screenshots"
    TMP_DIR="/tmp"
    SCREENSHOT_FILENAME=$(date '+%Y%m%d_%Hh-%Mm-%Ss')_grim.png

    if [[ ! -d "$SCREENSHOT_DIR" ]]; then mkdir -p "$SCREENSHOT_DIR"; fi
    if [[ ! -d "$SCREENSHOT_DIR/annotated" ]]; then mkdir -p "$SCREENSHOT_DIR/annotated"; fi
    if [[ ! -d "$SCREENSHOT_DIR/named" ]]; then mkdir -p "$SCREENSHOT_DIR/named"; fi

    grim -g "$(slurp)" "$TMP_DIR/$SCREENSHOT_FILENAME"

    # rename screenshot
    NEW_SCREENSHOT_FILENAME=$(echo $SCREENSHOT_FILENAME | bemenu -i -p "rename:" | tr ' ' '_')

    function send_notification(){
    	action="$(
    		dunstify \
    		--icon=$1 \
    		--action="option_1, view" \
    		--action="option_2, annotate" \
    		--action="option_3, copy" \
    		"screenshot" \
    		$1
    	)"

    	case "$action" in
    	"option_1")
    		xdg-open $1 2>/dev/null
    		;;
    	"option_2")
    		${pkgs.satty}/bin/satty \
    		--filename $1 \
    		--output-filename "$SCREENSHOT_DIR/annotated/$NEW_SCREENSHOT_FILENAME"
    		;;
    	"option_3")
    	   # copy to clipboard
    	   cat $1 | wl-copy
    	esac
    }


    if [[ "$NEW_SCREENSHOT_FILENAME" == "$SCREENSHOT_FILENAME" ]]; then
    	mv "$TMP_DIR/$SCREENSHOT_FILENAME" "$SCREENSHOT_DIR"
    	send_notification "$SCREENSHOT_DIR/$SCREENSHOT_FILENAME"
    else
    	NEW_SCREENSHOT_FILENAME="$NEW_SCREENSHOT_FILENAME.png"
    	DESTINATION_PATH="$SCREENSHOT_DIR/named/$NEW_SCREENSHOT_FILENAME"
    	mv "$TMP_DIR/$SCREENSHOT_FILENAME" "$DESTINATION_PATH"
    	send_notification "$DESTINATION_PATH"
    fi
  '';

  neorg-note = pkgs.writeShellScriptBin "neorg-note" ''
    #!/usr/bin/env bash

    WIN_TITLE="neorg-note"
    NEORG_PATH="$HOME/media/documents/neorg/notes"
    DEBUG=1
    LOG_FILE="/tmp/neorg-note.log"

    log_separator() {
        if [ "$DEBUG" -eq 1 ]; then
            echo -e "\n\n==================== $(date '+%Y-%m-%d %H:%M:%S') SCRIPT RUN START ====================\n" >> "$LOG_FILE"
        fi
    }

    log_debug() {
        if [ "$DEBUG" -eq 1 ]; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] [DEBUG] $*" >> "$LOG_FILE"
        fi
    }

    function get_window_address() {
        local window_title=$1
        hyprctl clients -j | jq -r --arg title "$window_title" '.[] | select(.title == $title) | .address'
    }

    function get_window_workspace() {
        local window_address=$1
        hyprctl clients -j | jq -r --arg addr "$window_address" '.[] | select(.address == $addr) | .workspace.id'
    }

    function get_current_workspace() {
        hyprctl activeworkspace -j | jq -r '.id'
    }

    function launch_kitty() {
        kitty --title "$WIN_TITLE" --directory "$NEORG_PATH" sh -c "nvim index.norg"
    }

    log_separator

    log_debug "Starting toggle window script"
    log_debug "Getting window address for title: $WIN_TITLE"
    WIN_ADDR=$(get_window_address "$WIN_TITLE")
    log_debug "Window address found: '$WIN_ADDR'"

    CUR_WS=$(get_current_workspace)
    log_debug "Current workspace ID: $CUR_WS"

    if [ -n "$WIN_ADDR" ]; then
        WIN_WS=$(get_window_workspace "$WIN_ADDR")
        log_debug "Window workspace ID: $WIN_WS"

        if [ "$WIN_WS" == "$CUR_WS" ]; then
            log_debug "Window is on current workspace, hiding it by moving to workspace 100"
            hyprctl dispatch "hl.dsp.window.move({ workspace = 100, follow = false, window = \"address:$WIN_ADDR\" })"
        else
            log_debug "Window is on different workspace, showing window on current workspace and focusing"
            hyprctl dispatch "hl.dsp.window.move({ workspace = $CUR_WS, window = \"address:$WIN_ADDR\" })"
            hyprctl dispatch "hl.dsp.focus({ window = \"address:$WIN_ADDR\" })"
        fi
    else
        log_debug "Window not found, launching kitty terminal"
        launch_kitty
    fi

    log_debug "Toggle window script finished"
  '';

  # open clipse and paste the chosen entry into the window focused before.
  # the clipboard is emptied first: if it's still empty afterwards, clipse was
  # cancelled and the old contents are restored. terminals need ctrl+shift+v
  paste-from-history = pkgs.writeShellScriptBin "paste-from-history" ''
    #!/usr/bin/env bash
    saved=$(mktemp)
    trap 'rm -f "$saved"' EXIT
    type=$(wl-paste -l 2>/dev/null | head -1)
    [ -n "$type" ] && wl-paste -n -t "$type" > "$saved"
    wl-copy --clear

    kitty --class clipse -e clipse

    if ! wl-paste -l >/dev/null 2>&1; then # cancelled: put the old clipboard back
      [ -n "$type" ] && wl-copy -t "$type" < "$saved"
      exit 0
    fi

    sleep 0.15 # let focus return to the previous window
    case "$(hyprctl activewindow -j | jq -r '.class')" in
      kitty|foot|Alacritty|org.wezfurlong.wezterm) wtype -M ctrl -M shift v -m shift -m ctrl ;;
      *) wtype -M ctrl v -m ctrl ;;
    esac
  '';

  # make the cursor 3x bigger for a second so it's easy to spot (poor man's shake-to-find)
  find-cursor = pkgs.writeShellScriptBin "find-cursor" ''
    # one at a time: a second press while it's running does nothing
    exec 9>"''${XDG_RUNTIME_DIR:-/tmp}/find-cursor.lock"
    ${pkgs.util-linux}/bin/flock -n 9 || exit 0

    theme="''${HYPRCURSOR_THEME:-rose-pine-hyprcursor}"
    size="''${HYPRCURSOR_SIZE:-24}"

    # setcursor alone doesn't redraw the cursor until it moves, so nudge it 1px and back
    redraw() {
      pos=$(hyprctl cursorpos); x=''${pos%,*}; y=''${pos#*, }
      hyprctl eval "hl.dispatch(hl.dsp.cursor.move({ x = $((x + 1)), y = $y }))" >/dev/null
      hyprctl eval "hl.dispatch(hl.dsp.cursor.move({ x = $x, y = $y }))" >/dev/null
    }

    hyprctl setcursor "$theme" $(( size * 3 )) >/dev/null; redraw
    sleep 1
    hyprctl setcursor "$theme" "$size" >/dev/null; redraw
  '';

in
{
  home.packages = [
    find-cursor
    paste-from-history
    volume
    brightness
    grimshot
    neorg-note
    pkgs.brightnessctl
    pkgs.pulseaudio # for pactl...
  ];
}
