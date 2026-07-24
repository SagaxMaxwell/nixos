{ pkgs, ... }:

{
  home = {
    stateVersion = "26.05";

    packages = with pkgs; [
      # Desktop applications
      gnome-tweaks

      # Command-line tools
      rsync
      which
      xh

      # Development and Nix tools
      rustup
      nixd
      nixfmt
      nix-tree
      nix-output-monitor
    ];
  };

  xdg = {
    enable = true;
  };

  services = {
    flameshot = {
      enable = true;
    };
  };

  programs = {
    gnome-shell = {
      enable = true;

      extensions = with pkgs.gnomeExtensions; [
        {
          package = appindicator;
        }
      ];
    };

    google-chrome = {
      enable = true;
    };

    # Shells
    bash = {
      enable = true;
    };

    fish = {
      enable = true;
    };

    nushell = {
      enable = true;
    };

    zsh = {
      enable = true;
    };

    # Shell environment
    direnv = {
      enable = true;

      nix-direnv = {
        enable = true;
      };
    };

    starship = {
      enable = true;
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

    # Command-line tools
    bat = {
      enable = true;
    };

    eza = {
      enable = true;
    };

    fd = {
      enable = true;
    };

    fzf = {
      enable = true;
    };

    jq = {
      enable = true;
    };

    ripgrep = {
      enable = true;
    };

    tealdeer = {
      enable = true;
    };

    yazi = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
    };

    # Nix integration
    home-manager = {
      enable = true;
    };

    nix-index = {
      enable = true;
    };

    nix-index-database = {
      comma = {
        enable = true;
      };
    };

    # Development tools
    bun = {
      enable = true;
    };

    codex = {
      enable = true;
    };

    git = {
      enable = true;

      settings = {
        user = {
          name = "Maxwell";
          email = "sagax.maxwell@gmail.com";
        };
      };
    };

    helix = {
      enable = true;

      settings = {
        theme = "onedark";

        editor = {
          "true-color" = true;
          "line-number" = "relative";
          mouse = true;
          cursorline = true;
          cursorcolumn = false;
          "auto-format" = true;
          bufferline = "never";
          "auto-pairs" = true;

          statusline = {
            left = [
              "mode"
              "spinner"
              "file-name"
              "read-only-indicator"
              "file-modification-indicator"
            ];
            center = [ ];
            right = [
              "diagnostics"
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

          lsp = {
            enable = true;
            "display-messages" = true;
            "auto-signature-help" = true;
            "display-inlay-hints" = true;
            "display-signature-help-docs" = true;
            snippets = true;
            "goto-reference-include-declaration" = true;
          };

          "cursor-shape" = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };

          "file-picker" = {
            hidden = false;
            "follow-symlinks" = true;
            "deduplicate-links" = true;
            parents = true;
            ignore = true;
            "git-ignore" = true;
            "git-global" = true;
            "git-exclude" = true;
          };

          search = {
            "smart-case" = true;
            "wrap-around" = true;
          };

          whitespace = {
            render = "none";
          };

          "indent-guides" = {
            render = false;
          };

          gutters = {
            layout = [
              "diff"
              "diagnostics"
              "line-numbers"
              "spacer"
            ];

            "line-numbers" = {
              "min-width" = 3;
            };
          };

          "soft-wrap" = {
            enable = true;
            "max-wrap" = 20;
            "max-indent-retain" = 40;
            "wrap-indicator" = "";
            "wrap-at-text-width" = false;
          };

          "smart-tab" = {
            enable = true;
            "supersede-menu" = false;
          };
        };
      };
    };

    uv = {
      enable = true;
    };

    vscode = {
      enable = true;
    };

    zed-editor = {
      enable = true;
    };

    # Interface applications
    mangohud = {
      enable = true;
    };

    obsidian = {
      enable = true;
    };

    ghostty = {
      enable = true;
      systemd.enable = true;
      installBatSyntax = true;
      installVimSyntax = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };
  };
}
