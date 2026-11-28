{
  lib,
  opacity,
  inputs,
  pkgs,
  ...
}:

let
  chromeAtLogin =
    chrome:
    pkgs.writeShellScript "chrome-at-login" ''
      data_dir="''${CHROME_USER_DATA_DIR:-''${CHROME_CONFIG_HOME:-''${XDG_CONFIG_HOME:-$HOME/.config}}/google-chrome}"

      # Extended preloading is a profile preference.
      if [[ ! -L "$data_dir/SingletonLock" ]]; then
        for prefs in "$data_dir"/{Default,Profile\ *}/Preferences; do
          [[ -f "$prefs" && ! -L "$prefs" ]] || continue
          (
            tmp=$(${lib.getExe' pkgs.coreutils "mktemp"} "$prefs.XXXXXX") || exit
            trap '${lib.getExe' pkgs.coreutils "rm"} -f "$tmp"' EXIT
            if ${lib.getExe pkgs.jq} -ce '
              select(type == "object")
              | (.account_values.net // {} | has("network_prediction_options")) as $has_account_pref
              | select(.net.network_prediction_options != 3 or
                  ($has_account_pref and .account_values.net.network_prediction_options != 3))
              | .net.network_prediction_options = 3
              | if $has_account_pref then .account_values.net.network_prediction_options = 3 else . end
            ' "$prefs" > "$tmp" && [[ ! -L "$data_dir/SingletonLock" ]]; then
              ${lib.getExe' pkgs.coreutils "mv"} -f "$tmp" "$prefs"
            fi
          )
        done
      fi

      exec ${chrome}
    '';
in
{
  programs.umbriel.enable = true;

  home-manager.users.maxwell = { config, ... }: {
    imports = [ "${inputs.umbriel}/nix/home-module.nix" ];

    programs.umbriel = {
      enable = true;

      # Extend the upstream starting configuration.
      settings =
        lib.recursiveUpdate (builtins.fromTOML (builtins.readFile "${inputs.umbriel}/examples/config.toml"))
          {
            keybinds."Mod+Return".action = "spawn ${lib.getExe config.programs.ghostty.package}";

            general = {
              xwayland_native_resolution = true;
              autostart = [
                (lib.getExe config.programs.ghostty.package)
                (toString (chromeAtLogin (lib.getExe config.programs.google-chrome.finalPackage)))
              ];
            };

            output."Philips 32M2N8900X" = {
              mode = "3840x2160@240";
              vrr = "fullscreen";
              hdr = "on";
              color_profile = "edid";
              sdr_transfer = "srgb";
              sdr_gamut = "srgb";
            };

            layout = {
              mode = "scrolling";
              gap = 8;

              # Cancel outer gaps while keeping window spacing.
              struts = {
                left = -8;
                right = -8;
                top = -8;
                bottom = -8;
              };

              extent_presets = [
                0.5
                0.7
                0.9
              ];
              scrolling = {
                default_extent_fraction = 0.7;
                center_underfull_strip = true;
              };
            };

            appearance = {
              border_width = 0;
              drag_opacity = opacity;
            };
          };
    };
  };
}
