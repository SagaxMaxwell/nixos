{ lib, pkgs, ... }:

let

  # Use the standard font installer.
  mkFont =
    {
      pname,
      version,
      sources,
      license ? lib.licenses.ofl,
    }:
    pkgs.stdenvNoCC.mkDerivation {
      inherit pname version;
      src = pkgs.linkFarm "${pname}-sources" (
        map (source: {
          inherit (source) name;
          path = pkgs.fetchurl source;
        }) sources
      );
      nativeBuildInputs = [ pkgs.installFonts ];
      dontBuild = true;
      meta = {
        inherit license;
        platforms = lib.platforms.all;
      };
    };

  # Install upstream font archives.
  mkFontArchive =
    {
      pname,
      version,
      url,
      hash,
    }:
    pkgs.stdenvNoCC.mkDerivation {
      inherit pname version;
      src = pkgs.fetchurl { inherit url hash; };
      nativeBuildInputs = [
        pkgs.unzip
        pkgs.installFonts
      ];
      sourceRoot = ".";
      dontBuild = true;
      meta = {
        license = lib.licenses.ofl;
        platforms = lib.platforms.all;
      };
    };

  extraFonts = {
    maple-mono-nf = mkFontArchive {
      pname = "maple-mono-nf";
      version = "8.0-beta.3";
      url = "https://github.com/subframe7536/maple-font/releases/download/v8.0-beta.3/MapleMono-NF-VF.zip";
      hash = "sha256-uzydYW868FVeuC6/wC28FqssWdLNVHHS+BXFU6+YPUE=";
    };

    maple-mono-nf-cn = mkFontArchive {
      pname = "maple-mono-nf-cn";
      version = "8.0-beta.3";
      url = "https://github.com/subframe7536/maple-font/releases/download/v8.0-beta.3/MapleMono-NF-CN-VF.zip";
      hash = "sha256-BVd6/BuJZpw2Qr8OK+dkpZGWeE4ODqfkRPcDwpUPpps=";
    };

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

    chiron-hei = mkFont {
      pname = "chiron-hei";
      version = "2.609";
      sources = [
        {
          name = "ChironHeiHKVF.otf";
          url = "https://raw.githubusercontent.com/chiron-fonts/chiron-hei-hk/v2.609/VAR_OTF/ChironHeiHKVF.otf";
          hash = "sha256-audsxR4DOouoPRO4JhGGcGtgGamezdhRlQC13aVqtT4=";
        }
        {
          name = "ChironHeiHKItVF.otf";
          url = "https://raw.githubusercontent.com/chiron-fonts/chiron-hei-hk/v2.609/VAR_OTF/ChironHeiHKItVF.otf";
          hash = "sha256-dnXqPvJ5UN3nsmRZwu8C/W8p1nDCWXm0xJBUOXg0qDc=";
        }
      ];
    };

    chiron-sung = mkFont {
      pname = "chiron-sung";
      version = "1.024";
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
    "Inter"
    "Source Han Sans SC VF"
    "Chiron Hei HK VF"
  ];
  serif = [
    "Amstelvar Roman"
    "Roboto Serif"
    "Source Han Serif SC VF"
    "Chiron Sung HK VF"
  ];
  mono = [
    "Monaspace Neon Var"
    "Cascadia Code NF"
    "Maple Mono NF"
    "Maple Mono NF CN"
    "Recursive"
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
      "Honk"
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
        (google-fonts.override {
          fonts = [
            "Roboto Serif"
            "Inter"
            "Recursive"
            "Shantell Sans"
            "Playwrite US Modern"
            "Nabla"
            "Honk"
            "STIX Two Math"
          ];
        })
        monaspace.variable
        (cascadia-code.override { useVariableFont = true; })
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
        ${builtins.head mono}.accept = builtins.tail mono;
      };

      confPackages = [
        (pkgs.writeTextDir "etc/fonts/conf.d/54-font-families.conf" ''
          <?xml version="1.0"?>
          <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
          <fontconfig>

            <match target="pattern">
              <test name="family"><string>Amstelvar Roman</string></test>
              <test name="slant" compare="more_eq"><const>italic</const></test>
              <edit name="family" mode="assign" binding="same"><string>Amstelvar</string></edit>
            </match>

            <match target="font">
              <test name="family"><string>Recursive</string></test>
              <edit name="fontvariations" mode="append"><string>MONO=1</string></edit>
            </match>

            <match target="font">
              <test name="family"><string>Monaspace Neon Var</string></test>
              <edit name="fontfeatures" mode="append"><string>calt=1</string></edit>
            </match>

            <match target="font">
              <test target="pattern" name="family"><string>ui-rounded</string></test>
              <test name="family"><string>Google Sans Flex</string></test>
              <edit name="fontvariations" mode="append"><string>ROND=100</string></edit>
            </match>

            <match target="font">
              <test target="pattern" name="family"><string>ui-rounded</string></test>
              <test name="family"><string>Alimama FangYuanTi VF</string></test>
              <edit name="fontvariations" mode="append"><string>BEVL=100</string></edit>
            </match>
          </fontconfig>
        '')
      ];
    };
  };

  home-manager.users.maxwell.gtk = {
    enable = true;
    font = {
      name = builtins.head sans;
      size = 11;
    };
  };
}
