{ lib, pkgs, ... }:

{
  config = {
    # List options merge, so the subvol entries from hardware-configuration.nix
    # survive. Setting them here rather than in the generated file keeps the
    # compression choice out of nixos-generate-config's overwrite path.
    fileSystems."/".options = [ "compress=zstd:1" ];
    fileSystems."/home".options = [ "compress=zstd:1" ];
    fileSystems."/nix".options = [ "compress=zstd:1" ];

    boot.supportedFilesystems.btrfs = true;

    hardware = {
      cpu.amd.updateMicrocode = true;
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
  };
}
