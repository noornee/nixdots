{ lib, ... }:
{
  options.custom = {
    shell = {
      profileExtra = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = "Extra shell agnostic commands that should be run when initializing a login shell.";
      };
    };
    wallpaper = {
      swaybg = {
        enable = lib.mkEnableOption "swaybg";
        startupScript = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "set wallpaper with swaybg on startup";
        };
      };
    };
  };
}
