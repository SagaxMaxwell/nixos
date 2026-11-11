{
  config,
  lib,
  pkgs,
  strata,
  ...
}:

let
  palette = rec {
    primary = "#629EE8";
    onPrimary = "#182B45";
    secondary = primary;
    onSecondary = onPrimary;
    tertiary = primary;
    onTertiary = onPrimary;
    error = "#BA3547";
    onError = "#FFFFFF";
    surface = "#FFFFFF";
    onSurface = "#253244";
    surfaceVariant = "#F8FAFC";
    onSurfaceVariant = "#526174";
    outline = "#DCE4ED";
    shadow = "#CBD5E1";
    hover = "#E5F0FD";
    onHover = onPrimary;
    terminal = rec {
      background = surface;
      foreground = onSurface;
      cursor = onSurface;
      cursorText = surface;
      selectionBg = hover;
      selectionFg = onSurface;
      normal = {
        black = onSurface;
        red = error;
        green = "#347A54";
        yellow = "#8C681D";
        blue = "#316BB0";
        magenta = "#8655A6";
        cyan = "#267B8A";
        white = surfaceVariant;
      };
      bright = normal;
    };
  };
in
{
  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
  };

  services = {
    displayManager.noctalia-greeter.enable = true;
    gnome.gnome-keyring.enable = true;
    gvfs.enable = true;
    dbus.packages = [ strata.fileManagerService ];
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

    programs.noctalia = {
      enable = true;
      systemd.enable = true;
      customPalettes.WhiteBlue = lib.genAttrs [ "light" "dark" ] (_: palette);

      settings = {
        brightness.enable_ddcutil = true;

        theme = {
          mode = "auto";
          shell_mode = "light";
          source = "custom";
          custom_palette = "WhiteBlue";
        };

        wallpaper.fill_color = "surface";
        weather.enabled = false;
        notification.background_opacity = 0.8;
        osd.background_opacity = 0.8;

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
          font_family = "IBM Plex Sans";
          panel = {
            transparency_mode = "soft";
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
