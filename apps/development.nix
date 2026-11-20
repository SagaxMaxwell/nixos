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
      settings.theme = "system";
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
      settings.user = {
        name = "maxwellsagax";
        email = "sagax.maxwell@gmail.com";
      };
    };

    uv.enable = true;
  };
}
