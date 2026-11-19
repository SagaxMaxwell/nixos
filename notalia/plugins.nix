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

  source = pkgs.fetchFromGitHub {
    owner = "noctalia-dev";
    repo = "official-plugins";
    rev = "5dc1d19b1aa6be331ee6506034dc8448aca5c446";
    hash = "sha256-JQDsY3fmpL57cqG1aCcLJablwTfcwIIJ44BtXj/sowE=";
  };

  plugins = pkgs.linkFarm "noctalia-official-plugins" (
    map (name: {
      inherit name;
      path = "${source}/${name}";
    }) names
  );
in
{
  home-manager.users.maxwell = {
    programs.noctalia.settings.plugin_settings."noctalia/screen_recorder".video_encoder = "gpu";

    programs.noctalia.settings.plugins = {
      enabled = map (name: "noctalia/${name}") names;
      auto_update = "none";
      source = [
        {
          name = "nix-official";
          kind = "path";
          location = "${plugins}";
          enabled = true;
        }
        {
          name = "official";
          kind = "git";
          location = "https://github.com/noctalia-dev/official-plugins";
          enabled = false;
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
      evtest
      gpu-screen-recorder
      mpvpaper
      python3
      slurp
      socat
    ];
  };
}
