{
  inputs,
  lib,
  pkgs,
  ...
}:

{
  imports = [ inputs.justray.nixosModules.default ];
  programs.justray = {
    enable = true;
    package = inputs.justray.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };

  home-manager.users.maxwell = {
    imports = [ inputs.justray.homeManagerModules.default ];
    services.justray = {
      enable = true;
      package = inputs.justray.packages.${pkgs.stdenv.hostPlatform.system}.default;
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
    ringboard.wayland.enable = true;

    flatpak = {
      enable = true;
      packages = [
        rec {
          appId = "jp.ne.ibis.ibisOffice";
          sha256 = "84bd15198df36f5d3e4c5bb826e2c1a2a1d63c03906e8bfd2b0efdce9a5fddb1";
          bundle = "${pkgs.fetchurl {
            url = "https://github.com/ibisjp/ibis-office/releases/download/v0.8.9/ibisOffice-0.8.9-Linux-x86_64.flatpak";
            inherit sha256;
          }}";
        }
        rec {
          appId = "com.flectar.mail";
          sha256 = "b439456b9f53684ca55464a2fb0d58b8aede5ddf1e0eb4f81e6e25ebab3a6f95";
          bundle = "${pkgs.fetchurl {
            url = "https://github.com/flectar/mail/releases/download/v0.1.0-alpha.7/flectar-mail-0.1.0-alpha.7-linux-x64.flatpak";
            inherit sha256;
          }}";
        }
      ];
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

  systemd.user.services.ringboard-listener.environment.RUST_LOG = lib.mkForce "warn";

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
