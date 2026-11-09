{ lib, ... }:

{
  security = {
    rtkit.enable = true;
    sudo.enable = false;
    run0 = {
      enable = true;
      sudo-shim.enable = true;
    };
  };

  environment.memoryAllocator.provider = "mimalloc";
  swapDevices = lib.mkForce [ ];

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

    zram-generator = {
      enable = true;
      settings.zram0 = {
        zram-size = "ram / 2";
        compression-algorithm = "zstd";
      };
    };
  };

  networking.networkmanager = {
    enable = true;
    dns = "none";
    wifi.backend = "iwd";
  };

  networking.nftables.enable = true;
}
