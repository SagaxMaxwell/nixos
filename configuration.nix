{ config, ... }:

{
  imports = [
    ./modules/local-options.nix
    ./hardware-configuration.nix
    ./modules/desktop.nix
    ./modules/fonts.nix
    ./modules/gaming.nix
    ./modules/input.nix
    ./modules/mihomo.nix
    ./modules/nvidia.nix
    ./modules/asus.nix
  ];

  local = rec {
    stateVersion = "26.05";

    user = {
      name = "maxwell";
      fullName = "Maxwell";
      primaryGroup = "users";
      extraGroups = [ "networkmanager" "wheel" ];

      git = {
        name = "Maxwell";
        email = "sagax.maxwell@gmail.com";
      };
    };

    paths = rec {
      home = "/home/" + user.name;
      mihomoConfig = home + "/Downloads/clash-verge.yaml";
    };

    nix = {
      gc = {
        dates = "weekly";
        options = "--delete-older-than 30d";
        randomizedDelaySec = "45min";
      };

      optimise = {
        dates = [ "weekly" ];
      };
    };

    desktop = {
      portalBackend = "gtk";
    };

    inputMethod = {
      type = "fcitx5";
    };

    graphics = {
      videoDrivers = [ "nvidia" ];
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };

    gc = {
      automatic = true;
      dates = config.local.nix.gc.dates;
      options = config.local.nix.gc.options;
      persistent = true;
      randomizedDelaySec = config.local.nix.gc.randomizedDelaySec;
    };

    optimise = {
      automatic = true;
      dates = config.local.nix.optimise.dates;
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
  };

  networking = {
    networkmanager.enable = true;
  };

  users.users.${config.local.user.name} = {
    isNormalUser = true;
    description = config.local.user.fullName;
    group = config.local.user.primaryGroup;
    extraGroups = config.local.user.extraGroups;
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
    stateVersion = config.local.stateVersion;
  };

  programs = {
    nix-ld = {
      enable = true;
    };

    fish = {
      enable = true;
    };

    zsh = {
      enable = true;
    };
  };
}
