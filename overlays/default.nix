{ inputs, ... }:
{
  nixpkgs.overlays = [
    (_: prev: {
      zjstatus = inputs.zjstatus.packages.${prev.stdenv.hostPlatform.system}.default;
      go = inputs.nixpkgs-go.legacyPackages.${prev.stdenv.hostPlatform.system}.go_1_27;
    })
  ];

}
