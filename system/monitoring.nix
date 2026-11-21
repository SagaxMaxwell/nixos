{
  services = {
    scrutiny = {
      enable = true;
      settings.web = {
        listen.host = "127.0.0.1";
        influxdb.host = "127.0.0.1";
      };
    };
    influxdb2.settings.http-bind-address = "127.0.0.1:8086";
  };
}
