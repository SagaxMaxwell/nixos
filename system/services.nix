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
    knot-resolver.enable = true;
    chrony.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
  };

  networking.networkmanager = {
    enable = true;
    dns = "none";
    wifi.backend = "iwd";
  };

  networking.nftables.enable = true;
}
