{ config, pkgs, ... }:

{
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = pkgs.stdenv.hostPlatform.isx86_64;
    };
  };

  security = {
    rtkit = {
      enable = true;
    };
  };

  services = {
    xserver = {
      enable = true;
    };

    displayManager = {
      gdm = {
        enable = true;
      };
    };

    desktopManager = {
      gnome = {
        enable = true;
      };
    };

    pipewire = {
      enable = true;

      pulse = {
        enable = true;
      };

      alsa = {
        enable = true;
        support32Bit = pkgs.stdenv.hostPlatform.isx86_64;
      };
    };

    pulseaudio = {
      enable = false;
    };

    flatpak = {
      enable = true;
    };
  };

  programs = {
    dconf = {
      enable = true;
    };
  };

  xdg = {
    portal = {
      enable = true;
      xdgOpenUsePortal = true;

      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];

      config = {
        common = {
          default = [ config.local.desktop.portalBackend ];
        };
      };
    };
  };
}
