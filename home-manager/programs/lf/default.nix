{ pkgs, ... }:

{
  imports = [ ./scripts.nix ];
  xdg.configFile."lf/icons".source = ./icons;
  xdg.configFile."lf/colors".source = ./colors;

  home.packages = with pkgs; [
    poppler_utils # for pdftoppm
    pistol
    bat
    ffmpegthumbnailer
  ];

  programs.zsh = {
    shellAliases = { lf = "lfcd"; };
    initExtra = "source lfcd.sh"; # check ./scripts.nix for more deets
  };

  programs.lf = {
    enable = true;
    settings = {
      ifs = "\\n";
      icons = true;
      preview = true;
      hidden = true;
    };

    commands = {
      open = ''
        ''${{
        	case $(file --mime-type "$(readlink -f $f)" -b) in
        		text/*|application/json|inode/x-empty) $EDITOR $fx ;;
        		image/svg+xml) display -- $f ;;
        		image/*) rotdir $f | grep -i "\.\(png\|jpg\|jpeg\|gif\|webp\|tif\|ico\)\(_large\)*$" |
        			setsid -f ${pkgs.imv}/bin/imv 2>/dev/null | while read -r file; do
        				[ -z "$file" ] && continue
        				lf -remote "send select \"$file\""
        				lf -remote "send toggle"
        			done &
        			;;
        		audio/* | application/octet-stream) mpv --audio-display=no $fx ;;
        		video/*) setsid -f mpv $fx -quiet >/dev/null 2>&1 ;;
        		application/pdf|application/epub*) setsid -f zathura $fx >/dev/null 2>&1 ;;
        		application/vnd*) setsid -f libreoffice $fx >/dev/null 2>&1 ;;
        		application/javascript) $EDITOR $fx ;;
        		*) for f in $fx; do setsid $OPENER $f > /dev/null 2> /dev/null & done ;;
        	esac
        }}'';
      delete = ''
        ''${{
        	clear; tput bold setaf 1
        	set -f
        	printf "$fx\n"
        	tput sgr0; tput bold
        	printf "delete? [y/n]: "
        	read ans
        	[ $ans = "y" ] && rm -rf -- $fx
        }}'';
      mkdir = ''%mkdir -p "$@"'';
      touch = ''$touch "$(echo $* | tr ' ' '\ '| tr ' ' '_')"'';
      trash = ''
        %trash-put $fx && notify-send "Trash-Put" "moved <p>$fx</p> <br>to trash"'';
      bulkrename = ''
        ''${{
        	${pkgs.vimv}/bin/vimv -- $(basename -a -- $fx)

        	lf -remote "send $id load"
        	lf -remote "send $id unselect"
        }}
      '';
      spawn_terminal = ''
        ''${{
        	setsid -f kitty --directory $(pwd) 2>/dev/null
        }}
      '';
      remove_exec = ''
        ''${{
        	chmod -x $fx # removes executable permission from file
        }}
      '';
      add_exec = ''
        ''${{
        	chmod +x $fx
        }}
      '';
      set_wallpaper = ''
        ''${{
        # set wallpaper with swaybg
        case $(file --mime-type $f | cut -d ':' -f2 | xargs) in
        	image/*)
        		image_path=$(printf "%s" $f)
        		sed -i "2s|\".*\"|\"$image_path\"|g" "$HOME/.config/swaybg/swaybg" && setsid -f swaybg -i "$f" -m fill 2>/dev/null
        		;;
        	*) notify-send --urgency=critical --expire-time=5000 "ERROR: invalid file type/format" "\n<b>hint:</b> remove semi-colon \":\" from filename if its a valid image" ;;
        esac
        }}
      '';
      fzf_find_file = ''
        ''${{
        selected="$(rg --files * | fzf)"
        lf -remote "send $id select \"$selected\""
        }}
      '';
    };

    keybindings = {
      D = "delete";
      "<c-n>" = "push :mkdir<space>";
      "<f-2>" = "spawn_terminal";
      "<a-x>" = "add_exec";
      "<a-X>" = "remove_exec";
      "<a-f>f" = "fzf_find_file";
      W = "set_wallpaper";
      R = "bulkrename";
      a = "push :touch<space>";
      T = "trash";
      Y = "$printf %s $fx | wl-copy"; # copies absolute path to clipboard

    };

    cmdKeybindings = {
      "<c-left>" = "cmd-word-back";
      "<c-right>" = "cmd-word";
      "<up>" = "cmd-history-prev";
      "<down>" = "cmd-history-next";
    };

    extraConfig = let
      previewer = pkgs.writeShellScript "previewer.sh" ''
        file=$1
        w=$2
        h=$3
        x=$4
        y=$5
        filetype="$(file -Lb --mime-type "$file")"

        image() {
        	if [[ "$filetype" =~ ^video ]]; then
        	    # vidthumb is from here:
        	    # https://raw.githubusercontent.com/duganchen/kitty-pistol-previewer/main/vidthumb
        		kitty +kitten icat --silent --stdin no --transfer-mode file --place "''${w}x''${h}@''${x}x''${y}" "$(vidthumb "$file")" < /dev/null > /dev/tty
        	    exit 1
        	else
        		kitty +kitten icat --silent --stdin no --transfer-mode file --place "''${w}x''${h}@''${x}x''${y}" "$file" < /dev/null > /dev/tty
        		exit 1
        	fi
        }

        get_cache_path() {
        	echo "''${XDG_CACHE_HOME:-$HOME/.cache}/lf/thumb.$(stat --printf '%n\0%i\0%F\0%s\0%W\0%Y' -- "$(readlink -f "$1")" | sha256sum | cut -d' ' -f1)"
        }

        CACHE=$(get_cache_path "$1")

        case "$(file --dereference --brief --mime-type -- "$1")" in
        image/*) 
        	image "$1"
        	;;
        video/* )
        	[ ! -f "$CACHE" ] && ffmpegthumbnailer -i "$1" -o "$CACHE" -s 0
        		image "$CACHE";;
        */pdf)
        	[ ! -f "$CACHE.jpg" ] && pdftoppm -jpeg -f 1 -singlefile "$1" "$CACHE"
        		kitty +kitten icat --silent --stdin no --transfer-mode file --place "''${w}x''${h}@''${x}x''${y}" "$CACHE.jpg" < /dev/null > /dev/tty
        		exit 1
        	# 	image "$CACHE.jpg"
        	;;
        */epub+zip|*/mobi*)
        	[ ! -f "$CACHE.jpg" ] && ${pkgs.gnome-epub-thumbnailer}/bin/gnome-epub-thumbnailer "$1" "$CACHE.jpg"
        		image "$CACHE.jpg" 
        	;;
        application/javascript) #fixes issue of `init.lua` not being previewed for some reason idk
        	bat --color=always "$1"
        	;;
        *)
        	pistol "$1"
        esac'';
      cleaner = pkgs.writeShellScript "cleaner.sh"
        "kitty +kitten icat --clear --stdin no --silent --transfer-mode file < /dev/null > /dev/tty";
    in ''
      set previewer ${previewer}
      set cleaner ${cleaner}

      setlocal ~ hidden false # hide hidden files in the home directory
      map zh setlocal ~ hidden!
    '';
  };

  # pistol -> https://github.com/doronbehar/pistol
  home.file.".config/pistol/pistol.conf".text = ''
    text/* bat --paging=never --color=always %pistol-filename%
  '';
}
