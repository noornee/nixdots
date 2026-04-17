{ pkgs, ... }: {

  home.packages = with pkgs; [ fastfetch ];
  programs.zsh.shellAliases = { neofetch = "fastfetch"; };

  xdg.configFile."fastfetch/config.jsonc".text = # jsonc
    ''
      {
      	"$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",

      	"modules": [
      	  "title",
      	  "separator",

      	  { "type": "os",       "key": "  OS ",   "keyColor": "blue" },
      	  { "type": "kernel",   "key": "  VER",  "keyColor": "green" },
      	  { "type": "uptime",   "key": "  UP ",   "keyColor": "yellow" },
      	  { "type": "packages", "key": "  PKG",  "keyColor": "blue" },

      	  "break",

      	  { "type": "wm",       "key": " WM  ",   "keyColor": "blue" },
      	  { "type": "terminal", "key": " TER ",  "keyColor": "red" },
      	  { "type": "shell",    "key": "󱆃 SH  ",   "keyColor": "green" },

      	  "break",

      	  { "type": "cpu",      "key": "  CPU",  "keyColor": "magenta" },
      	  // { "type": "gpu",      "key": "  GPU",  "keyColor": "cyan" },
      	  { "type": "memory",   "key": "  RAM",  "keyColor": "white" },

      	  "break",

      	  { "type": "disk", "key": "  Disk", "keyColor": "cyan", "format": "({mountpoint}) {size-used} / {size-total} ({size-percentage})"},

      	  "break",

      	  "colors"
      	],

      	"memory": {
      	  "unit": "GiB"
      	},

      	"os": {
      	  "distroShorthand": true
      	}
      }
    '';
}
