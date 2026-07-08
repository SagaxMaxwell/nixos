{ pkgs, ... }:

{
  home = {
    stateVersion = "26.05";

    packages = with pkgs; [
      google-chrome
      gnome-tweaks
      rsync
      which
      xh
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

    direnv = {
      enable = true;

      nix-direnv = {
        enable = true;
      };
    };

    fish = {
      enable = true;
    };

    zsh = {
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

    mangohud = {
      enable = true;
    };

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

    vscode = {
      enable = true;
    };

    codex = {
      enable = true;
    };

    bun = {
      enable = true;
    };

    yazi = {
      enable = true;
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
    };

    obsidian = {
      enable = true;
    };

    uv = {
      enable = true;
    };

    nushell = {
      enable = true;
    };

    wezterm = {
      enable = true;
    };

    helix = {
      enable = true;
    };
  };
}
