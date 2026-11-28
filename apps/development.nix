{
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) system;
  chromeDevtoolsMcp = inputs.mcp-servers-nix.packages.${system}.chrome-devtools-mcp;
in
{
  imports = [ ./herdr.nix ];

  home.packages = [
    pkgs.nixd
    pkgs.tix
    pkgs.nixfmt
    pkgs.gh
    pkgs.oxfmt
    pkgs.ruff
    pkgs.ty
    pkgs.rustup
    inputs.delta.packages.${system}.delta
    inputs.llm-agents.packages.${system}.gascity
    inputs.llm-agents.packages.${system}.kitesurf
    chromeDevtoolsMcp
  ];

  programs = {
    bun.enable = true;

    claude-code = {
      enable = true;
      mutableSettings = true;
      settings.theme = "auto";
    };

    codex = {
      enable = true;
      mutableSettings = true;
      settings.mcp_servers.kitesurf = {
        command = lib.getExe chromeDevtoolsMcp;
        args = [ "--wsEndpoint=wss://kitesurf.dev/devtools/browser" ];
      };
    };

    pi-coding-agent = {
      enable = true;
      mutableSettings = true;
      settings = {
        theme = "system";
        defaultProvider = "openrouter";
        defaultModel = "openrouter/free";
        shellPath = lib.getExe' pkgs.bash "bash";
        externalEditor = lib.getExe' pkgs.helix "hx";
        defaultTools = [ "+codemode" ];
        npmCommand = [ (lib.getExe' pkgs.bun "bun") ];
        packages = [
          "npm:billion-context"
          "npm:pi-total-recall"
          "npm:pi-lens"
          "npm:@tintinweb/pi-subagents"
          "npm:pi-web-access"
          "npm:pi-doc-review"
          "npm:@juicesharp/rpiv-todo"
          "npm:pi-md-render"
        ];
        terminal.showTerminalProgress = true;
        quietStartup = "header";
      };
    };

    difftastic = {
      enable = true;
      git = {
        enable = true;
        mode = "difftool";
      };
    };

    git = {
      enable = true;
      settings = {
        rerere.enabled = true;
        fetch.prune = true;
        merge.conflictStyle = "zdiff3";
        push.autoSetupRemote = true;
        user = {
          name = "maxwellsagax";
          email = "sagax.maxwell@gmail.com";
        };
      };
    };

    uv.enable = true;
  };
}
