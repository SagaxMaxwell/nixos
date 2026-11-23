{
  config,
  lib,
  pkgs,
  alpha,
  ...
}:

{
  home = {
    activation.tabularisAppearance = lib.hm.dag.entryAfter [ "linkGeneration" ] (
      lib.hm.generators.mkImpureConfigMerger {
        inherit pkgs;
        format = "json";
        empty = "{}";
        jqOperation = "$dynamic * $static";
        path = "${config.xdg.configHome}/tabularis/config.json";
        staticSettings = (pkgs.formats.json { }).generate "tabularis-appearance.json" {
          followSystemTheme = true;
        };
      }
    );

    packages = with pkgs; [
      anytype
      anime4k
      (blender.override { rocmSupport = true; })
      loupe
      mission-center
      papers
      syncplay
      tabularis
    ];
  };

  programs = {
    mpv = {
      enable = true;
      config = {
        hwdec = "auto";
        osc = false;
        vo = "gpu-next";
        gpu-api = "auto";
        background-color = "#${alpha}000000";
      };
      scripts = with pkgs.mpvScripts; [
        autosubsync-mpv
        mpris
        skipsilence
        smartskip
        sponsorblock-minimal
        uosc
        thumbfast
      ];
    };

    google-chrome = {
      enable = true;
      commandLineArgs = [ "--enable-features=AcceleratedVideoEncoder" ];
    };
  };

  xdg = {
    mimeApps.defaultApplications =
      lib.genAttrs [
        "video/mp4"
        "video/x-matroska"
        "video/webm"
        "video/quicktime"
        "video/x-msvideo"
        "video/mpeg"
        "video/ogg"
        "video/mp2t"
        "video/x-flv"
        "video/x-ms-wmv"
      ] (_: [ "mpv.desktop" ])
      // lib.genAttrs [
        "image/avif"
        "image/bmp"
        "image/gif"
        "image/heic"
        "image/heif"
        "image/jpeg"
        "image/jxl"
        "image/png"
        "image/svg+xml"
        "image/tiff"
        "image/webp"
      ] (_: [ "org.gnome.Loupe.desktop" ])
      // lib.genAttrs [
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        "application/vnd.openxmlformats-officedocument.presentationml.presentation"
      ] (_: [ "jp.ne.ibis.ibisOffice.desktop" ]);
  };
}
