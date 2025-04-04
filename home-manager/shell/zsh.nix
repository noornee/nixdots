{ config, pkgs, ... }:
let cfg = config.custom.shell;
in {
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ls = "ls --color=auto";
      l = "ls -lFh"; # size,show type,human readable
      la = "ls -lAFh"; # long list,show almost all,show type,human readable
      ll = "ls -l"; # long list
      lsd = "ls -d .*"; # list dots
      lsdl = "ls -ld .*"; # long list dots
      grep = "grep --color=auto --exclude-dir=.git";
      diff = "diff --color -u";
      clh =
        "cat /dev/null > $HISTFILE && history -p && echo 'history file cleared'";
      cls = "clear";
      sdn = "shutdown now";
      hist = "history 0";
      dl = "cd $HOME/downloads";
      pix = "cd $HOME/media/pictures/";
      vid = "cd $HOME/media/video/";
      dots = "cd $HOME/.config/dotfiles/ && nvim flake.nix";
      goenv = "cd $HOME/workspace/codenv/go";
      zshrc = "$EDITOR $ZDOTDIR/.zshrc";
      nvc = "cd $HOME/.config/nvim && nvim init.lua"; # neovim config
      lg = "lazygit";
      hms = "home-manager switch --flake ~/.config/dotfiles";
      hmso = "home-manager switch --flake ~/.config/dotfiles --no-substitute";
      le = "eza --long --group --group-directories-first --icons";
    };
    plugins = [{
      name = "powerlevel10k";
      src = pkgs.zsh-powerlevel10k;
      file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
    }];
    inherit (cfg) profileExtra;
    envExtra = # sh
      ''
        # https://github.com/Cloudef/bemenu
        export BEMENU_OPTS="--tb "#005577" --tf "#CACACA" --hb "#005577" --hf "#CACACA" --hp 10"

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
        export PATH="$PATH:$XDG_DATA_HOME/nvim/mason/bin" # nvim mason bin path

        # create zsh directory in the cache dir
        if [[ ! -d "$HOME/.cache/zsh" ]];then
        	mkdir -p "$HOME/.cache/zsh"
        fi

                    	'';
    initExtra = # sh
      ''
        # To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
        [[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

        bindkey -s '^t' 'tmux\n'
        #eval "$(direnv hook zsh)"

      '';
  };

}
