{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    home-manager
    neovim
  ];

  environment.variables = {
    EDITOR = "nvim";
  };

  # https://mynixos.com/nix-darwin/options
  nix = {
    enable = false;
  };
  services.openssh = {
    enable = true;
  };

  programs.zsh.enable = true;
  system.stateVersion = 6;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
