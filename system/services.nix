{ inputs, ... }:

{
  imports = [ inputs.justray.nixosModules.default ];
  programs.justray.enable = true;

  home-manager.users.maxwell = {
    imports = [ inputs.justray.homeManagerModules.default ];
    services.justray.enable = true;
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

  networking = {
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
      wifi.powersave = false;
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
