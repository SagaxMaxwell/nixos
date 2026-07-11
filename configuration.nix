{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ./modules/asus.nix
    ./modules/nvidia.nix
    ./modules/openrgb.nix

    ./modules/desktop.nix
    ./modules/fonts.nix
    ./modules/input.nix

    ./modules/gaming.nix
    ./modules/mihomo.nix
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  nix = {
    package = pkgs.nixVersions.latest;
    
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
      persistent = true;
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

      efi = {
        canTouchEfiVariables = true;
      };
    };

    tmp = {
      cleanOnBoot = true;
    };

    kernelPackages = pkgs.linuxPackages_latest;
  };

  users.users.maxwell = {
    isNormalUser = true;
    description = "Maxwell";
    group = "users";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  services = {
    fstrim = {
      enable = true;
    };

    fwupd = {
      enable = true;
    };

    openssh = {
      enable = true;
    };
  };

  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  system = {
    stateVersion = "26.05";
  };

  programs = {
    fish = {
      enable = true;
    };

    nix-ld = {
      enable = true;
    };

    zsh = {
      enable = true;
    };
  };
}
