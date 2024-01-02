{ config, pkgs, ... }:

{

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ls = "ls --color=auto";
      l = "ls -lFh"; #size,show type,human readable
      la = "ls -lAFh"; #long list,show almost all,show type,human readable
      ll = "ls -l"; #long list
      lsd = "ls -d .*"; #list dots
      lsdl = "ls -ld .*"; #long list dots
      grep = "grep --color=auto --exclude-dir=.git";
      diff = "diff --color -u";
      clh = "cat /dev/null > $HISTFILE && history -p && echo 'history file cleared'";
      cls = "clear";
      sdn = "shutdown now";
      hist = "history 0";
      dl = "cd $HOME/downloads";
      zshrc = "$EDITOR $ZDOTDIR/.zshrc";
      nvc = "cd $HOME/.config/nvim && nvim init.lua"; # neovim config
      lg = "lazygit";
    };
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      # {
      #          name = "zsh-colored-man-pages";
      #          src = pkgs.fetchFromGitHub {
      #            owner = "ohmyzsh";
      #            repo = "ohmyzsh";
      # 		rev = "6bc4c80c7db072a0d2d265eb3589bbe52e0d2737";
      # 		sha256 = "sha256-VJ1DM35d2fSs6CDyNFpq8fJ9gPHHG9kjgSnkX0m+3yc=";
      #          };
      # 	 file = "plugins/colored-man-pages/colored-man-pages.zsh";
      # }
    ];
    envExtra = ''
      # https://github.com/Cloudef/bemenu
      export BEMENU_OPTS="--tb "#005577" --tf "#CACACA" --hb "#005577" --hf "#CACACA" --hp 10"

                  	'';
    initExtra = ''
      if [[ -z "$DISPLAY" ]] && [[ $(tty) = /dev/tty1 ]]; then
      	exec Hyprland 2>/dev/null
      fi

      unsetopt BEEP # disables the cursed beep sound

      export XDG_PICTURES_DIR="$HOME/media/pictures"
      export LESSHISTFILE="-"
      export ZDOTDIR="$HOME/.config/zsh"
      export GOPATH="$HOME/.local/share/go"

      export CARGO_HOME="$HOME/.local/share/cargo"
      export RUSTUP_HOME="$HOME/.local/share/rustup"

      export NPM_CONFIG_CACHE="$HOME/.cache/npm/"
      if [[ -d "$HOME/.local/share/npm/" ]]; then
      	export NPM_CONFIG_PREFIX="$HOME/.local/share/npm/"
      else
      	mkdir -p "$HOME/.local/share/npm/"
      fi

      export PATH="$PATH:$HOME/.local/bin"
      export PATH="$PATH:$GOPATH/bin" # go path
      export PATH="$PATH:$CARGO_HOME/bin" # cargo path
      export PATH="$PATH:$NPM_CONFIG_PREFIX/bin" # npm path

      # create zsh directory in the cache dir
      if [[ ! -d "$HOME/.cache/zsh" ]];then
      	mkdir -p "$HOME/.cache/zsh"
      fi

      # Phone
      export istore="~/storage/shared/rsync/download" # mobile phone internal storage path
      export estore="/storage/2731-1C20/Android/data/com.termux/files" # mobile phone sdcard path

      # To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
      [[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh
      	'';
  };

}
