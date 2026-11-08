{ lib, pkgs, ... }:

{
  security.rtkit.enable = true;
  swapDevices = lib.mkForce [ ];

  programs = {
    niri = {
      enable = true;
      useNautilus = false;
    };

    noctalia = {
      enable = true;
      recommendedServices.enable = true;
    };

    sing-box-for-desktop = {
      enable = true;
      settings = {
        startAtLogin = true;
        core.insecureMode = false;
      };
    };
  };

  services = {
    displayManager.noctalia-greeter.enable = true;
    fwupd.enable = true;
    openssh.enable = true;
    firewalld.enable = true;
    knot-resolver.enable = true;
    chrony.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    zram-generator = {
      enable = true;
      settings.zram0 = {
        zram-size = "ram / 2";
        compression-algorithm = "zstd";
      };
    };
  };

  networking.networkmanager = {
    enable = true;
    dns = "none";
  };

  networking.nftables.enable = true;

  fonts.packages = with pkgs; [
    ibm-plex
    lxgw-wenkai
    nerd-fonts.jetbrains-mono
    source-han-mono
    source-han-sans
    source-han-serif
  ];
}
