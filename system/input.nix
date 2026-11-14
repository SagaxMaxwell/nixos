{ config, pkgs, ... }:

let
  # Pin the snapshot and hash; upstream LTS assets can be replaced.
  wanxiangGram = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "rime-wanxiang-gram";
    version = "20261112153433";

    src = pkgs.fetchurl {
      url = "https://github.com/OrdChaos/RIME-LMDG.snapshot/releases/download/${finalAttrs.version}/wanxiang-lts-zh-hans.gram";
      hash = "sha256-ZRKIPE7AwgFb7sqQcV1NzXQ2ctg1iAxp6YGKaIYJuhk=";
    };

    dontUnpack = true;

    installPhase = ''
      runHook preInstall
      install -Dm444 "$src" "$out/share/rime-data/wanxiang-lts-zh-hans.gram"
      runHook postInstall
    '';

    meta = {
      description = "Wanxiang LTS grammar model for Rime";
      homepage = "https://github.com/amzxyz/RIME-LMDG";
      license = pkgs.lib.licenses.cc-by-40;
    };
  });

  rimeDataPkgs = [
    pkgs.rime-wanxiang
    wanxiangGram
  ];

  defaultCustom = (pkgs.formats.yaml { }).generate "rime-default.custom.yaml" {
    patch = {
      __include = "wanxiang_suggested_default:/";
      schema_list = [ { schema = "wanxiang"; } ];
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

  home-manager.users.maxwell.xdg = {
    configFile."fcitx5/profile".source = (pkgs.formats.ini { }).generate "fcitx5-profile" {
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

    dataFile."fcitx5/rime/default.custom.yaml".source = defaultCustom;

    # Track store paths because Rime's timestamp checks can miss updates.
    dataFile."fcitx5/rime/.nix-deployment-fingerprint" = {
      text = builtins.toString ([ defaultCustom ] ++ rimeDataPkgs);
      onChange = ''
        rm -rf -- "${config.home-manager.users.maxwell.xdg.dataHome}/fcitx5/rime/build"
        echo "Rime cache cleared; restart Fcitx5 to redeploy." >&2
      '';
    };
  };
}
