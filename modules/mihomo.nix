{ lib, ... }:

{
  services = {
    mihomo = {
      enable = true;
      configFile = "/home/maxwell/Downloads/nixos/clash-verge.yaml";
      tunMode = true;
    };
  };

  networking.networkmanager = {
    enable = true;
    insertNameservers = [ "127.0.0.1" ];
  };

  systemd.services.mihomo.serviceConfig = {
    AmbientCapabilities = lib.mkAfter [ "CAP_NET_BIND_SERVICE" ];
    CapabilityBoundingSet = lib.mkAfter [ "CAP_NET_BIND_SERVICE" ];
  };
}
