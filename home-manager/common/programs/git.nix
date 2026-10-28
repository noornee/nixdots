{ pkgs, userSettings, ... }: {
  programs = {
    git = {
      enable = true;
      settings = {
        user = {
          name = userSettings.username;
          email = userSettings.email;
        };
        init.defaultBranch = "main";
        pull = {
          rebase = true;
        };
        rebase.autoStash = true; # pull works with uncommitted changes
        push.autoSetupRemote = true; # first push of a new branch sets its upstream
        fetch.prune = true; # drop refs to branches deleted on the remote
        merge = {
          conflictstyle = "zdiff3"; # diff3, minus lines both sides share
        };
        diff.algorithm = "histogram"; # cleaner diffs when code moves around
        branch.sort = "-committerdate"; # recent branches first

        # reuse record resolution: git automatically resolves conflicts using the recorded resolution
        # https://git-scm.com/book/en/v2/Git-Tools-Rerere
        rerere = {
          enabled = true;
          # autoUpdate = true;
        };

        # Use SSH instead of HTTPS for GitHub
        url."git@github.com:".insteadOf = "https://github.com/";

        alias = {
          lg = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)'";
          ddiff = "-c diff.external=difft diff";
          dshow = "-c diff.external=difft show --ext-diff";
        };
      };
    };

    lazygit = {
      enable = true;
      settings = {
        git.diffRenderers = [
          {
            type = "extDiff";
            command = "difft --color=always";
          }
        ];
        gui = {
          sidePanelWidth = 0.28; # default is a third; leaves more room for side-by-side diffs
          expandFocusedSidePanel = true; # the focused left panel grows taller
          nerdFontsVersion = "3"; # file/folder icons
        };
      };
    };
  };

  home.packages = with pkgs; [ difftastic ];
}
