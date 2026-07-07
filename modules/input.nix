{ config, pkgs, ... }:

{
  i18n.inputMethod = {
    enable = true;
    type = config.local.inputMethod.type;

    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        qt6Packages.fcitx5-chinese-addons
        fcitx5-gtk
        qt6Packages.fcitx5-qt
        qt6Packages.fcitx5-configtool
      ];
    };
  };
}
