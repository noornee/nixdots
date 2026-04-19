{ pkgs, ... }:
let
  vidthumb = pkgs.writeShellScriptBin "vidthumb" ''
    #!/usr/bin/env bash
    #https://github.com/gokcehan/lf/wiki/Previews#with-kitty-and-pistol
    #https://raw.githubusercontent.com/duganchen/kitty-pistol-previewer/main/vidthumb

    if ! [ -f "$1" ]; then
    	exit 1
    fi

    cache="$HOME/.cache/vidthumb"
    index="$cache/index.json"
    movie="$(realpath "$1")"

    mkdir -p "$cache"

    if [ -f "$index" ]; then
    	thumbnail="$(jq -r ". \"$movie\"" <"$index")"
    	if [[ "$thumbnail" != "null" ]]; then
    		if [[ ! -f "$cache/$thumbnail" ]]; then
    			exit 1
    		fi
    		echo "$cache/$thumbnail"
    		exit 0
    	fi
    fi

    thumbnail="$(uuidgen).jpg"

    if ! ${pkgs.ffmpegthumbnailer}/bin/ffmpegthumbnailer -i "$movie" -o "$cache/$thumbnail" -s 0 2>/dev/null; then
    	exit 1
    fi

    if [[ ! -f "$index" ]]; then
    	echo "{\"$movie\": \"$thumbnail\"}" >"$index"
    fi
    json="$(jq -r --arg "$movie" "$thumbnail" ". + {\"$movie\": \"$thumbnail\"}" <"$index")"
    echo "$json" >"$index"

    echo "$cache/$thumbnail"
  '';
  rotdir = pkgs.writeShellScriptBin "rotdir" ''
    #!/usr/bin/env sh
    # https://raw.githubusercontent.com/LukeSmithxyz/voidrice/master/.local/bin/rotdir

    # When I open an image from the file manager in nsxiv (the image viewer), I want
    # to be able to press the next/previous keys to key through the rest of the
    # images in the same directory. This script "rotates" the content of a
    # directory based on the first chosen file, so that if I open the 15th image,
    # if I press next, it will go to the 16th etc. Autistic, I know, but this is
    # one of the reasons that nsxiv is great for being able to read standard input.

    [ -z "$1" ] && echo "usage: rotdir regex 2>&1" && exit 1
    base="$(basename "$1")"
    ls "$PWD" | awk -v BASE="$base" 'BEGIN { lines = ""; m = 0; } { if ($0 == BASE) { m = 1; } } { if (!m) { if (lines) { lines = lines"\n"; } lines = lines""$0; } else { print $0; } } END { print lines; }'
  '';
  lfcd = pkgs.writeShellScriptBin "lfcd.sh" ''
    function lfcd () {
    	# `command` is needed in case `lfcd` is aliased to `lf`
    	cd "$(command lf -print-last-dir "$@")"
    }
  '';
in
{
  home.packages = [
    vidthumb
    rotdir
    lfcd
  ];
}
