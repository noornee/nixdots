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
    		brightnessctl --quiet set 1%-
    		send_notification $1;;
    esac

  '';

  grimshot = pkgs.writeShellScriptBin "grimshot" ''
    #!/usr/bin/env bash

    SCREENSHOT_DIR="$HOME/media/pictures/screenshots"
    TMP_DIR="/tmp"
    SCREENSHOT_FILENAME=$(date '+%Y%m%d_%Hh-%Mm-%Ss')_grim.png

    grim -g "$(slurp)" "$TMP_DIR/$SCREENSHOT_FILENAME"

    # rename screenshot
    NEW_SCREENSHOT_FILENAME=$(echo $SCREENSHOT_FILENAME | bemenu -i -p "rename:" | tr ' ' '_')

    function send_notification(){
    	action="$(
    		dunstify \
    		--icon=$1 \
    		--action="option_1, view" \
    		--action="option_2, annotate" \
    		"screenshot" \
    		$1
    	)"

    	case "$action" in
    	"option_1")
    		xdg-open $1 2>/dev/null
    		;;
    	"option_2")
    		mkdir -p $SCREENSHOT_DIR/annotated
    		${pkgs.satty}/bin/satty \
    		--filename $1 \
    		--output-filename "$SCREENSHOT_DIR/annotated/$NEW_SCREENSHOT_FILENAME"
    		;;
    	esac
    }

    if [[ "$NEW_SCREENSHOT_FILENAME" == "$SCREENSHOT_FILENAME" ]]; then
    	mv "$TMP_DIR/$SCREENSHOT_FILENAME" "$SCREENSHOT_DIR"
    	send_notification "$SCREENSHOT_DIR/$SCREENSHOT_FILENAME"
    else
    	NEW_SCREENSHOT_FILENAME="$NEW_SCREENSHOT_FILENAME.png"
    	DESTINATION_PATH="$SCREENSHOT_DIR/$NEW_SCREENSHOT_FILENAME"
    	mv "$TMP_DIR/$SCREENSHOT_FILENAME" "$DESTINATION_PATH"
    	send_notification "$DESTINATION_PATH"
    fi
  '';
in
{
  home.packages = [
    volume
    brightness
    grimshot
    pkgs.brightnessctl
    pkgs.pulseaudio # for pactl...
  ];
}
