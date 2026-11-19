{ inputs, pkgs, ... }:

let

  # Correct the upstream dependency hash.
  justray = inputs.justray.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs {
    vendorHash = "sha256-IGRz+7u0vpk4DPjXoFwXkffSiwZb/EnnkTCrXNO2S4M=";
  };
in
{
  imports = [ inputs.justray.nixosModules.default ];
  programs.justray = {
    enable = true;
    package = justray;
  };

  home-manager.users.maxwell = {
    imports = [ inputs.justray.homeManagerModules.default ];
    services.justray = {
      enable = true;
      package = justray;
    };
  };

  security = {
    rtkit.enable = true;
    sudo.enable = false;
    run0 = {
      enable = true;
      sudo-shim.enable = true;
    };
  };

  services = {
    flatpak = {
      enable = true;
      remotes = [
        {
          name = "flathub";
          location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        }
        {
          name = "flathub-beta";
          location = "https://dl.flathub.org/beta-repo/flathub-beta.flatpakrepo";
        }
        {
          name = "gnome-nightly";
          location = "https://nightly.gnome.org/gnome-nightly.flatpakrepo";
        }
      ];
      packages = [ "org.onlyoffice.desktopeditors" ];
      uninstallUnused = true;
      update.auto = {
        enable = true;
        onCalendar = "weekly";
      };
    };
    journald.settings.Journal = {
      Storage = "persistent";
      SystemMaxUse = "1G";
      MaxRetentionSec = "30day";
    };

    fwupd.enable = true;
    openssh.enable = true;
    resolved.enable = true;
    chrony.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
  };

  xdg.portal = {
    enable = true;
    config.common.default = [ "gtk" ];
  };

  networking = {
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
      wifi.powersave = false;
      dispatcherScripts = [
        {
          source = pkgs.writeShellScript "justray-dns" ''
            set -eu

            case "$1:$2" in
              justray:up|justray:reapply)
                ${pkgs.systemd}/bin/resolvectl dns "$1" 172.19.0.2
                ${pkgs.systemd}/bin/resolvectl domain "$1" '~.'
                ${pkgs.systemd}/bin/resolvectl flush-caches
                ;;
            esac
          '';
        }
      ];
    };
    nftables.enable = true;
    firewall.checkReversePath = "loose";
  };

  boot = {
    kernelModules = [ "tcp_bbr" ];
    kernel.sysctl = {
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.core.default_qdisc" = "fq";
    };
  };
}
