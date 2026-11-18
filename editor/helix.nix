{ lib, pkgs, ... }:

let
  exe = lib.getExe;
in
{
  programs.helix = {
    enable = true;
    extraPackages = [ pkgs.wl-clipboard ];

    settings = {
      theme = "base16_terminal";

      editor = {
        true-color = true;
        line-number = "relative";
        cursorline = true;

        end-of-line-diagnostics = "hint";
        inline-diagnostics.cursor-line = "warning";

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

        lsp.display-inlay-hints = true;

        cursor-shape = {
          insert = "bar";
          select = "underline";
        };

        file-picker.hidden = false;

        gutters = [
          "diff"
          "diagnostics"
          "line-numbers"
          "spacer"
        ];

        soft-wrap = {
          enable = true;
          wrap-indicator = "";
        };
      };
    };

    languages = {
      language = [
        {
          name = "nix";
          auto-format = true;
          language-servers = [ "nixd" ];
          formatter.command = exe pkgs.nixfmt;
        }
        {
          name = "python";
          language-servers = [
            "ty"
            "ruff"
          ];
        }
        {
          name = "toml";
          language-servers = [ "tombi" ];
        }
      ];

      language-server = {
        nixd.command = exe pkgs.nixd;
        ty.command = exe pkgs.ty;
        ruff.command = exe pkgs.ruff;
        rust-analyzer.command = exe pkgs.rust-analyzer;
        tombi.command = exe pkgs.tombi;
      };
    };
  };
}
