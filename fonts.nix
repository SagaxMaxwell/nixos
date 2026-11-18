{ lib, pkgs, ... }:

let

  # Install upstream font binaries without rebuilding them.
  mkFont =
    {
      pname,
      version,
      sources,
      format ? "ttf",
      license ? lib.licenses.ofl,
    }:
    pkgs.runCommand "${pname}-${version}"
      {
        meta = {
          inherit license;
          platforms = lib.platforms.all;
        };
      }
      (
        ''
          fontDir="$out/share/fonts/${if format == "otf" then "opentype" else "truetype"}"
          mkdir -p "$fontDir"
        ''
        + lib.concatImapStringsSep "\n" (index: source: ''
          install -m444 ${pkgs.fetchurl source} "$fontDir/${pname}-${toString index}.${format}"
        '') sources
      );

  # Pin extra font packages.
  extraFonts = {
    alimama-fangyuan = mkFont {
      pname = "alimama-fangyuan";
      version = "1.004-beta";
      license = lib.licenses.unfree;
      sources = [
        {
          name = "AlimamaFangYuanTiVF.ttf";
          url = "https://fonts.alibabadesign.com/AlimamaFangYuanTiVF/AlimamaFangYuanTiVF-Thin/AlimamaFangYuanTiVF-Thin.ttf";
          hash = "sha256-xz1Ubip19BhJRPNyzdQWd5mf591T/GbGkNxfAfmQAs8=";
          curlOptsList = [
            "--referer"
            "https://www.alibabafonts.com/"
          ];
        }
      ];
    };

    amstelvar = mkFont {
      pname = "amstelvar";
      version = "unstable-f44f670";
      sources = [
        {
          name = "amstelvar-1.ttf";
          url = "https://raw.githubusercontent.com/googlefonts/amstelvar-beta/f44f670affec72a37c69a1bf103bddc044020f49/fonts/Amstelvar-Italic%5BGRAD%2CYOPQ%2CYTAS%2CYTDE%2CYTFI%2CYTLC%2CYTUC%2Cwdth%2Cwght%2Copsz%5D.ttf";
          hash = "sha256-5BDITis9IQt1JKCP4WpFgkcyFpEIao1O8/sCT9RKsZI=";
        }
        {
          name = "amstelvar-2.ttf";
          url = "https://raw.githubusercontent.com/googlefonts/amstelvar-beta/f44f670affec72a37c69a1bf103bddc044020f49/fonts/Amstelvar-Roman%5BGRAD%2CXOPQ%2CXTRA%2CYOPQ%2CYTAS%2CYTDE%2CYTFI%2CYTLC%2CYTUC%2Cwdth%2Cwght%2Copsz%5D.ttf";
          hash = "sha256-WwcI+7sGnhJ65i0Be9A7653Z3WG8B7dI9lCKf82QFmI=";
        }
      ];
    };

    google-sans-flex = mkFont {
      pname = "google-sans-flex";
      version = "unstable-7af0d90";
      sources = [
        {
          name = "google-sans-flex-1.ttf";
          url = "https://raw.githubusercontent.com/google/fonts/7af0d90b4d532ffa4b041937b560c6df4e7b1e95/ofl/googlesansflex/GoogleSansFlex%5BROND%2Copsz%2Cslnt%2Cwdth%2Cwght%5D.ttf";
          hash = "sha256-qax3B5iFfV6KxZPO1Csi5Ap8CM7Jgxn5Kw7Mwng6d7o=";
        }
      ];
    };

    playwrite = mkFont {
      pname = "playwrite";
      version = "unstable-7af0d90";
      sources = [
        {
          name = "playwrite-1.ttf";
          url = "https://raw.githubusercontent.com/google/fonts/7af0d90b4d532ffa4b041937b560c6df4e7b1e95/ofl/playwriteusmodern/PlaywriteUSModern%5Bwght%5D.ttf";
          hash = "sha256-E1Ihmohn4E4lcn7GPTViHXBLYnp+tb8n19b3l04dOy0=";
        }
      ];
    };

    nabla = mkFont {
      pname = "nabla";
      version = "unstable-7af0d90";
      sources = [
        {
          name = "nabla-1.ttf";
          url = "https://raw.githubusercontent.com/google/fonts/7af0d90b4d532ffa4b041937b560c6df4e7b1e95/ofl/nabla/Nabla%5BEDPT%2CEHLT%5D.ttf";
          hash = "sha256-5FzsYOsgmbS0/+6OvgBdHTBgdxBx7eHK7usS43osAK4=";
        }
      ];
    };

    noto-colrv1 = mkFont {
      pname = "noto-colrv1";
      version = "2.051";
      sources = [
        {
          name = "noto-colrv1-1.ttf";
          url = "https://raw.githubusercontent.com/googlefonts/noto-emoji/v2.051/fonts/Noto-COLRv1.ttf";
          hash = "sha256-CuV/5YZFY4UjujXziNk3OdKSU5qay4TfVwDIGx4aKNI=";
        }
      ];
    };

    openmoji-colrv1 = mkFont {
      pname = "openmoji-colrv1";
      version = "17.0.0";
      license = lib.licenses.cc-by-sa-40;
      sources = [
        {
          name = "openmoji-colrv1-1.ttf";
          url = "https://raw.githubusercontent.com/hfg-gmuend/openmoji/17.0.0/font/OpenMoji-color-glyf_colr_1/OpenMoji-color-glyf_colr_1.ttf";
          hash = "sha256-tshuPZX1V9rpp9WamTtabyJ0xAHW2XV0fUNhLG+rI20=";
        }
      ];
    };

    chiron-sung = mkFont {
      pname = "chiron-sung";
      version = "1.024";
      format = "otf";
      sources = [
        {
          name = "ChironSungHKVF.otf";
          url = "https://raw.githubusercontent.com/chiron-fonts/chiron-sung-hk/v1.024/VAR_OTF/ChironSungHKVF.otf";
          hash = "sha256-DREqGueO02ZyVhcTFzrXAYCqx23pnnXRUXhI5e9+pjs=";
        }
        {
          name = "ChironSungHKItVF.otf";
          url = "https://raw.githubusercontent.com/chiron-fonts/chiron-sung-hk/v1.024/VAR_OTF/ChironSungHKItVF.otf";
          hash = "sha256-9Q8PTBrPSA2arAzlwi/uXhpOv+QBZ8IDgoYlytoID4Y=";
        }
      ];
    };

    wenyuan-rounded = mkFont {
      pname = "wenyuan-rounded";
      version = "1.110";
      format = "otf";
      sources = [
        {
          name = "WenYuanRoundedSCVF.otf";
          url = "https://github.com/takushun-wu/WenYuanFonts/releases/download/v1.110/WenYuanRoundedSCVF.otf";
          hash = "sha256-bpcJielK1qyvpl6PJbHoB2c28qtpt09L80mE7CT85H8=";
        }
      ];
    };
  };

  sans = [
    "Roboto Flex"
    "Google Sans Flex"
    "Source Han Sans SC VF"
  ];
  serif = [
    "Amstelvar Roman"
    "Roboto Serif"
    "Source Han Serif SC VF"
    "Chiron Sung HK VF"
  ];
  mono = [
    "Monaspace Neon Var"
    "Recursive Mono Linear Static"
    "Sarasa Mono SC"
    "Sarasa Term SC"
  ];

  aliases = {
    system-ui = sans;
    ui-sans-serif = sans;
    ui-serif = serif;
    ui-monospace = mono;
    ui-rounded = [
      "Google Sans Flex"
      "Alimama FangYuanTi VF"
      "WenYuan Rounded SC VF"
    ];
    cursive = [
      "Shantell Sans"
      "Playwrite US Modern"
      "LXGW WenKai"
    ];
    fantasy = [
      "Nabla"
      "Alimama FangYuanTi VF"
      "Smiley Sans"
    ];
    math = [ "STIX Two Math" ];
  };
in
{
  fonts = {
    enableDefaultPackages = false;

    packages =
      with pkgs;
      [
        roboto-flex
        roboto-serif
        monaspace.variable
        recursive
        shantell-sans
        stix-two
        source-han-sans-vf-ttf
        source-han-serif-vf-ttf
        sarasa-gothic
        lxgw-wenkai
        smiley-sans
      ]
      ++ builtins.attrValues extraFonts;

    fontconfig = {
      antialias = true;
      hinting.style = "slight";
      useEmbeddedBitmaps = false;

      subpixel = {
        rgba = "rgb";
        lcdfilter = "default";
      };

      defaultFonts = {
        sansSerif = sans;
        inherit serif;
        monospace = mono;
        emoji = [
          "Noto Color Emoji"
          "OpenMoji"
        ];
      };

      aliases = lib.mapAttrs (_: prefer: { inherit prefer; }) aliases // {

        # Preserve CJK fallback for explicit application fonts.
        "Roboto Flex".accept = builtins.tail sans;
        "Amstelvar Roman".accept = builtins.tail serif;
        "Monaspace Neon Var".accept = builtins.tail mono;
      };

      confPackages = [
        (pkgs.writeTextDir "etc/fonts/conf.d/54-font-features.conf" ''
          <?xml version="1.0"?>
          <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
          <fontconfig>

            <!-- Select Amstelvar's separate italic family after aliases. -->
            <match target="pattern">
              <test name="family"><string>Amstelvar Roman</string></test>
              <test name="slant" compare="more_eq"><const>italic</const></test>
              <edit name="family" mode="assign" binding="same"><string>Amstelvar</string></edit>
            </match>

            <!-- Use the rounded axis only for rounded UI requests. -->
            <match target="pattern">
              <test name="family"><string>ui-rounded</string></test>
              <edit name="fontvariations" mode="append"><string>ROND=100</string></edit>
            </match>

            <!-- Enable standard OpenType shaping features. -->
            <match target="font">
              <edit name="fontfeatures" mode="append">
                <string>kern=1</string>
                <string>liga=1</string>
                <string>clig=1</string>
                <string>calt=1</string>
              </edit>
            </match>
          </fontconfig>
        '')
      ];
    };
  };

  home-manager.users.maxwell = {
    gtk = {
      enable = true;
      font = {
        name = builtins.head sans;
        size = 11;
      };
    };

    programs = {
      noctalia.settings.shell.font_family = builtins.head sans;

      ghostty.settings = {
        font-family = builtins.head mono;
        font-feature = [
          "calt"
          "liga"
        ];
      };

      zed-editor.userSettings = {
        ui_font_family = builtins.head sans;
        buffer_font_family = builtins.head mono;
        ui_font_features = {
          calt = true;
          liga = true;
        };
        buffer_font_features = {
          calt = true;
          liga = true;
        };
      };
    };
  };
}
