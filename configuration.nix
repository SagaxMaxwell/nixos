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

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [ "ventoy-1.1.18" ];
  };

  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "zh_CN.UTF-8";

  nix = {
    package = pkgs.lix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      use-xdg-base-directories = true;
      http3 = true;
      http2 = true;
      http-connections = 50;
      max-substitution-jobs = 32;
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
  environment.etc."opt/chrome/policies/managed/preferences.json".text = builtins.toJSON {
    RestoreOnStartup = 1;
    HighEfficiencyModeEnabled = true;
    MemorySaverModeSavings = 1;
    HardwareAccelerationModeEnabled = true;
  };
  programs.nushell.enable = true;
  programs.nix-ld.enable = true;

  system.stateVersion = "26.05";
}
