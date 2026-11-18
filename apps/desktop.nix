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
      (blender.override { rocmSupport = true; })
      mission-center
      tabularis
    ];
  };

  programs = {
    mpv = {
      enable = true;
      config = {
        hwdec = "auto";
        background-color = "#${alpha}000000";
      };
      scripts = [ pkgs.mpvScripts.mpris ];
    };

    obsidian = {
      enable = true;
      cli.enable = true;

      vaults.notes = {
        target = "Documents/notes";
        settings.app.restrictedMode = false;
      };

      defaultSettings.communityPlugins = with pkgs.obsidianPlugins; [
        obsidian-linter
        {
          pkg = update-time;
          settings = {
            createdPropertyName = "date created";
            updatedPropertyName = "date updated";
          };
        }
        templater-obsidian
        dataview
        notebook-navigator
        jupyter-viewer
        advanced-canvas
        tldraw
      ];

      defaultSettings.themes = [ pkgs.obsidianThemes.border ];
    };

    google-chrome = {
      enable = true;
      commandLineArgs = [ "--enable-features=AcceleratedVideoEncoder" ];
    };
  };

  xdg = {
    mimeApps.defaultApplications = lib.genAttrs [
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
    ] (_: [ "mpv.desktop" ]);
  };
}
