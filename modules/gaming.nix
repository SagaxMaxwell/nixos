{ pkgs, ... }:

{
  programs = {
    gamemode = {
      enable = true;
    };

    gamescope = {
      enable = true;
      capSysNice = true;
    };

    steam = {
      enable = true;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      mesa-demos
      vulkan-tools
      vulkan-validation-layers
      libva-utils
      vdpauinfo
      clinfo
      protonplus
    ];
  };
}
