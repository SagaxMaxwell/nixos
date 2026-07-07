{ pkgs, ... }:

{
  home = {
    stateVersion = "26.05";

    packages = with pkgs; [
      duf
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

  programs = {
    home-manager = {
      enable = true;
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
