{ osConfig, pkgs, ... }:

{
  home = {
    stateVersion = osConfig.local.stateVersion;

    packages = with pkgs; [
      duf
      google-chrome
      ncdu
      rsync
      unzip
      which
      wl-clipboard
      xh
      zip
      _7zz
      poppler-utils
    ];
  };

  xdg = {
    enable = true;
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
          name = osConfig.local.user.git.name;
          email = osConfig.local.user.git.email;
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
    };

    starship = {
      enable = true;
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
