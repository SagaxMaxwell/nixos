{
  lib,
  pkgs,
  alpha,
  ...
}:

let
  exe = lib.getExe;
in
{
  programs.zed-editor = {
    enable = true;

    userSettings = {
      theme = {
        mode = "system";
        light = "GitHub Dark Dimmed";
        dark = "IR Black";
      };

      terminal = {
        font_family = "Monaspace Neon Var";
        font_fallbacks = [
          "Cascadia Code NF"
          "Maple Mono NF"
          "Maple Mono NF CN"
          "Recursive"
          "Sarasa Mono SC"
          "Sarasa Term SC"
        ];
      };

      # Apply alpha to outer surfaces.
      theme_overrides =
        lib.mapAttrs
          (
            _: background:
            {
              "background.appearance" = "blurred";
              inherit background;
              "title_bar.background" = background;
              "title_bar.inactive_background" = background;
              "status_bar.background" = background;
            }
            // lib.genAttrs [
              "editor.background"
              "editor.gutter.background"
              "panel.background"
              "terminal.background"
              "toolbar.background"
              "tab_bar.background"
              "tab.active_background"
              "tab.inactive_background"
            ] (_: "#00000000")
          )
          {
            "GitHub Dark Dimmed" = "#212830${alpha}";
            "IR Black" = "#000000${alpha}";
          };

      auto_install_extensions = {
        github-theme = true;
        ir-black = true;
        nix = true;
        oxc = true;
        tombi = true;
      };

      diagnostics.inline.enabled = true;
      autosave = "on_window_change";
      format_on_save = "on";

      lsp = {
        nixd.binary.path = exe pkgs.nixd;
        rust-analyzer.binary.path = exe pkgs.rust-analyzer;
        oxfmt.binary = {
          path = exe pkgs.oxfmt;
          arguments = [ "--lsp" ];
        };
        oxlint = {
          initialization_options.settings.fixKind = "safe_fix";
          binary = {
            path = exe pkgs.oxlint;
            arguments = [ "--lsp" ];
          };
        };
        ruff.binary = {
          path = exe pkgs.ruff;
          arguments = [ "server" ];
        };
        ty.binary = {
          path = exe pkgs.ty;
          arguments = [ "server" ];
        };
        tombi.binary = {
          path = exe pkgs.tombi;
          arguments = [ "lsp" ];
        };
      };

      languages =
        lib.genAttrs [ "JavaScript" "JSX" "TypeScript" "TSX" ] (_: {
          formatter.language_server.name = "oxfmt";
          code_actions_on_format = {
            "source.organizeImports" = true;
            "source.fixAll.oxc" = true;
          };
        })
        // {
          Nix = {
            language_servers = [ "nixd" ];
            formatter.external.command = exe pkgs.nixfmt;
          };
          TOML = {
            language_servers = [ "tombi" ];
            formatter.language_server.name = "tombi";
          };
          Python = {
            language_servers = [
              "ty"
              "ruff"
            ];
            code_actions_on_format."source.fixAll.ruff" = true;
          };
        };
    };
  };
}
