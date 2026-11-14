{ pkgs, ... }:

{
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
}
