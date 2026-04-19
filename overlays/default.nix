{ inputs, ... }:
{
  nixpkgs.overlays = [
    (_: prev: { zjstatus = inputs.zjstatus.packages.${prev.stdenv.hostPlatform.system}.default; })
  ];

}
