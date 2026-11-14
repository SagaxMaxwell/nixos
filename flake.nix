{
  description = "NixOS configuration";

  nixConfig = {
    extra-substituters = [ "https://cache.lantian.pub/lantian" ];
    extra-trusted-public-keys = [
      "lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/master";

    home-manager = {
      url = "github:nix-community/home-manager";

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

    sheprd = {
      url = "github:sheprd-labs/sheprd";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    strata = {
      url = "github:lgse/strata";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sfd-nix = {
      url = "github:asaineko/sfd-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-cronet.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      system = "x86_64-linux";

      # Shared background opacity.
      opacity = 0.8;
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

      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs opacity; };
        modules = [
          ./configuration.nix

          inputs.home-manager.nixosModules.home-manager
          inputs.sfd-nix.nixosModules.default
          {
            nixpkgs.overlays = [
              inputs.nix-cachyos-kernel.overlays.pinned
              inputs.obsidian-extensions.overlays.default
              inputs.sheprd.overlays.default
            ];

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-backup";
              overwriteBackup = true;
              extraSpecialArgs = { inherit opacity; };
              users.maxwell = {
                imports = [
                  inputs.nix-index-database.homeModules.default
                  ./home
                ];
              };
            };
          }
        ];
      };
    };
}
