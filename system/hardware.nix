{ lib, pkgs, ... }:

{
  # Apply compression to each declared Btrfs mount, preserving its other options.
  options.fileSystems = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { config, ... }:
        {
          config.options = lib.mkIf (config.fsType == "btrfs") [ "compress=zstd:1" ];
        }
      )
    );
  };

  config = {
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
