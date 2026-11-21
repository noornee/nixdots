{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.custom.shell;
in
{
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    history = {
      path = "${config.xdg.configHome}/zsh/zsh_history";
      size = 50000;
      ignoreAllDups = true; # keep only the latest copy of a repeated command
      extended = true; # save timestamps
      # share (across terminals) and ignoreSpace (" cmd" isn't saved) are on by default
    };
    # type the start of a command, then up/down steps through matching history
    historySubstringSearch = {
      enable = true;
      searchUpKey = [
        "^[[A"
        "^[OA"
      ];
      searchDownKey = [
        "^[[B"
        "^[OB"
      ];
    };
    autosuggestion.enable = true;
    syntaxHighlighting = {
      enable = true;
      # default comment style (fg=black,bold) is nearly invisible on dark themes
      styles.comment = "fg=245";
    };
    shellAliases = {
      ls = "ls --color=auto";
      l = "ls -lFh"; # size,show type,human readable
      la = "ls -lAFh"; # long list,show almost all,show type,human readable
      ll = "ls -l"; # long list
      lsd = "ls -d .*"; # list dots
      lsdl = "ls -ld .*"; # long list dots
      grep = "grep --color=auto --exclude-dir=.git";
      diff = "diff --color -u";
      clh = "cat /dev/null > $HISTFILE && history -p && echo 'history file cleared'";
      cls = "clear";
      sdn = "shutdown now";
      hist = "history 0";
      dl = if pkgs.stdenv.hostPlatform.isDarwin then "cd ~/Downloads" else "cd ~/media/downloads";
      pix = "cd ~/media/pictures/";
      vid = "cd ~/media/video/";
      dots = "cd $HOME/.config/dotfiles/ && nvim flake.nix";
      goenv = "cd $HOME/workspace/codenv/go";
      zshrc = "$EDITOR $ZDOTDIR/.zshrc";
      nvc = "cd $HOME/.config/nvim && nvim init.lua"; # neovim config
      lg = "lazygit";
      hms = "home-manager switch --flake ~/.config/dotfiles";
      hmso = "home-manager switch --flake ~/.config/dotfiles --no-substitute";
      le = "eza --long --group --group-directories-first --icons";
      nsh = "nix-shell  --command zsh";
    };
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];
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
    initContent = ''
      # To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
      [[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

      # allow comments (#) in interactive shell
      setopt interactive_comments

      # enable vim keybinding
      bindkey -v

      # normal mode: v/e edit the command in $EDITOR, k/j search history like up/down
      autoload -Uz edit-command-line
      zle -N edit-command-line
      bindkey -M vicmd 'v' edit-command-line
      bindkey -M vicmd 'e' edit-command-line # replaces end-of-word (E still works)
      # in a multi-line command k/j move between lines; history search only kicks in on the
      # first/last line (otherwise k searches for the whole buffer and highlights it red)
      _vi-up-line-or-substring-search() { zle up-line || zle history-substring-search-up }
      _vi-down-line-or-substring-search() { zle down-line || zle history-substring-search-down }
      zle -N _vi-up-line-or-substring-search
      zle -N _vi-down-line-or-substring-search
      bindkey -M vicmd 'k' _vi-up-line-or-substring-search
      bindkey -M vicmd 'j' _vi-down-line-or-substring-search

      # tmux shortcut
      bindkey -s '^t' 'tmux\n'

      # cmd+t (kitty sends F12) in a plain shell: attach to the "side" tmux session, or create it.
      # inside tmux/zellij they handle F12 themselves; the guard covers zellij's locked mode
      _cmd-t-side-tmux() {
        [[ -n $TMUX || -n $ZELLIJ ]] && return
        (( $+commands[tmux] )) || return # no tmux installed: do nothing
        BUFFER=" tmux new -A -s side" # leading space: kept out of history
        zle accept-line
      }
      zle -N _cmd-t-side-tmux
      bindkey -M viins '^[[24~' _cmd-t-side-tmux
      bindkey -M vicmd '^[[24~' _cmd-t-side-tmux

      # notify when a long or failed command finishes while you're not looking
      ${builtins.readFile ./cmd-notify.zsh}
      ${builtins.readFile (
        if pkgs.stdenv.hostPlatform.isDarwin then ./cmd-notify-darwin.zsh else ./cmd-notify-linux.zsh
      )}

      # Homebrew (macOS only)
      ${lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
        # after a reboot the agent is empty: load keys whose passphrases are saved in the
        # Keychain (ssh-add --apple-use-keychain) so commit signing never needs a prompt
        ssh-add -l >/dev/null 2>&1 || /usr/bin/ssh-add --apple-load-keychain -q 2>/dev/null

        if [ -x /opt/homebrew/bin/brew ]; then
          eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [ -x /usr/local/bin/brew ]; then
          eval "$(/usr/local/bin/brew shellenv)"
        fi
      ''}
    '';
  };

  # ctrl+r: fuzzy history search, alt+c: cd into a folder (ctrl+t stays the tmux shortcut above)
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # nix-direnv caches `use flake` / `use nix`, so entering a project is instant
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
