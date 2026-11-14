{ lib, ... }:

{

  # Zram only.
  swapDevices = lib.mkForce [ ];
  boot.kernelParams = [ "zswap.enabled=0" ];
  services.zram-generator = {
    enable = true;
    settings.zram0 = {
      zram-size = "ram / 2";
      compression-algorithm = "zstd";
    };
  };

  systemd.oomd.enableUserSlices = true;
}
