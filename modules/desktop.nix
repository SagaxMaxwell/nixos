{ pkgs, ... }:

{
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

      alsa = {
        enable = true;
        support32Bit = pkgs.stdenv.hostPlatform.isx86_64;
      };

      pulse = {
        enable = true;
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
          default = [ "gtk" ];
        };
      };
    };
  };
}
