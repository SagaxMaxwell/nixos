{ pkgs, ... }:

{
  home = {
    stateVersion = "26.05";

    packages = with pkgs; [
      # Desktop applications
      gnome-tweaks
      google-chrome

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

    configFile = {
      "helix/config.toml" = {
        source = ./helix/config.toml;
        force = true;
      };

      "wezterm/wezterm.lua" = {
        source = ./wezterm/wezterm.lua;
        force = true;
      };
    };
  };

  programs = {
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
      enableBashIntegration = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
    };

    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
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
    };

    uv = {
      enable = true;
    };

    vscode = {
      enable = true;
    };

    # Interface applications
    mangohud = {
      enable = true;
    };

    obsidian = {
      enable = true;
    };

    wezterm = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
  };
}
