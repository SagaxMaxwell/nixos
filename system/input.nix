{ pkgs, ... }:

let

  # Use the bundled Rime Ice data.
  rimeDataPkgs = [ pkgs.rime-ice ];

  defaultCustom = (pkgs.formats.yaml { }).generate "rime-default.custom.yaml" {
    patch = {
      __include = "rime_ice_suggestion:/";
      schema_list = [ { schema = "rime_ice"; } ];
    };
  };
in
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      settings.addons.classicui.globalSection.UseDarkTheme = true;
      addons = [
        (pkgs.fcitx5-rime.override { inherit rimeDataPkgs; })
      ];
    };
  };

  home-manager.users.maxwell = { config, ... }: {
    xdg.configFile."fcitx5/profile".source = (pkgs.formats.ini { }).generate "fcitx5-profile" {
      "Groups/0" = {
        Name = "Default";
        "Default Layout" = "us";
        DefaultIM = "rime";
      };
      "Groups/0/Items/0" = {
        Name = "keyboard-us";
        Layout = "us";
      };
      "Groups/0/Items/1".Name = "rime";
      GroupOrder."0" = "Default";
    };

    xdg.dataFile."fcitx5/rime/default.custom.yaml".source = defaultCustom;

    # Track Rime data changes.
    xdg.dataFile."fcitx5/rime/.nix-deployment-fingerprint" = {
      text = builtins.toString ([ defaultCustom ] ++ rimeDataPkgs);
      onChange = ''
        rm -rf -- "${config.xdg.dataHome}/fcitx5/rime/build"
        echo "Rime cache cleared; restart Fcitx5 to redeploy." >&2
      '';
    };
  };
}
