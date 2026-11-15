{ inputs, pkgs, ... }:

let
  justraySettings = (pkgs.formats.json { }).generate "justray-settings.json" {
    connection.dns = "https://223.5.5.5/dns-query";
    routing.block_quic = "off";
  };
in
{
  imports = [ inputs.justray.nixosModules.default ];

  security = {
    rtkit.enable = true;
    sudo.enable = false;
    run0 = {
      enable = true;
      sudo-shim.enable = true;
    };

    # The user daemon's resolvectl children need permission to switch TUN DNS.
    polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (subject.user === "maxwell" && [
          "org.freedesktop.resolve1.revert",
          "org.freedesktop.resolve1.set-domains",
          "org.freedesktop.resolve1.set-default-route",
          "org.freedesktop.resolve1.set-dns-servers"
        ].indexOf(action.id) !== -1) {
          return polkit.Result.YES;
        }
      });
    '';
  };

  programs.justray.enable = true;

  home-manager.users.maxwell = { config, lib, ... }: {
    imports = [ inputs.justray.homeManagerModules.default ];
    services.justray.enable = true;
    systemd.user.services.justrayd.Unit.X-Restart-Triggers = [
      "${config.services.justray.package}"
      "${justraySettings}"
    ];

    # Keep settings writable; use reachable DoH for both node and proxy DNS.
    home.activation.justraySettings = lib.hm.dag.entryAfter [ "linkGeneration" ] (
      lib.hm.generators.mkImpureConfigMerger {
        inherit pkgs;
        format = "json";
        empty = "{}";
        jqOperation = "$dynamic * $static";
        path = "${config.xdg.configHome}/justray/config.json";
        staticSettings = justraySettings;
      }
    );
  };

  services = {
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

  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
    wifi.powersave = false;
  };

  networking.nftables.enable = true;
  networking.firewall.checkReversePath = "loose";

  boot.kernelModules = [ "tcp_bbr" ];
  boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "fq";
  };
}
