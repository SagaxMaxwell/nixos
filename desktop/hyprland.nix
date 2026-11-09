{ lib, ... }:

let
  bind = key: action: options: {
    _args = [
      key
      (lib.generators.mkLuaInline "hl.dsp.${action}")
    ]
    ++ lib.optional (options != { }) options;
  };
in
{
  imports = [ ./common.nix ];

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  services.displayManager.noctalia-greeter.settings.session.default = "hyprland-uwsm";

  xdg.portal.config.hyprland = {
    default = [
      "hyprland"
      "gtk"
    ];
    "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
  };

  home-manager.users.maxwell.wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    systemd.enable = false;

    settings = {
      monitor = {
        output = "";
        mode = "highres";
        position = "auto";
        scale = "auto";
      };

      config = {
        general = {
          gaps_in = 6;
          gaps_out = 12;
          col.active_border = "rgba(16fff9ff)";
        };
        misc.vrr = 2;
      };

      layer_rule = {
        name = "noctalia";
        match.namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$";
        no_anim = true;
      };

      window_rule = [
        {
          name = "noctalia-settings";
          match.class = "dev.noctalia.Noctalia";
          float = true;
        }
        {
          name = "fix-xwayland-drags";
          match = {
            class = "^$";
            title = "^$";
            xwayland = true;
            float = true;
            fullscreen = false;
            pin = false;
          };
          no_focus = true;
        }
      ];

      # Upstream default keys; only launch commands change.
      bind =
        lib.mapAttrsToList (key: action: bind key action { }) {
          "SUPER + Q" = ''exec_cmd("ghostty")'';
          "SUPER + C" = "window.close()";
          "SUPER + M" = ''exec_cmd("uwsm stop")'';
          "SUPER + E" = ''exec_cmd("strata")'';
          "SUPER + V" = ''window.float({ action = "toggle" })'';
          "SUPER + R" = ''exec_cmd("noctalia msg panel-toggle launcher")'';
          "SUPER + P" = "window.pseudo()";
          "SUPER + J" = ''layout("togglesplit")'';
          "SUPER + S" = ''workspace.toggle_special("magic")'';
          "SUPER + SHIFT + S" = ''window.move({ workspace = "special:magic" })'';
          "SUPER + mouse_down" = ''focus({ workspace = "e+1" })'';
          "SUPER + mouse_up" = ''focus({ workspace = "e-1" })'';
        }
        ++ map (direction: bind "SUPER + ${direction}" ''focus({ direction = "${direction}" })'' { }) [
          "left"
          "right"
          "up"
          "down"
        ]
        ++ lib.concatMap (
          workspace:
          let
            key = toString (lib.mod workspace 10);
          in
          [
            (bind "SUPER + ${key}" "focus({ workspace = ${toString workspace} })" { })
            (bind "SUPER + SHIFT + ${key}" "window.move({ workspace = ${toString workspace} })" { })
          ]
        ) (lib.range 1 10)
        ++ [
          (bind "SUPER + mouse:272" "window.drag()" { mouse = true; })
          (bind "SUPER + mouse:273" "window.resize()" { mouse = true; })
        ]
        ++
          lib.mapAttrsToList
            (
              key: command:
              bind key ''exec_cmd("noctalia msg ${command}")'' {
                locked = true;
                repeating = true;
              }
            )
            {
              XF86AudioRaiseVolume = "volume-up 5";
              XF86AudioLowerVolume = "volume-down 5";
              XF86AudioMute = "volume-mute";
              XF86AudioMicMute = "mic-mute";
              XF86MonBrightnessUp = "brightness-up 5";
              XF86MonBrightnessDown = "brightness-down 5";
            }
        ++
          lib.mapAttrsToList
            (
              key: command:
              bind key ''exec_cmd("noctalia msg media ${command}")'' {
                locked = true;
              }
            )
            {
              XF86AudioNext = "next";
              XF86AudioPause = "toggle";
              XF86AudioPlay = "toggle";
              XF86AudioPrev = "previous";
            };
    };
  };
}
