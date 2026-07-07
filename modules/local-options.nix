{ lib, ... }:

let
  inherit (lib) mkOption types;
in
{
  options.local = {
    stateVersion = mkOption {
      type = types.str;
      description = "NixOS and Home Manager state version for this host.";
    };

    user = {
      name = mkOption {
        type = types.str;
        description = "Primary local username.";
      };

      fullName = mkOption {
        type = types.str;
        description = "Display name for the primary local user.";
      };

      primaryGroup = mkOption {
        type = types.str;
        default = "users";
        description = "Primary group for the local user.";
      };

      extraGroups = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Supplementary groups for the local user.";
      };

      git = {
        name = mkOption {
          type = types.str;
          description = "Git author name.";
        };

        email = mkOption {
          type = types.str;
          description = "Git author email.";
        };
      };
    };

    paths = {
      home = mkOption {
        type = types.str;
        description = "Home directory for the primary local user.";
      };

      mihomoConfig = mkOption {
        type = types.path;
        description = "Mihomo configuration file path.";
      };
    };

    nix = {
      gc = {
        dates = mkOption {
          type = types.str;
          default = "weekly";
          description = "Systemd calendar for automatic Nix garbage collection.";
        };

        options = mkOption {
          type = types.str;
          default = "--delete-older-than 30d";
          description = "Arguments passed to nix-collect-garbage.";
        };

        randomizedDelaySec = mkOption {
          type = types.str;
          default = "45min";
          description = "Randomized delay for automatic Nix garbage collection.";
        };
      };

      optimise.dates = mkOption {
        type = types.listOf types.str;
        default = [ "weekly" ];
        description = "Systemd calendar values for automatic Nix store optimisation.";
      };
    };

    desktop.portalBackend = mkOption {
      type = types.str;
      default = "gtk";
      description = "Default xdg-desktop-portal backend name.";
    };

    inputMethod.type = mkOption {
      type = types.str;
      default = "fcitx5";
      description = "NixOS input method type.";
    };

    graphics.videoDrivers = mkOption {
      type = types.listOf types.str;
      default = [ "nvidia" ];
      description = "X server video drivers.";
    };
  };
}
