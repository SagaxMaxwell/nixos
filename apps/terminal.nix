{ pkgs, opacity, ... }:

{
  home.packages = with pkgs; [
    nix-output-monitor
    nix-tree
    xh
    wireguard-tools
  ];

  programs = {
    bash.enable = true;

    nushell = {
      enable = true;
      loadSessionVariables = true;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    starship.enable = true;

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

    ghostty = {
      enable = true;
      settings = {
        theme = "light:TokyoNight Storm,dark:IR Black";
        background-opacity = opacity;
        background-opacity-cells = true;
        background-blur = true;
      };
    };

    nix-index-database.comma.enable = true;
  };
}
