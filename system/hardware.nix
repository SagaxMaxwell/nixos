{ pkgs, ... }:

{
  hardware = {
    amdgpu = {
      initrd.enable = true;
      opencl.enable = true;
    };
    i2c.enable = true;
  };

  home-manager.users.maxwell.home.packages = with pkgs; [
    ddcutil
    libva-utils
    mesa-demos
    nvtopPackages.amd
    pciutils
    vulkan-tools
    vulkan-validation-layers
  ];
}
