{ pkgs, userSettings, ... }:
{
  environment.systemPackages = with pkgs; [
    home-manager
    neovim
  ];

  environment.variables = {
    EDITOR = "nvim";
  };

  nix.enable = false;
  programs.zsh.enable = true;
  services.openssh.enable = true;

  # https://mynixos.com/nix-darwin/options/system
  system.defaults = {
    dock = {
      autohide = true;
      magnification = true;
      largesize = 40;
      tilesize = 35;
      mru-spaces = false;
      minimize-to-application = true;
      show-recents = false;
      show-process-indicators = true;
      orientation = "left"; # bottom, left, right
    };
  };

  system.primaryUser = userSettings.username;
  system.stateVersion = 6;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
