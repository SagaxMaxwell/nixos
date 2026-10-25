{
  pkgs,
  ...
}:

{
  home = {
    stateVersion = "26.05";

    packages = with pkgs; [
      # Linux desktop tools.
      gnome-tweaks
      rsync

      # Nix and command-line tools.
      nix-output-monitor
      nix-tree
      nixd
      nixfmt
      gh
      oxfmt
      xh

      # Development environments.
      dotnet-sdk_10
      rustup
    ];
  };

  xdg.enable = true;

  services.flameshot.enable = true;

  programs = {
    # Desktop integration.
    gnome-shell = {
      enable = true;

      extensions = with pkgs.gnomeExtensions; [
        {
          package = appindicator;
        }
      ];
    };

    google-chrome.enable = true;

    # Shells.
    bash.enable = true;
    fish.enable = true;
    nushell.enable = true;
    zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
    };

    # Shell environment.
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
    };

    atuin = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
      flags = [ "--disable-up-arrow" ];
    };

    # Command-line tools.
    bat.enable = true;
    eza.enable = true;
    fd.enable = true;
    man.generateCaches = false;
    ripgrep.enable = true;
    tealdeer.enable = true;

    yazi = {
      enable = true;
      shellWrapperName = "y";
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
    };

    # Development tools.
    bun.enable = true;
    codex.enable = true;
    delta.enable = true;

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

    home-manager.enable = true;

    nix-index.enable = true;
    nix-index-database.comma.enable = true;
    uv.enable = true;

    ghostty = {
      enable = true;
      systemd.enable = true;
      installBatSyntax = true;
      installVimSyntax = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableFishIntegration = true;

      settings = {
        theme = "Atom One Dark";
      };
    };

    # Editors.
    helix = {
      enable = true;

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
              normal = "🥳";
              insert = "🤯";
              select = "🤔";
            };
          };

          lsp."display-inlay-hints" = true;

          "cursor-shape" = {
            insert = "bar";
            select = "underline";
          };

          "file-picker".hidden = false;

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
          name = "c-sharp";
          "language-servers" = [ "roslyn" ];
        }
      ];

      languages.language-server.roslyn = {
        command = "${pkgs.roslyn-ls}/bin/Microsoft.CodeAnalysis.LanguageServer";
        args = [ "--stdio" ];
      };

      languages.language-server.ty = {
        command = "${pkgs.ty}/bin/ty";
        args = [ "server" ];
      };

      languages.language-server.ruff = {
        command = "${pkgs.ruff}/bin/ruff";
        args = [ "server" ];
      };

      languages.language-server.rust-analyzer.command = "${pkgs.rust-analyzer}/bin/rust-analyzer";
    };

    vscode = {
      enable = true;

      profiles.default.extensions = with pkgs.nix-vscode-extensions.vscode-marketplace-release; [
        analytic-signal.preview-pdf
        charliermarsh.ruff
        csharpier.csharpier-vscode
        github.github-vscode-theme
        ms-python.debugpy
        ms-python.isort
        ms-python.python
        ms-python.vscode-python-envs
        ms-toolsai.jupyter
        ms-toolsai.jupyter-keymap
        ms-toolsai.jupyter-renderers
        ms-toolsai.vscode-jupyter-cell-tags
        ms-toolsai.vscode-jupyter-slideshow
        ms-dotnettools.csharp
        # Oxc's current releases are universal; platform-specific builds are older.
        pkgs.nix-vscode-extensions.vscode-marketplace-release-universal.oxc.oxc-vscode
        rust-lang.rust-analyzer
      ];
    };

    obsidian = {
      enable = true;

      defaultSettings.communityPlugins = with pkgs.obsidianPlugins; [
        obsidian-linter
        templater-obsidian
        dataview
        notebook-navigator
        jupyter-viewer
        advanced-canvas
        tldraw
      ];
    };

    # Linux-specific applications.
    mangohud.enable = true;
    zed-editor.enable = true;
  };
}
