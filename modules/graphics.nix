{ pkgs, ... }:

{
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver
        # intel-compute-runtime
        intel-compute-runtime-legacy1
        intel-compute-runtime-legacy1.drivers
      ];
    };
  };

  environment = {
    systemPackages = with pkgs; [
      clinfo
      intel-gpu-tools
      libva-utils
      mesa-demos
      nvtopPackages.full
      vdpauinfo
      vulkan-tools
      vulkan-validation-layers
    ];
  };
}
