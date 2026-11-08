{ pkgs, ... }:

{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        (fcitx5-rime.override { rimeDataPkgs = [ rime-ice ]; })
      ];
      settings.inputMethod = {
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
    };
  };

  home-manager.users.maxwell.xdg.configFile."fcitx5/rime/default.custom.yaml".source =
    (pkgs.formats.yaml { }).generate "rime-default.custom.yaml"
      {
        patch.schema_list = [ { schema = "rime_ice"; } ];
      };
}
