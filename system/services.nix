_:

{
  security = {
    rtkit.enable = true;
    sudo.enable = false;
    run0 = {
      enable = true;
      sudo-shim.enable = true;
    };
  };

  programs = {
    sing-box-for-desktop = {
      enable = true;
      settings = {
        startAtLogin = true;
        appearance = "auto";
        core.insecureMode = false;
      };
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

  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
  };

  networking.nftables.enable = true;

  # Let sing-box TUN traffic reach the host.
  networking.firewall.trustedInterfaces = [ "tun0" ];
}
