{
  description = "noornee's cross-platform nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-colors.url = "github:misterio77/nix-colors";
    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";
    zjstatus.url = "github:dj95/zjstatus";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      nix-darwin,
      ...
    }:
    let
      userSettings = {
        username = "noornee";
        email = "noornee.011@gmail.com";
      };

      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
    in
    {
      nixosConfigurations.thinkpad = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/thinkpad/configuration.nix ];
        specialArgs = { inherit userSettings inputs; };
      };

      darwinConfigurations.macbook = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [ ./hosts/macbook/configuration.nix ];
        specialArgs = { inherit userSettings inputs; };
      };

      homeConfigurations = {
        "noornee@thinkpad" = home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs "x86_64-linux";
          modules = [ ./home-manager/home.nix ];
          extraSpecialArgs = {
            hostname = "thinkpad";
            inherit userSettings inputs;
          };
        };

        "noornee@macbook" = home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs "aarch64-darwin";
          modules = [ ./home-manager/home.nix ];
          extraSpecialArgs = {
            hostname = "macbook";
            inherit userSettings inputs;
          };
        };
      };
    };
}
