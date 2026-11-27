{
  inputs,
  pkgs,
  opacity,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) system;
in
{
  home.packages = [
    pkgs.nix-output-monitor
    pkgs.nix-tree
    pkgs.broot
    pkgs.ast-grep
    pkgs.fd
    pkgs.lsr
    pkgs.mcat
    pkgs.resterm
    pkgs.ripgrep
    pkgs.sendme
    pkgs.zstd
    pkgs.impression
    pkgs.ventoy
    pkgs.wireguard-tools
    inputs.multiverse.packages.${system}.mvs
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
