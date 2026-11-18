{
  config,
  lib,
  pkgs,
  opacity,
  alpha,
  ...
}:

{
  imports = [
    ./helix.nix
    ./zed.nix
  ];

  home = {
    stateVersion = "26.05";

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

      # Nix tools.
      nix-output-monitor
      nix-tree
      nixd
      nixfmt

      # CLI tools.
      gh
      oxfmt
      ruff
      ty
      xh
      wireguard-tools

      # Development tools.
      rustup

      # Desktop apps.
      (blender.override { rocmSupport = true; })
      mission-center
      tabularis
    ];
  };

  programs = {

    # Shells.
    bash.enable = true;

    nushell = {
      enable = true;
      loadSessionVariables = true;
    };

    # Shell environment.
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    starship.enable = true;

    # CLI tools.
    bat.enable = true;
    eza.enable = true;
    fd.enable = true;
    ripgrep.enable = true;
    tealdeer.enable = true;
    atuin.enable = true;

    bottom = {
      enable = true;

      # Follow the terminal palette.
      settings.styles = {
        widgets = {
          text = "reset";
          widget_title = "reset";
          border_color = "reset";
        };
        graphs = {
          graph_color = "reset";
          legend_text = "reset";
        };
      };
    };

    yazi.enable = true;

    zoxide.enable = true;

    # Development tools.
    bun.enable = true;

    claude-code = {
      enable = true;
      mutableSettings = true;
      settings.theme = "auto";
    };

    codex.enable = true;

    herdr = {
      enable = true;
      mutableSettings = true;
      settings = {
        theme.auto_switch = true;
        session.resume_agents_on_restore = true;
        remote.manage_ssh_config = true;
        terminal.default_shell = "nu";
        terminal.kitty_graphics = true;
        worktrees.directory = "~/.herdr/worktrees";
        ui.toast.delivery = "herdr";
        ui.toast.delay_seconds = 0;
        ui.sound.enabled = true;
        experimental.pane_history = true;
      };
    };

    difftastic = {
      enable = true;
      git = {
        enable = true;
        mode = "difftool";
      };
    };

    git = {
      enable = true;
      settings.user = {
        name = "maxwellsagax";
        email = "sagax.maxwell@gmail.com";
      };
    };

    ghostty = {
      enable = true;
      settings = {
        theme = "noctalia";
        background-opacity = opacity;
        background-opacity-cells = true;
        background-blur = true;
      };
    };

    nix-index-database.comma.enable = true;

    uv.enable = true;

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
    enable = true;

    autostart = {
      enable = true;
      entries = [
        "${config.programs.ghostty.package}/share/applications/com.mitchellh.ghostty.desktop"
        "${config.programs.google-chrome.finalPackage}/share/applications/google-chrome.desktop"
      ];
    };

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
