{ config, opacity, ... }:

{
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
}
