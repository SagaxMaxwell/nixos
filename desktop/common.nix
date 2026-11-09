{
  config,
  lib,
  pkgs,
  strata,
  ...
}:

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
