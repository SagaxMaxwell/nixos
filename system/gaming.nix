{ pkgs, ... }:

{
  programs = {
    gamemode.enable = true;
    epic-games-launcher.enable = true;

    gamescope = {
      enableWsi = true;
      capSysNice = true;
    };

    steam = {
      enable = true;
      extraPackages = [
        pkgs.gamemode
        pkgs.mangohud
      ];
      gamescopeSession.enable = true;
    };
  };

  users.users.maxwell.extraGroups = [ "gamemode" ];
  home-manager.users.maxwell = {
    home.packages = [
      pkgs.faugus-launcher
      pkgs.protonup-rs
    ];
    programs.mangohud.enable = true;
  };
}
