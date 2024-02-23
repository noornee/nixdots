{ lib
, fetchFromGitHub
, buildLua
,
}:
buildLua {
  pname = "mpv-cut";
  version = "unstable-2023-11-21";

  src = fetchFromGitHub {
    owner = "familyfriendlymikey";
    repo = "mpv-cut";
    rev = "3b18f1161ffb2ff822c88cb97e099772d4b3c26d";
    hash = "sha256-c4NHJM1qeXXBz8oyGUzS9QiAzRYiNKjmArM1K0Q2Xo0=";
  };

  dontBuild = true;
  scriptPath = "main.lua";
  passthru.scriptName = "main.lua";

  meta = with lib; {
    description = "An mpv plugin for cutting videos incredibly quickly";
    homepage = "https://github.com/familyfriendlymikey/mpv-cut";
    license = licenses.unfree; # FIXME: nix-init did not found a license
    maintainers = with maintainers; [ ];
    mainProgram = "mpv-cut";
    platforms = platforms.all;
  };
}
