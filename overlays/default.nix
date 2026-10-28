{ inputs, ... }:
{
  nixpkgs.overlays = [
    (
      _: prev:
      let
        master = inputs.nixpkgs-go.legacyPackages.${prev.stdenv.hostPlatform.system};
        # Use whichever nixpkgs has the newer Go: nixos-unstable (binary-cached, so
        # fast) or master (gets new Go releases first, but may compile locally).
        goPkgs =
          if prev.lib.versionOlder prev.go_latest.version master.go_latest.version then master else prev;
      in
      {
        zjstatus = inputs.zjstatus.packages.${prev.stdenv.hostPlatform.system}.default;

        go = goPkgs.go_latest;

        gopls = goPkgs.gopls;
        govulncheck = goPkgs.govulncheck;
        golangci-lint = goPkgs.golangci-lint; # may lag a release: nixpkgs waits until golangci-lint supports the new Go
      }
    )
  ];

}
