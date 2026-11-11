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
    {
      self,
      nixpkgs,
      nix-cachyos-kernel,
      home-manager,
      nix-index-database,
      obsidian-extensions,
      sheprd,
      strata,
      sfd-nix,
      ...
    }:
    let
      system = "x86_64-linux";
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
        }
        // nixpkgs.lib.optionalAttrs config.programs.niri.enable {
          niri-config = home.xdg.configFile."niri/config.kdl".source;
        }
        // nixpkgs.lib.optionalAttrs config.programs.umbriel.enable {
          umbriel-config = pkgs.runCommand "umbriel-config" { } ''
            ${config.programs.umbriel.package}/bin/umbriel config validate \
              -c ${home.xdg.configFile."umbriel/config.toml".source}
            touch "$out"
          '';
        };

      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs.strata = strata.packages.${system}.default.overrideAttrs (previous: {
          # Expose NixOS media drivers inside the preview sandbox.
          postPatch = (previous.postPatch or "") + ''
            substituteInPlace src/sandbox/command.rs \
              --replace-fail 'command.args(["--ro-bind", "/sys", "/sys"]);' \
                'bind_try(command, "/run/opengl-driver");
                    command.args(["--ro-bind", "/sys", "/sys"]);'
          '';
        });
        modules = [
          ./configuration.nix

          home-manager.nixosModules.home-manager
          sfd-nix.nixosModules.default
          {
            nixpkgs.overlays = [
              nix-cachyos-kernel.overlays.pinned
              obsidian-extensions.overlays.default
              sheprd.overlays.default
            ];

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.maxwell = {
                imports = [
                  nix-index-database.homeModules.default
                  ./home/programs.nix
                ];
              };
            };
          }
        ];
      };
    };
}
