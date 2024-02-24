{ pkgs, ... }:
let
  ncmpcpp_songinfo = pkgs.writeShellScriptBin "ncmpcpp_songinfo" ''
    #!/usr/bin/env bash

    music_dir="$HOME/media/music/"
    previewdir="/tmp"
    filename="$(mpc --format "$music_dir"/%file% current)"
    previewname="$previewdir/$(mpc --format %album% current | base64).png"

    [ -e "$previewname" ] || ${pkgs.ffmpeg}/bin/ffmpeg -y -i "$filename" -an -vf scale=128:128 "$previewname" > /dev/null 2>&1

    ${pkgs.libnotify}/bin/notify-send -r 27072 "Now Playing" "$(mpc --format '%title% \n%artist% - %album%' current)" -i "$previewname"
  '';
in
{
  programs.ncmpcpp = {
    enable = true;
    mpdMusicDir = "~/media/music/";
    settings = {
      ncmpcpp_directory = "~/.config/ncmpcpp";
      lyrics_directory = "~/.config/ncmpcpp/lyrics";
      display_volume_level = "yes";
      user_interface = "alternative";
      song_list_format = "{$4%a - }{%t}|{$8%f$9}$R{$3(%l)$9}";
      current_item_prefix = "$(cyan)$r$b";
      current_item_suffix = "$/r$(end)$/b";
      now_playing_prefix = "$(blue)$r$b";
      now_playing_suffix = "$/r$(end)$/b";
      current_item_inactive_column_prefix = "$(magenta)$r";
      current_item_inactive_column_suffix = "$/r$(end)";
      execute_on_song_change = "ncmpcpp_songinfo"; # ncmpcpp_songinfo script
      follow_now_playing_lyrics = "yes";
    };
    bindings = [
      { key = "j"; command = "scroll_down"; }
      { key = "k"; command = "scroll_up"; }
      { key = "h"; command = "previous_column"; }
      { key = "l"; command = "next_column"; }
      { key = "J"; command = [ "select_item" "scroll_down" ]; }
      { key = "K"; command = [ "select_item" "scroll_up" ]; }
      { key = "ctrl-l"; command = "show_lyrics"; }
    ];
  };

  xdg.configFile."mpd/mpd.conf".text = ''
    music_directory		"~/media/music"
    playlist_directory	"~/.config/mpd/playlists"
    db_file				"~/.config/mpd/database"
    log_file			"~/.config/mpd/log"
    pid_file			"~/.config/mpd/pid"
    state_file			"~/.config/mpd/state"
    sticker_file		"~/.config/mpd/sticker.sql"
    auto_update			"yes"

    audio_output {
    	type		"pipewire"
    	name		"My PipeWire Output"
    }

  '';

  home.packages = [
    ncmpcpp_songinfo
    pkgs.ncmpcpp
    pkgs.mpd
    pkgs.mpc-cli
  ];
}
