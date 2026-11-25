{
  inputs,
  pkgs,
  opacity,
  ...
}:

{
  home.packages = with pkgs; [
    nix-output-monitor
    nix-tree
    broot
    ast-grep
    fd
    lsr
    mcat
    resterm
    ringboard-wayland
    ripgrep
    sendme
    zstd
    impression
    ventoy
    wireguard-tools
    inputs.multiverse.packages.${pkgs.stdenv.hostPlatform.system}.mvs
  ];

  programs = {
    bash.enable = true;

    nushell = {
      enable = true;
      loadSessionVariables = true;
    };

    devenv = {
      enable = true;
      enableNushellIntegration = true;
    };

    starship.enable = true;

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

    ghostty = {
      enable = true;
      settings = {
        font-family = [
          "Monaspace Neon Var"
          "Cascadia Code NF"
          "Maple Mono NF"
          "Maple Mono NF CN"
          "Recursive"
          "Sarasa Mono SC"
          "Sarasa Term SC"
        ];
        theme = "light:GitHub Dark Dimmed,dark:IR Black";
        background-opacity = opacity;
        background-opacity-cells = true;
        background-blur = true;
      };
    };

  };
}
