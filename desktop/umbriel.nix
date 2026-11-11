{ lib, pkgs, ... }:

let
  defaults = builtins.fromTOML (builtins.readFile "${pkgs.umbriel.src}/examples/config.toml");
in
{
  imports = [ ./common.nix ];

  programs.umbriel.enable = true;
  services.displayManager.noctalia-greeter.settings.session.default = "umbriel";

  xdg.portal.config.umbriel = {
    default = [
      "umbriel"
      "gtk"
    ];
    "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
  };

  home-manager.users.maxwell = {
    imports = [ "${pkgs.umbriel.src}/nix/home-module.nix" ];

    programs.umbriel = {
      enable = true;
      settings = {
        layout = {
          gap = 12;
          extent_presets = [
            0.5
            0.7
            1.0
          ];
          scrolling.default_extent_fraction = 0.7;
        };

        input.focus = {
          follows_mouse = true;
          follows_mouse_max_scroll = 0.0;
        };

        appearance.blur.radius = 3;

        # Keep upstream keys and shell rules; only replace the terminal.
        keybinds = lib.recursiveUpdate defaults.keybinds {
          "Mod+Return".action = "spawn ghostty";
        };
        inherit (defaults) layer_rule;
        window_rule = defaults.window_rule ++ [ { hdr = "auto"; } ];
      };
    };
  };
}
