{ 
  programs = {
    rog-control-center = {
      enable = true;
    };
  };

  services = {
    supergfxd = {
      enable = true;
    };

    power-profiles-daemon = {
      enable = true;
    };

    thermald = {
      enable = true;
    };
  };
}
