{
  description = "noornee's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-colors.url = "github:misterio77/nix-colors";
    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";
    zjstatus.url = "github:dj95/zjstatus";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      # ---- system settings ---- #
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # ---- user settings ---- #
      userSettings = {
        username = "noornee";
        email = "noornee.011@gmail.com";
      };
    in {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ ./nixos/configuration.nix ];
          specialArgs = {
            # pass config variables from above
            inherit userSettings;
            inherit inputs;
          };
        };
      };

      homeConfigurations = {
        noornee = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home-manager/home.nix ];
          extraSpecialArgs = {
            # pass config variables from above
            inherit inputs;
            inherit userSettings;
          };
        };
      };
    };
}
