{ pkgs, ... }:

{
  hardware.cpu.amd.updateMicrocode = true;

  hardware = {
    amdgpu = {
      initrd.enable = true;
      opencl.enable = true;
    };
    i2c.enable = true;
  };

  environment.systemPackages = with pkgs; [
    ddcutil
    libva-utils
    mesa-demos
    nvtopPackages.amd
    pciutils
    vulkan-tools
    vulkan-validation-layers
  ];
}
