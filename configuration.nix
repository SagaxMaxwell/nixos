{ lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./desktop/hyprland.nix
    ./system/services.nix
    ./system/gaming.nix
    ./system/hardware.nix
    ./system/input.nix
    ./system/virtualisation.nix
  ];

  nixpkgs.config.allowUnfree = true;

  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "zh_CN.UTF-8";

  programs.chromium = {
    enable = true;
    extraOpts.ExtensionSettings."bgnkhhnnamicmpeenaelnjfhikgbkllg" = {
      installation_mode = "force_installed";
      update_url = "https://clients2.google.com/service/update2/crx";
    };
  };

  nix = {
    package = pkgs.lix;

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = lib.mkAfter [ "https://cache.lantian.pub/lantian" ];
      trusted-public-keys = lib.mkAfter [
        "lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ="
      ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
      randomizedDelaySec = "45min";
    };

    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
  };

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };

      efi.canTouchEfiVariables = true;
    };

    tmp.cleanOnBoot = true;

    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
  };

  users.users.maxwell = {
    isNormalUser = true;
    description = "Maxwell";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  system.stateVersion = "26.05";

  programs.nix-ld.enable = true;
  programs.nushell.enable = true;
  users.defaultUserShell = pkgs.nushell;
  systemd.oomd.enableUserSlices = true;
}
