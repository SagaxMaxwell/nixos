{ lib, ... }:

{
  # Global mimalloc preload; packages bundling jemalloc must disable it or crash at startup.
  environment.memoryAllocator.provider = "mimalloc";
  nixpkgs.overlays = [
    (
      _: prev:
      lib.mapAttrs
        (
          name: option:
          prev.${name}.overrideAttrs (previous: {
            mesonFlags = lib.filter (flag: !lib.hasPrefix "${option}=" flag) (previous.mesonFlags or [ ]) ++ [
              "${option}=disabled"
            ];
          })
        )
        {
          knot-resolver_6 = "-Dmalloc";
          noctalia = "-Djemalloc";
          umbriel = "-Djemalloc";
        }
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
