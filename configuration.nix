{ lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./fonts.nix
    ./umbriel
    ./system/gaming.nix
    ./system/hardware.nix
    ./system/services.nix
    ./system/virtualisation.nix
  ];

  nixpkgs.config.allowUnfree = true;

  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "zh_CN.UTF-8";

  nix = {
    package = pkgs.lix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = lib.mkAfter [
        "https://cache.lantian.pub/lantian"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = lib.mkAfter [
        "lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
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
  users.defaultUserShell = pkgs.nushell;
  environment.shells = [ pkgs.nushell ];
  programs.nushell.enable = true;
  programs.nix-ld.enable = true;

  system.stateVersion = "26.05";
}
