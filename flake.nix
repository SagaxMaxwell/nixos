{
  description = "NixOS configuration";

  nixConfig = {
    extra-substituters = [
      "https://cache.lantian.pub/lantian"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.8.0";

    luciole = {
      url = "github:noctalia-dev/luciole";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    justray = {
      url = "github:luynrs/justray";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    obsidian-extensions = {
      url = "git+https://github.com/karaolidis/nix-obsidian-extensions?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;
      system = "x86_64-linux";

      # Shared background opacity.
      opacity = 0.8;

      # Alpha byte for RGBA colors.
      alpha = lib.fixedWidthString 2 "0" (
        lib.toLower (lib.toHexString (builtins.floor (opacity * 255 + 0.5)))
      );
    in
    {
      devShells.${system}.default =
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        (pkgs.mkShell.override {
          stdenv = pkgs.stdenvAdapters.useMoldLinker pkgs.stdenv;
        })
          { };

      checks.${system} =
        let
          config = self.nixosConfigurations.nixos.config;
          pkgs = self.nixosConfigurations.nixos.pkgs;
          home = config.home-manager.users.maxwell;
        in
        {
          noctalia-config = home.xdg.configFile."noctalia/config.toml".source;
          umbriel-config = pkgs.runCommand "umbriel-config" { } ''
            ${config.programs.umbriel.package}/bin/umbriel config validate \
              -c ${home.xdg.configFile."umbriel/config.toml".source}
            touch "$out"
          '';
        };

      nixosConfigurations.nixos = lib.nixosSystem {
        specialArgs = { inherit inputs opacity; };
        modules = [
          ./configuration.nix

          inputs.nix-flatpak.nixosModules.nix-flatpak

          inputs.home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [
              inputs.nix-cachyos-kernel.overlays.pinned
              inputs.obsidian-extensions.overlays.default
            ];

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-backup";
              overwriteBackup = true;
              extraSpecialArgs = { inherit opacity alpha; };
              users.maxwell.imports = [
                inputs.nix-index-database.homeModules.default
                ./home.nix
              ];
            };
          }
        ];
      };
    };
}
