{
  services = {
    xserver = {
      videoDrivers = [ "nvidia" ];
    };
  };

  hardware = {
    nvidia = {
      open = false;

      powerManagement = {
        enable = true;
      };
    };
  };
}
