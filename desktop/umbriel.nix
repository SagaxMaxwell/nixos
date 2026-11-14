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

  # Expose GPU drivers to the preview sandbox; drop after lgse/strata#2261.
  strata =
    inputs.strata.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs
      (previous: {
        postPatch = (previous.postPatch or "") + ''
          substituteInPlace src/sandbox/command.rs \
            --replace-fail 'command.args(["--ro-bind", "/sys", "/sys"]);' \
              'bind_try(command, "/run/opengl-driver");
                  command.args(["--ro-bind", "/sys", "/sys"]);'
        '';
      });
  defaults = fromTOML (builtins.readFile "${pkgs.umbriel.src}/examples/config.toml");
  accent = rec {
    primary = "#629EE8";
    onPrimary = "#182B45";
    secondary = primary;
    onSecondary = onPrimary;
    tertiary = primary;
    onTertiary = onPrimary;
  };
  modes = {
    light = rec {
      error = "#BA3547";
      onError = "#FFFFFF";
      surface = "#FFFFFF";
      onSurface = "#253244";
      surfaceVariant = "#F8FAFC";
      onSurfaceVariant = "#526174";
      outline = "#DCE4ED";
      shadow = "#CBD5E1";
      hover = "#E5F0FD";
      onHover = accent.onPrimary;
      ansi = {
        black = onSurface;
        green = "#347A54";
        yellow = "#8C681D";
        blue = "#316BB0";
        magenta = "#8655A6";
        cyan = "#267B8A";
        white = surfaceVariant;
      };
    };
    dark = rec {
      error = "#FFB4AB";
      onError = "#690005";
      surface = "#151A22";
      onSurface = "#E4EAF2";
      surfaceVariant = "#222B38";
      onSurfaceVariant = "#B4C1D2";
      outline = "#455468";
      shadow = "#000000";
      hover = "#2D4360";
      onHover = onSurface;
      ansi = {
        black = "#354153";
        green = "#9AD6AF";
        yellow = "#E9CA83";
        blue = "#9CC9FF";
        magenta = "#D8B4EF";
        cyan = "#8CD5DF";
        white = onSurface;
      };
    };
  };

  # Merge the accent and derive terminal colors.
  palette =
    colors:
    accent
    // removeAttrs colors [ "ansi" ]
    // {
      terminal = rec {
        background = colors.surface;
        foreground = colors.onSurface;
        cursor = colors.onSurface;
        cursorText = colors.surface;
        selectionBg = colors.hover;
        selectionFg = colors.onSurface;
        normal = colors.ansi // {
          red = colors.error;
        };
        bright = normal;
      };
    };
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

  fonts.packages = with pkgs; [
    ibm-plex
    lxgw-wenkai
    nerd-fonts.jetbrains-mono
    source-han-mono
    source-han-sans
    source-han-serif
  ];

  home-manager.users.maxwell = {
    imports = [ "${pkgs.umbriel.src}/nix/home-module.nix" ];

    home.packages = [ strata ];
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
          focus = {
            follows_mouse = true;
            follows_mouse_max_scroll = 0.0;
          };

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

        # Upstream defaults; swap the terminal only.
        keybinds = lib.recursiveUpdate defaults.keybinds {
          "Mod+Return".action = "spawn ghostty";
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
      customPalettes.WhiteBlue = lib.mapAttrs (_: palette) modes;

      settings = {
        brightness.enable_ddcutil = true;

        theme = {
          mode = "auto";
          source = "custom";
          custom_palette = "WhiteBlue";
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

        idle.behavior = {
          lock = {
            timeout = 600;
            action = "lock";
          };
          screen-off = {
            timeout = 660;
            action = "screen_off";
          };
        };
      };
    };
  };
}
