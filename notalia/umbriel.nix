{
  lib,
  pkgs,
  opacity,
  ...
}:

{
  programs.umbriel.enable = true;

  home-manager.users.maxwell = { config, ... }: {
    imports = [ "${pkgs.umbriel.src}/nix/home-module.nix" ];

    programs.umbriel = {
      enable = true;

      # Extend the upstream starting configuration.
      settings =
        lib.recursiveUpdate
          (builtins.fromTOML (builtins.readFile "${pkgs.umbriel.src}/examples/config.toml"))
          {
            general = {
              xwayland_native_resolution = true;
              autostart = [
                (lib.getExe config.programs.ghostty.package)
                (lib.getExe config.programs.google-chrome.finalPackage)
              ];
            };

            layout = {
              mode = "scrolling";
              gap = 8;

              # Cancel outer gaps while keeping window spacing.
              struts = {
                left = -8;
                right = -8;
                top = -8;
                bottom = -8;
              };

              extent_presets = [
                0.5
                0.7
                0.9
              ];
              scrolling = {
                default_extent_fraction = 0.7;
                center_underfull_strip = true;
              };
            };

            appearance = {
              border_width = 0;
              drag_opacity = opacity;
            };
          };
    };

    # Support the upstream terminal shortcut.
    programs.kitty = {
      enable = true;
      settings.background_opacity = opacity;
    };
  };
}
