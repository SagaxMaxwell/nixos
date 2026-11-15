{
  config,
  lib,
  pkgs,
  inputs,
  opacity,
  ...
}:

let

  # Output name from `umbriel outputs`.
  outputName = "";

  strata = inputs.strata.packages.${pkgs.stdenv.hostPlatform.system}.default;
  defaults = fromTOML (builtins.readFile "${pkgs.umbriel.src}/examples/config.toml");

in
{
  programs.umbriel.enable = true;

  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
  };

  services = {
    displayManager.noctalia-greeter = {
      enable = true;
      settings.session.default = "umbriel";
    };
    gnome.gnome-keyring.enable = true;
    gvfs.enable = true;
    dbus.packages = [ strata.fileManagerService ];
  };

  xdg.portal.config.umbriel = {
    default = [
      "umbriel"
      "gtk"
    ];
    "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
  };

  fonts.fontconfig = {
    hinting.style = "medium";
    useEmbeddedBitmaps = false;
    defaultFonts = {
      sansSerif = [
        "IBM Plex Sans"
        "Source Han Sans SC"
      ];
      serif = [ "Source Han Serif SC" ];
      monospace = [
        "JetBrainsMono Nerd Font Mono"
        "Source Han Mono SC"
      ];
    };
  };

  fonts.packages = with pkgs; [
    ibm-plex
    lxgw-wenkai
    nerd-fonts.jetbrains-mono
    source-han-mono
    source-han-sans
    source-han-serif
  ];

  home-manager.users.maxwell = { lib, ... }: {
    imports = [ "${pkgs.umbriel.src}/nix/home-module.nix" ];

    home.packages = [ strata ];
    qt = {
      enable = true;
      platformTheme.name = "xdgdesktopportal";
    };

    home.activation.strataAppearance = lib.hm.dag.entryAfter [ "linkGeneration" ] (
      lib.hm.generators.mkImpureConfigMerger {
        inherit pkgs;
        format = "toml";
        empty = "{}";
        jqOperation = "$dynamic * $static";
        path = "${config.home-manager.users.maxwell.xdg.configHome}/strata/settings.toml";
        staticSettings = (pkgs.formats.toml { }).generate "strata-appearance.toml" {
          mode = "system";
          theme = "atelier-cave-light";
        };
      }
    );
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = [ "io.github.lgse.Strata.desktop" ];
        "x-scheme-handler/trash" = [ "io.github.lgse.Strata.desktop" ];
      };
    };

    systemd.user.services.noctalia.Unit.X-Restart-Triggers = lib.optional (
      config.time.timeZone != null
    ) config.time.timeZone;

    programs.umbriel = {
      enable = true;
      settings = {
        general.xwayland_native_resolution = true;

        # Noctalia owns the generated colors; keep the base config declarative.
        include.optional.files = [ "noctalia.toml" ];

        output = lib.optionalAttrs (outputName != "") {
          ${outputName} = {
            mode = "3840x2160@240";
            hdr = "on";
          };
        };

        layout = {
          gap = 8;
          extent_presets = [
            0.5
            0.7
            1.0
          ];
          scrolling.default_extent_fraction = 0.7;
        };

        input = {
          focus.follows_mouse = true;

          # Cursor follows keyboard focus.
          cursor.follows_focus = true;
        };

        appearance = {
          border_width = 0;

          # Frosted glass; blur windows behind too.
          blur = {
            optimized = false;
            passes = 3;
            radius = 8;
            brightness = 1.0;
            contrast = 1.0;
            saturation = 1.2;
          };
        };

        # Upstream defaults; swap the terminal, wrap horizontal focus.
        keybinds = lib.recursiveUpdate defaults.keybinds {
          "Mod+Return".action = "spawn ghostty";
          "Mod+Left" = "window-focus-previous";
          "Mod+Right" = "window-focus-next";
          "Mod+H" = "window-focus-previous";
          "Mod+L" = "window-focus-next";
          "Mod+WheelUp" = "window-focus-previous";
          "Mod+WheelDown" = "window-focus-next";
        };
        inherit (defaults) layer_rule;

        # Focus border draws into the gap.
        window_rule = defaults.window_rule ++ [
          {
            match.is_focused = true;
            border_width = 4;
          }
        ];
      };
    };

    programs.noctalia = {
      enable = true;
      systemd.enable = true;

      settings = {
        brightness.enable_ddcutil = true;

        theme = {
          mode = "auto";
          source = "community";
          community_palette = "One Dark Warmer";
          templates.builtin_ids = [
            "umbriel"
            "ghostty"
          ];
        };

        wallpaper.fill_color = "surface";
        weather.enabled = false;
        notification.background_opacity = opacity;
        osd.background_opacity = opacity;

        nightlight = {
          enabled = true;
          temperature_night = 5500;
        };

        location = {
          custom_schedule = true;
          sunset = "18:00";
          sunrise = "06:00";
        };

        shell = {
          polkit_agent = true;
          font_family = "IBM Plex Sans";
          panel = {
            transparency_mode = "glass";
            control_center_placement = "floating";
            control_center_position = "top_right";
          };
        };

        bar.default.enabled = false;

        hot_corners = {
          enabled = true;
          delay_ms = 500;
          top_right.action = "control_center";
        };

        control_center = {
          media.show_visualizer = false;
          shortcuts = map (type: { inherit type; }) [
            "wifi"
            "bluetooth"
            "clipboard"
            "nightlight"
            "notification"
            "power_profile"
          ];
        };

        idle = {
          behavior_order = [
            "lock"
            "screen-off"
            "suspend"
          ];
          behavior = {
            lock = {
              timeout = 600;
              action = "lock";
            };
            screen-off = {
              timeout = 900;
              action = "screen_off";
            };
            suspend = {
              timeout = 1200;
              action = "lock_and_suspend";
            };
          };
        };
      };
    };
  };
}
