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
        core.insecureMode = false;
      };
    };
  };

  services = {
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
  # Allow sing-box TUN traffic back into the host.
  networking.firewall.trustedInterfaces = [ "tun0" ];
}
