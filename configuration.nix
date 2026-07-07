{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/desktop.nix
    ./modules/gaming.nix
    ./modules/input.nix
    ./modules/mihomo.nix
    ./modules/nvidia.nix
    ./modules/asus.nix
  ];

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
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
  };

  networking = {
    networkmanager.enable = true;
  };

  users.users.maxwell = {
    isNormalUser = true;
    description = "Maxwell";
    group = "users";
    extraGroups = [ "networkmanager" "wheel" ];
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
