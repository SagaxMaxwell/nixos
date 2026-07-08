{ pkgs, ... }:

{
  jovian.decky-loader = {
    enable = true;
    user = "maxwell";
    extraPackages = with pkgs; [
      flatpak
      p7zip
    ];
    # Jovian's Decky package currently defaults to pnpm_9, which this nixpkgs
    # revision marks as insecure.
    package = (pkgs.decky-loader.override {
      pnpm_9 = pkgs.pnpm_10;
    }).overridePythonAttrs (old: {
      pnpmDeps = old.pnpmDeps.overrideAttrs (_: {
        outputHash = "sha256-X1L8JYG5hgYMmfg0aa8XhkRU6/oFrYTPiXDIyq77puE=";
      });
    });
  };

  programs = {
    gamemode = {
      enable = true;
    };

    gamescope = {
      enable = true;
      capSysNice = true;
    };

    steam = {
      enable = true;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      mesa-demos
      vulkan-tools
      vulkan-validation-layers
      libva-utils
      vdpauinfo
      clinfo
      protonplus
    ];
  };
}
