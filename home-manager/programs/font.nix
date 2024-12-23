{ pkgs, ... }:

{
  home.packages = with pkgs; [
    corefonts
    noto-fonts
    noto-fonts-cjk-sans
    nerd-fonts.iosevka
    nerd-fonts.jetbrains-mono
  ];

  fonts.fontconfig.enable = true;
}
