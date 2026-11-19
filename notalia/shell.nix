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
        };
        location.auto_locate = true;

        idle.behavior = {
          lock = {
            enabled = true;
            timeout = 900;
          };
          screen-off = {
            enabled = true;
            timeout = 1200;
          };
          lock-and-suspend = {
            enabled = true;
            timeout = 1500;
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
            "bluetooth"
            "volume"
            "brightness"
            "battery"
            "session"
            "control-center"
          ];
        };
        dock = {
          enabled = true;
          position = "right";
          auto_hide = true;
          auto_hide_reveal_delay_ms = 500;
          reserve_space = false;
          background_opacity = opacity;
          compositor_blur = true;
        };
        notification.background_opacity = opacity;
        osd.background_opacity = opacity;

        # Soft panels use 0.8 background opacity upstream.
        shell.panel.transparency_mode = "soft";
      };
    };

    # Restart after time zone changes.
    systemd.user.services.noctalia.Unit.X-Restart-Triggers = lib.optional (
      config.time.timeZone != null
    ) config.time.timeZone;
  };
}
