{ pkgs, ... }: {
  home.packages = with pkgs; [
    imv
    nsxiv # sxiv replacement
  ];

  # https://git.sr.ht/~exec64/imv
  home.file.".config/imv/config".text = ''
    [binds]
    n = next
    p = prev
  '';
}
