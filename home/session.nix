{
  lib,
  pkgs,
  osConfig,
  ...
}:

let
  defaultNiriConfig = builtins.readFile "${pkgs.niri.src}/resources/default-config.kdl";
  niriDefaults = pkgs.writeText "niri-defaults.kdl" (
    lib.replaceStrings [ ''spawn-at-startup "waybar"'' ] [ "" ] defaultNiriConfig
  );
in

{
  systemd.user.services.noctalia.Unit.X-Restart-Triggers = lib.optional (
    osConfig.time.timeZone != null
  ) osConfig.time.timeZone;

  services.way-displays = {
    enable = true;
    systemdTarget = "niri.service";
    settings.MAX_PREFERRED_REFRESH = [ "!.*" ];
  };

  wayland.windowManager.niri = {
    enable = true;
    extraConfig = lib.mkBefore ''include "${niriDefaults}"'';
    systemd.enable = false;
    portalPackage = null;

    settings = {
      input.focus-follows-mouse._props.max-scroll-amount = "0%";

      layout = {
        gaps = 12;
        default-column-width.proportion = 0.7;
        preset-column-widths._children = [
          { proportion = 0.5; }
          { proportion = 0.7; }
          { proportion = 1.0; }
        ];
        focus-ring.active-color = "#16fff9";
      };

      prefer-no-csd = { };

      binds = {
        "Mod+T" = {
          _props.hotkey-overlay-title = "Open a Terminal: Ghostty";
          spawn = [ "ghostty" ];
        };
        "Mod+D" = {
          _props.hotkey-overlay-title = "Run an Application: Noctalia";
          spawn = [
            "noctalia"
            "msg"
            "panel-toggle"
            "launcher"
          ];
        };
        "Super+Alt+L" = {
          _props.hotkey-overlay-title = "Lock the Screen: Noctalia";
          spawn = [
            "noctalia"
            "msg"
            "session"
            "lock"
          ];
        };
      }
      //
        lib.mapAttrs
          (_: args: {
            _props.allow-when-locked = true;
            spawn = [
              "noctalia"
              "msg"
            ]
            ++ args;
          })
          {
            "XF86AudioRaiseVolume" = [
              "volume-up"
              "10"
            ];
            "XF86AudioLowerVolume" = [
              "volume-down"
              "10"
            ];
            "XF86AudioMute" = [ "volume-mute" ];
            "XF86AudioMicMute" = [ "mic-mute" ];
            "XF86AudioPlay" = [
              "media"
              "toggle"
            ];
            "XF86AudioStop" = [
              "media"
              "stop"
            ];
            "XF86AudioPrev" = [
              "media"
              "previous"
            ];
            "XF86AudioNext" = [
              "media"
              "next"
            ];
            "XF86MonBrightnessUp" = [
              "brightness-up"
              "10"
            ];
            "XF86MonBrightnessDown" = [
              "brightness-down"
              "10"
            ];
          };
    };
  };

  programs.noctalia = {
    enable = true;
    systemd.enable = true;

    settings = {
      brightness.enable_ddcutil = true;

      nightlight = {
        enabled = true;
        temperature_night = 5500;
      };

      location = {
        custom_schedule = true;
        sunset = "22:00";
        sunrise = "07:00";
      };

      shell = {
        polkit_agent = true;
      };

      bar.default = {
        reserve_space = false;
        auto_hide = true;
        end = [
          "media"
          "tray"
          "notifications"
          "clipboard"
          "keyboard_layout"
          "network"
          "bluetooth"
          "volume"
          "brightness"
          "battery"
          "control-center"
          "session"
        ];
      };

      widget.keyboard_layout = {
        show_glyph = false;
      };

      widget.tray.hidden = [
        "fcitx"
        "org.fcitx.Fcitx5"
      ];

      idle.behavior = {
        lock = {
          enabled = true;
          timeout = 600;
          action = "lock";
        };
        screen-off = {
          enabled = true;
          timeout = 660;
          action = "screen_off";
        };
      };
    };
  };
}
