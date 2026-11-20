{
  config,
  lib,
  opacity,
  ...
}:

{
  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
  };

  home-manager.users.maxwell = {
    programs.noctalia = {
      enable = true;
      systemd.enable = true;

      settings = {
        theme = {
          source = "wallpaper";
          mode = "auto";
          shell_mode = "auto";
          pure_black_dark = true;
        };
        location.auto_locate = true;

        weather = {
          enabled = true;
          unit = "celsius";
        };

        calendar.enabled = true;

        nightlight = {
          enabled = true;
          temperature_day = 6500;
          temperature_night = 6000;
        };

        backdrop.enabled = true;

        lockscreen.blurred_desktop = true;

        wallpaper.transition_on_startup = true;

        idle.behavior = {
          lock = {
            enabled = true;
            timeout = 900;
            action = "lock";
          };
          screen-off = {
            enabled = true;
            timeout = 1200;
            action = "screen_off";
          };
          lock-and-suspend = {
            enabled = true;
            timeout = 1500;
            action = "lock_and_suspend";
          };
        };

        wallpaper.automation = {
          enabled = true;
          interval_seconds = 900;
          order = "random";
          recursive = true;
        };

        bar.default = {
          position = "top";
          auto_hide = false;
          smart_auto_hide = true;
          contact_shadow = true;
          reserve_space = false;
          background_opacity = opacity;
          compositor_blur = true;

          # Keep the control center at the right end.
          end = [
            "media"
            "tray"
            "notifications"
            "clipboard"
            "network"
            "weather"
            "bluetooth"
            "power-profile"
            "volume"
            "brightness"
            "nightlight"
            "battery"
            "privacy"
            "sysmon"
            "keyboard-layout"
            "session"
            "control-center"
          ];
        };
        dock = {
          enabled = true;
          position = "right";
          auto_hide = false;
          smart_auto_hide = true;
          reserve_space = false;
          background_opacity = opacity;
          compositor_blur = true;
        };
        notification.background_opacity = opacity;
        osd.background_opacity = opacity;

        shell.panel.transparency_mode = "glass";

        desktop_widgets = {
          enabled = true;
          widget_order = [
            "desktop-weather"
            "desktop-clock"
            "desktop-sysmon"
          ];
          widget = {
            "desktop-weather" = {
              type = "weather";
              cx = 220.0;
              cy = 140.0;
              box_width = 360.0;
              box_height = 140.0;
            };
            "desktop-clock" = {
              type = "clock";
              cx = 3620.0;
              cy = 2060.0;
              box_width = 360.0;
              box_height = 120.0;
              settings.format = "{:%H:%M}";
            };
            "desktop-sysmon" = {
              type = "sysmon";
              cx = 220.0;
              cy = 2030.0;
              box_width = 360.0;
              box_height = 180.0;
              settings.stat2 = "ram_pct";
            };
          };
        };

        lockscreen_widgets = {
          enabled = true;
          widget_order = [ "lockscreen-clock" ];
          widget = {
            "lockscreen-clock" = {
              type = "clock";
              cx = 1920.0;
              cy = 1080.0;
              box_width = 360.0;
              box_height = 120.0;
              settings = {
                format = "{:%H:%M}";
                center_text = true;
              };
            };
          };
        };
      };
    };

    # Restart after time zone changes.
    systemd.user.services.noctalia.Unit.X-Restart-Triggers = lib.optional (
      config.time.timeZone != null
    ) config.time.timeZone;
  };
}
