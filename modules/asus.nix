{
  programs = {
    rog-control-center = {
      enable = true;
    };
  };

  services = {
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
