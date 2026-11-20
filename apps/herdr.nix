{ config, ... }:

let
  cfg = config.programs.herdr;

  # Link upstream hook scripts.
  script = agent: "${cfg.package}/share/herdr/integrations/${agent}/herdr-agent-state.sh";

  # Report sessions to Herdr.
  hook = path: {
    type = "command";
    command = "bash '${config.home.homeDirectory}/${path}' session";
    timeout = 10;
  };

in
{
  programs.herdr = {
    enable = true;
    mutableSettings = true;
    settings = {
      theme = {
        name = "terminal";
        auto_switch = true;
        light_name = "terminal";
        dark_name = "terminal";
      };
      session.resume_agents_on_restore = true;
      remote.manage_ssh_config = true;
      terminal.default_shell = "nu";

      # Forward pane images to Ghostty.
      terminal.kitty_graphics = true;
      worktrees.directory = "~/.herdr/worktrees";
      ui.toast.delivery = "herdr";
      ui.toast.delay_seconds = 0;
      ui.sound.enabled = true;
      experimental.pane_history = true;
    };
  };

  programs.claude-code = {
    hooks."herdr-agent-state.sh" = script "claude";
    settings.hooks.SessionStart = [
      {
        matcher = "^(startup|resume|clear|compact|fork)$";
        hooks = [ (hook ".claude/hooks/herdr-agent-state.sh") ];
      }
    ];
  };

  home.file.".codex/herdr-agent-state.sh".source = script "codex";

  home.file."${config.programs.pi-coding-agent.configDir}/extensions/herdr-agent-state.ts".source =
    "${cfg.package}/share/herdr/integrations/pi/herdr-agent-state.ts";

  programs.codex = {
    settings.features.hooks = true;
    hooks.SessionStart = [ { hooks = [ (hook ".codex/herdr-agent-state.sh") ]; } ];
  };
}
