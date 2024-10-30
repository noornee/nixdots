{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    (nerdfonts.override { fonts = [ "Iosevka" "JetBrainsMono" ]; })
    corefonts # Times New Roman is amongst this
  ];

  fonts.fontconfig.enable = true;
}
