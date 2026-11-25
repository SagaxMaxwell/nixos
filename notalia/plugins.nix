{ pkgs, ... }:

let
  names = [
    "example"
    "screen_recorder"
    "bongocat"
    "translator"
    "timer"
    "wallhaven"
    "mpvpaper"
    "kaomoji"
    "notes"
    "bitwarden"
    "world_clock"
    "wallpaper_depth"
    "umbriel-companion"
    "lyrics"
  ];

in
{
  home-manager.users.maxwell = {
    programs.noctalia.settings.plugin_settings."noctalia/screen_recorder".video_encoder = "gpu";

    programs.noctalia.settings.plugins = {
      enabled = map (name: "noctalia/${name}") names;
      auto_update = "official";
      source = [
        {
          name = "official";
          kind = "git";
          location = "https://github.com/noctalia-dev/official-plugins";
          enabled = true;
        }
        {
          name = "community";
          kind = "git";
          location = "https://github.com/noctalia-dev/community-plugins";
          enabled = false;
        }
      ];
    };

    home.packages = with pkgs; [
      bitwarden-cli
      libinput
      gpu-screen-recorder
      mpvpaper
      python3
      slurp
      socat
    ];
  };
}
