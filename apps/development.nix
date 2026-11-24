{ inputs, pkgs, ... }:

{
  imports = [ ./herdr.nix ];

  home.packages =
    (with pkgs; [
      nixd
      nixfmt
      gh
      oxfmt
      ruff
      ty
      rustup
    ])
    ++ [ inputs.delta.packages.${pkgs.stdenv.hostPlatform.system}.delta ];

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
    };

    pi-coding-agent = {
      enable = true;
      mutableSettings = true;
      settings = {
        theme = "system";
        defaultProvider = "openrouter";
        defaultModel = "openrouter/free";
        shellPath = "${pkgs.bash}/bin/bash";
        externalEditor = "${pkgs.helix}/bin/hx";
        defaultTools = [ "+codemode" ];
        npmCommand = [ "${pkgs.bun}/bin/bun" ];
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
