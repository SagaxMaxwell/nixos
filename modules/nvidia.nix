{ config, ... }:

{
  services = {
    xserver = {
      videoDrivers = config.local.graphics.videoDrivers;
    };
  };

  hardware = {
    nvidia = {
      open = true;

      powerManagement = {
        enable = true;
      };
    };
  };
}
