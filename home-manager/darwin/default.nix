{
  userSettings,
  inputs,
  pkgs,
  config,
  ...
}:

{
  # Import the modules
  imports = [
    inputs.nix-colors.homeManagerModule
    ../common/options.nix
    ../common/terminal/kitty
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
    terminal-notifier # cmd-notify (common/shell/cmd-notify-darwin.zsh)
  ];

  services.colima = {
    enable = true;
    package = pkgs.colima;

    colimaHomeDir = "${config.xdg.configHome}/colima";
    # limaHomeDir = "${config.xdg.dataHome}/colima/lima";
    limaHomeDir = "${config.xdg.configHome}/colima/_lima";

    profiles.default = {
      isActive = true;
      isService = true;
      setDockerHost = true;
      mutableSettings = true;

      settings = {
        cpu = 4;
        memory = 8;
        disk = 200;
        vmType = "vz";
        runtime = "docker";
      };
    };
  };

  colorScheme = inputs.nix-colors.colorSchemes.gruvbox-dark-hard;

  home.username = userSettings.username;
  home.homeDirectory = "/Users/${userSettings.username}";

  home.stateVersion = "26.05";
  programs.home-manager.enable = true;
}
