{ lib, ... }:

{
  security.rtkit.enable = true;
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
  };

  networking.nftables.enable = true;
}
