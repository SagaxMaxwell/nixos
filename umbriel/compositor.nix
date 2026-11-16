{ lib, ... }:

let
  # Output name from `umbriel outputs`; empty keeps automatic detection.
  outputName = "";

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

}
