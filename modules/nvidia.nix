{
  services = {
    xserver = {
      videoDrivers = [ "nvidia" ];
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
