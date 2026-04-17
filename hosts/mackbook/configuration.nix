{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    home-manager
  ];

  programs.zsh.enable = true;
  nix.enable = false;
  system.stateVersion = 6;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
