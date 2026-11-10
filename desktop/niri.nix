{
  lib,
  pkgs,
  ...
}:

let
  defaultNiriConfig = builtins.readFile "${pkgs.niri.src}/resources/default-config.kdl";
  niriDefaults = pkgs.writeText "niri-defaults.kdl" (
    lib.replaceStrings [ ''spawn-at-startup "waybar"'' ] [ "" ] defaultNiriConfig
  );
in

{
  imports = [ ./common.nix ];

  programs.niri = {
    enable = true;
    useNautilus = false;
  };

  services.displayManager.noctalia-greeter.settings.session.default = "niri";

  # GNOME's accent-color would regenerate COSMIC's custom theme.
  xdg.portal.config.niri."org.freedesktop.impl.portal.Settings" = "gtk";

  home-manager.users.maxwell = {
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
          background-color = "#ffffff";
          default-column-width.proportion = 0.7;
          preset-column-widths._children = [
            { proportion = 0.5; }
            { proportion = 0.7; }
            { proportion = 1.0; }
          ];
          focus-ring = {
            width = 2;
            active-color = "#629ee8";
            inactive-color = "#dce4ed";
          };
        };

        overview.backdrop-color = "#f8fafc";
        blur.passes = 2;
        layer-rule = {
          match._props.namespace = "^noctalia-";
          background-effect.xray = false;
        };
        # Clients without native ext-background-effect requests.
        window-rule = {
          match._props.app-id = "^(dev\\.zed\\.Zed|org\\.sheprd\\.Sheprd|mpv)$";
          background-effect = {
            blur = true;
            xray = false;
          };
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
  };
}
