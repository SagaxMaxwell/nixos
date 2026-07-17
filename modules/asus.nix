{
  programs = {
    rog-control-center = {
      enable = true;
    };
  };

  services = {
    hardware.openrgb = {
      enable = true;
    };

    power-profiles-daemon = {
      enable = true;
    };

    supergfxd = {
      enable = true;
    };

    thermald = {
      enable = true;
    };
  };
}
