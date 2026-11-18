{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nixd
    nixfmt
    gh
    oxfmt
    ruff
    ty
    rustup
  ];

  programs = {

    bun.enable = true;

    claude-code = {
      enable = true;
      mutableSettings = true;
      settings.theme = "auto";
    };

    codex.enable = true;

    herdr = {
      enable = true;
      mutableSettings = true;
      settings = {
        theme.auto_switch = true;
        session.resume_agents_on_restore = true;
        remote.manage_ssh_config = true;
        terminal.default_shell = "nu";
        terminal.kitty_graphics = true;
        worktrees.directory = "~/.herdr/worktrees";
        ui.toast.delivery = "herdr";
        ui.toast.delay_seconds = 0;
        ui.sound.enabled = true;
        experimental.pane_history = true;
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
      settings.user = {
        name = "maxwellsagax";
        email = "sagax.maxwell@gmail.com";
      };
    };

    uv.enable = true;
  };
}
