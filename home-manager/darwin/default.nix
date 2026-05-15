{
  userSettings,
  inputs,
  pkgs,
  ...
}:

{
  # Import the modules
  imports = [
    inputs.nix-colors.homeManagerModule
    ../common/options.nix
    ../common/terminal/kitty
    ../common/programs/zathura.nix
    ../common/shell/zsh.nix
    ../common/programs
    ../../overlays
    ./wm/aerospace
  ];

  home.packages = with pkgs; [
    sketchybar
    jankyborders
    fontconfig
    docker
    colima
    util-linux
    wget
  ];

  launchd.agents.colima = {
    enable = true;

    config = {
      ProgramArguments = [
        "${pkgs.colima}/bin/colima"
        "start"
        "--foreground"
      ];

      EnvironmentVariables = {
        PATH = "${pkgs.docker}/bin:${pkgs.colima}/bin:${pkgs.coreutils}/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      };

      RunAtLoad = true;
      KeepAlive = true;

      StandardOutPath = "/tmp/colima.out.log";
      StandardErrorPath = "/tmp/colima.err.log";
    };
  };

  colorScheme = inputs.nix-colors.colorSchemes.gruvbox-dark-hard;

  home.username = userSettings.username;
  home.homeDirectory = "/Users/${userSettings.username}";

  home.stateVersion = "26.05";
  programs.home-manager.enable = true;
}
