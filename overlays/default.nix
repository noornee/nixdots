{ inputs, ... }: {
  nixpkgs.overlays = [
    (_: prev: { zjstatus = inputs.zjstatus.packages.${prev.system}.default; })
  ];

}
