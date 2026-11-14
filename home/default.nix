{
  config,
  lib,
  pkgs,
  opacity,
  ...
}:

let

  # Hex alpha for #RRGGBBAA.
  alpha = lib.fixedWidthString 2 "0" (
    lib.toLower (lib.toHexString (builtins.floor (opacity * 255 + 0.5)))
  );
in
{
  home = {
    stateVersion = "26.05";

    activation.sheprdAppearance = lib.hm.dag.entryAfter [ "linkGeneration" ] (
      lib.hm.generators.mkImpureConfigMerger {
        inherit pkgs;
        format = "toml";
        empty = "{}";
        jqOperation = "$dynamic * $static";
        path = "${config.xdg.configHome}/herdr/config-gpui.local.toml";
        staticSettings = (pkgs.formats.toml { }).generate "sheprd.toml" {
          backdrop = {
            inherit opacity;
            blur = true;
          };
        };
      }
    );

    packages = with pkgs; [

      # Nix tooling.
      nix-output-monitor
      nix-tree
      nixd
      nixfmt

      # Command-line tools.
      gh
      oxfmt
      ruff
      ty
      xh

      # Development environments.
      rustup

      # GUI apps.
      (blender.override { rocmSupport = true; })
      sheprd
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

    # Command-line tools.
    bat.enable = true;

    eza.enable = true;

    fd.enable = true;

    ripgrep.enable = true;

    tealdeer.enable = true;

    atuin.enable = true;

    yazi.enable = true;

    zoxide.enable = true;

    # Development tools.
    bun.enable = true;

    claude-code.enable = true;

    codex.enable = true;

    herdr.enable = true;

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
        theme = "light:GitHub Light Default,dark:Atom One Dark";
        background-opacity = opacity;
        background-opacity-cells = true;
        background-blur = true;
      };
    };

    nix-index-database.comma.enable = true;

    uv.enable = true;

    # Editors.
    helix = {
      enable = true;
      extraPackages = [ pkgs.wl-clipboard ];

      settings = {
        theme = "onedark";

        editor = {
          "true-color" = true;
          "line-number" = "relative";
          cursorline = true;

          "end-of-line-diagnostics" = "hint";
          "inline-diagnostics" = {
            "cursor-line" = "warning";
          };

          statusline = {
            right = [
              "diagnostics"
              "separator"
              "selections"
              "register"
              "position"
              "file-encoding"
              "file-line-ending"
              "file-type"
            ];
            separator = "💤";

            mode = {
              normal = "🦄";
              insert = "🐣";
              select = "🐧";
            };
          };

          lsp = {
            "display-inlay-hints" = true;
          };

          "cursor-shape" = {
            insert = "bar";
            select = "underline";
          };

          "file-picker" = {
            hidden = false;
          };

          gutters = [
            "diff"
            "diagnostics"
            "line-numbers"
            "spacer"
          ];

          "soft-wrap" = {
            enable = true;
            "wrap-indicator" = "";
          };
        };
      };

      languages.language = [
        {
          name = "nix";
          "auto-format" = true;
          "language-servers" = [ "nixd" ];
          formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
        }
        {
          name = "python";
          "language-servers" = [
            "ty"
            "ruff"
          ];
        }
        {
          name = "toml";
          "language-servers" = [ "tombi" ];
        }
      ];

      languages.language-server.ty.command = "${pkgs.ty}/bin/ty";
      languages.language-server.ruff.command = "${pkgs.ruff}/bin/ruff";
      languages.language-server.rust-analyzer.command = "${pkgs.rust-analyzer}/bin/rust-analyzer";
      languages.language-server.tombi.command = "${pkgs.tombi}/bin/tombi";
    };

    zed-editor = {
      enable = true;

      # Apply alpha once; nested surfaces stay clear.
      userSettings.theme_overrides =
        lib.mapAttrs
          (
            _: background:
            {
              "background.appearance" = "blurred";
              inherit background;
              "title_bar.background" = background;
              "title_bar.inactive_background" = background;
              "status_bar.background" = background;
            }
            // lib.genAttrs [
              "editor.background"
              "editor.gutter.background"
              "panel.background"
              "terminal.background"
              "toolbar.background"
              "tab_bar.background"
              "tab.active_background"
              "tab.inactive_background"
            ] (_: "#00000000")
          )
          {
            "One Light" = "#fafafa${alpha}";
            "One Dark" = "#282c33${alpha}";
          };
      userSettings.auto_install_extensions = {
        nix = true;
        oxc = true;
        tombi = true;
        toml = false;
        github-theme = false;
      };
      userSettings.diagnostics.inline.enabled = true;
      userSettings.autosave = "on_window_change";
      userSettings.format_on_save = "on";
      userSettings.lsp.nixd.binary.path = "${pkgs.nixd}/bin/nixd";
      userSettings.lsp.oxfmt.binary = {
        path = "${pkgs.oxfmt}/bin/oxfmt";
        arguments = [ "--lsp" ];
      };
      userSettings.lsp.oxlint.initialization_options.settings.fixKind = "safe_fix";
      userSettings.lsp.oxlint.binary = {
        path = "${pkgs.oxlint}/bin/oxlint";
        arguments = [ "--lsp" ];
      };
      userSettings.lsp.ruff.binary = {
        path = "${pkgs.ruff}/bin/ruff";
        arguments = [ "server" ];
      };
      userSettings.lsp.ty.binary = {
        path = "${pkgs.ty}/bin/ty";
        arguments = [ "server" ];
      };
      userSettings.lsp.tombi.binary = {
        path = "${pkgs.tombi}/bin/tombi";
        arguments = [ "lsp" ];
      };
      userSettings.lsp.rust-analyzer.binary.path = "${pkgs.rust-analyzer}/bin/rust-analyzer";
      userSettings.languages =
        lib.genAttrs [ "JavaScript" "JSX" "TypeScript" "TSX" ] (_: {
          formatter.language_server.name = "oxfmt";
          code_actions_on_format = {
            "source.organizeImports" = true;
            "source.fixAll.oxc" = true;
          };
        })
        // {
          Nix = {
            language_servers = [ "nixd" ];
            formatter.external.command = "${pkgs.nixfmt}/bin/nixfmt";
          };
          TOML = {
            language_servers = [ "tombi" ];
            formatter.language_server.name = "tombi";
          };
          Python = {
            language_servers = [
              "ty"
              "ruff"
            ];
            code_actions_on_format."source.fixAll.ruff" = true;
          };
        };
    };

    # GUI apps.
    onlyoffice.enable = true;

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
