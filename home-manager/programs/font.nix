{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    noto-fonts-cjk-sans
    (nerdfonts.override { fonts = [ "Iosevka" "JetBrainsMono" ]; })
  ];

  fonts.fontconfig.enable = true;
}
