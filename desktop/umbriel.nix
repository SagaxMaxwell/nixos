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

  # NixOS-level value, captured here because the home-manager block below takes
  # its own `config` argument, which shadows this one.
  systemTimeZone = config.time.timeZone;

  # Keybinds are compiled into the binary; only express overrides and additions
  # here. Window and layer rules have no built-in defaults, so the upstream
  # example's entries are spelled out below.
  keybinds = {
    # Applications and session.
    "Mod+Return" = {
      action = "spawn ghostty";
      repeat = false;
    };
    "Mod" = "spawn noctalia msg panel-toggle launcher";
    "Mod+Shift+Escape" = {
      action = "shortcuts-inhibit-toggle";
      allow_when_inhibited = true;
      repeat = false;
    };

    # Media keys, routed through Noctalia so its OSDs show.
    "XF86AudioRaiseVolume" = {
      action = "spawn noctalia msg volume-up";
      allow_when_locked = true;
    };
    "XF86AudioLowerVolume" = {
      action = "spawn noctalia msg volume-down";
      allow_when_locked = true;
    };
    "XF86AudioMute" = {
      action = "spawn noctalia msg volume-mute";
      allow_when_locked = true;
      repeat = false;
    };
    "XF86AudioPlay" = {
      action = "spawn noctalia msg media toggle";
      allow_when_locked = true;
      repeat = false;
    };
    "XF86AudioNext" = {
      action = "spawn noctalia msg media next";
      allow_when_locked = true;
    };
    "XF86AudioPrev" = {
      action = "spawn noctalia msg media previous";
      allow_when_locked = true;
    };
    "XF86MonBrightnessUp" = {
      action = "spawn noctalia msg brightness-up";
      allow_when_locked = true;
    };
    "XF86MonBrightnessDown" = {
      action = "spawn noctalia msg brightness-down";
      allow_when_locked = true;
    };

    # Wrap horizontal focus instead of stopping at the ends.
    "Mod+Left" = "window-focus-previous";
    "Mod+Right" = "window-focus-next";
    "Mod+H" = "window-focus-previous";
    "Mod+L" = "window-focus-next";
    "Mod+WheelUp" = "window-focus-previous";
    "Mod+WheelDown" = "window-focus-next";

    # Extent tuning.
    "Mod+Minus" = "window-modify-primary-extent -0.02";
    "Mod+Equal" = "window-modify-primary-extent +0.02";
    "Mod+Ctrl+Minus" = "window-modify-secondary-extent -0.02";
    "Mod+Ctrl+Equal" = "window-modify-secondary-extent +0.02";

    "Mod+Shift+T" = {
      action = "window-focus-switch-floating";
      repeat = false;
    };

    # Tabs.
    "Mod+Alt+Right" = "column-focus-tab-next";
    "Mod+Alt+Left" = "column-focus-tab-previous";

    # Scratchpad.
    "Mod+Shift+Space" = {
      action = "window-move-to-scratchpad";
      repeat = false;
    };
    "Mod+Space" = "scratchpad-toggle";
    "Mod+Ctrl+Space" = {
      action = "window-restore-from-scratchpad";
      repeat = false;
    };
    "Mod+Tab" = "scratchpad-focus-next";
  };

  layerRule = [
    {
      match.namespace = "^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd|desktop-widget-[^\"]*)$";
      blur = true;
      blur_ignore_alpha = 0.5;
      blur_popups = true;
    }
    {
      # Surfaces that open over windows blur live content behind them.
      match.namespace = "^noctalia-(notification|dock|panel|attached-panel|osd)$";
      blur_optimized = false;
    }
  ];

  windowRule = [
    { blur = true; }

    {
      match.app_id = "^dev.noctalia.Noctalia$";
      default_floating = true;
      default_floating_size_px = {
        width = 1020;
        height = 900;
      };
    }
    {
      match.app_id = "^dev.noctalia.UmbrielSharePicker$";
      default_floating = true;
      default_floating_size_px = {
        width = 800;
        height = 600;
      };
    }
    {
      match.title = "^(Picture-in-Picture|Picture in picture)$";
      default_floating = true;
      default_maximize = false;
      default_position = {
        x = 20;
        y = 20;
        anchor = "bottom_right";
      };
    }
    {
      match.title = "^notificationtoasts_.+_desktop";
      default_position = {
        x = 0;
        y = 0;
        anchor = "bottom_right";
      };
      default_focused = false;
      default_pinned = true;
    }

    # Focus border draws into the gap.
    {
      match.is_focused = true;
      border_width = 4;
    }

    # Only unfocused floating windows get a negotiated title bar.
    {
      match = {
        is_focused = false;
        is_floating = true;
      };
      title_bar = "negotiated";
    }
  ];

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

  home-manager.users.maxwell = { config, lib, ... }: {
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
        path = "${config.xdg.configHome}/strata/settings.toml";
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
      systemTimeZone != null
    ) systemTimeZone;

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
          corner_radius = 12;

          # Frosted glass; blur windows behind too.
          blur = {
            optimized = false;
            passes = 3;
            radius = 8;
            brightness = 1.0;
            contrast = 1.0;
            saturation = 1.2;
          };

          shadow.softness = 24;
        };

        animation.windows_in.style = "zoom";

        inherit keybinds;
        layer_rule = layerRule;
        window_rule = windowRule;
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
          community_palette = "One";
          templates.builtin_ids = [
            "umbriel"
            "ghostty"
          ];
        };

        wallpaper = {
          default.path = "${config.programs.noctalia.package}/share/noctalia/assets/noctalia-wallpaper.png";
          fill_color = "surface";
        };
        notification.background_opacity = opacity;
        osd.background_opacity = opacity;

        nightlight = {
          enabled = true;
          temperature_night = 5500;
        };

        location = {
          auto_locate = true;
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
