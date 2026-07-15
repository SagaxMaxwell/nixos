{ pkgs, ... }:

{
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      clinfo
      libva-utils
      mesa-demos
      vdpauinfo
      vulkan-tools
      vulkan-validation-layers
    ];
  };
}
