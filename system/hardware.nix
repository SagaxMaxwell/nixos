{ lib, pkgs, ... }:

{

  # Preserve generated subvolume options.
  fileSystems = lib.genAttrs [ "/" "/home" "/nix" ] (_: {
    options = [ "compress=zstd:1" ];
  });

  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
  };

  hardware = {
    amdgpu = {
      initrd.enable = true;
      opencl.enable = true;
    };
    i2c.enable = true;
  };

  services.udev.packages = [ pkgs.openrgb ];

  home-manager.users.maxwell.home.packages = with pkgs; [
    ddcutil
    libva-utils
    mesa-demos
    nvtopPackages.amd
    openrgb
    pciutils
    vulkan-tools
    vulkan-validation-layers
  ];

  # Use zram only.
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
