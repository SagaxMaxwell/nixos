{ lib, pkgs, ... }:

let
  inherit (import ./flake.nix) nixConfig;
in
{
  imports = [
    ./hardware-configuration.nix
    ./system/fonts.nix
    ./notalia
    ./system/input.nix
    ./system/gaming.nix
    ./system/hardware.nix
    ./system/monitoring.nix
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
      substituters = lib.mkAfter nixConfig.extra-substituters;
      trusted-public-keys = lib.mkAfter nixConfig.extra-trusted-public-keys;
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
