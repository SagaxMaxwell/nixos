{
  config,
  lib,
  pkgs,
  ...
}:

let
  throneAutostart = pkgs.makeDesktopItem {
    name = "Throne";
    desktopName = "Throne";
    exec = "${lib.getExe config.programs.throne.package} -tray";
  };
in

{
  security = {
    rtkit.enable = true;
    sudo.enable = false;
    run0 = {
      enable = true;
      sudo-shim.enable = true;
    };
  };

  programs.throne = {
    enable = true;
    tunMode.enable = true;
  };

  home-manager.users.maxwell.xdg.autostart = {
    enable = true;
    entries = [ "${throneAutostart}/share/applications/Throne.desktop" ];
  };

  services = {
    journald.settings.Journal = {
      Storage = "persistent";
      SystemMaxUse = "1G";
      MaxRetentionSec = "30day";
    };

    fwupd.enable = true;
    openssh.enable = true;
    resolved.enable = true;
    chrony.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
  };

  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
    wifi.powersave = false;
  };

  networking.nftables.enable = true;
}
