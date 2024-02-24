{ pkgs, ... }:
{
  programs.chromium = {
    enable = true;
    package = pkgs.brave;
    extensions = [
      # Dark Reader
      { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; }
      # Vimium
      { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; }
      # Json Viewer
      { id = "gbmdgpbipfallnflgajpaliibnhdgobh"; }
    ];
  };

}
