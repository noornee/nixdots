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
        pull = { rebase = true; };
        merge = { conflictstyle = "diff3"; };

        # reuse record resolution: git automatically resolves conflicts using the recorded resolution
        # https://git-scm.com/book/en/v2/Git-Tools-Rerere
        rerere = {
          enabled = true;
          # autoUpdate = true;
        };

        alias = {
          lg =
            "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)'";
          ddiff = "-c diff.external=difft diff";
          dshow = "-c diff.external=difft show --ext-diff";
        };
      };

    };
    lazygit.enable = true;
  };

  home.packages = with pkgs; [ difftastic ];

}
