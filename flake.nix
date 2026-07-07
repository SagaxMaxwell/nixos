{
  description = "NixOS configuration";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs?ref=nixos-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager";

      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      hostname = "nixos";
      username = "maxwell";
    in
    {
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs hostname username;
        };

        modules = [
          ./configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;

              extraSpecialArgs = {
                inherit inputs username;
              };

              users.${username} = import ./home.nix;
            };
          }
        ];
      };
    };
}
