{ lib, ... }:

{
  # Global mimalloc preload; packages bundling jemalloc must disable it or crash at startup.
  environment.memoryAllocator.provider = "mimalloc";
  nixpkgs.overlays = [
    (
      _: prev:
      lib.genAttrs [ "noctalia" "umbriel" ] (
        name:
        prev.${name}.overrideAttrs (previous: {
          mesonFlags = lib.filter (flag: !lib.hasPrefix "-Djemalloc=" flag) (previous.mesonFlags or [ ]) ++ [
            "-Djemalloc=disabled"
          ];
        })
      )
    )
  ];

  # zram only
  swapDevices = lib.mkForce [ ];
  boot.kernelParams = [ "zswap.enabled=0" ];
  services.zram-generator = {
    enable = true;
    settings.zram0 = {
      zram-size = "ram / 2";
      compression-algorithm = "zstd";
    };
  };

  systemd.oomd.enableUserSlices = true;
}
