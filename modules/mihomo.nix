{ config, ... }:

{
  services = {
    mihomo = {
      enable = true;
      configFile = config.local.paths.mihomoConfig;
      tunMode = true;
    };
  };
}
