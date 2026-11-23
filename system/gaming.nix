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
      extraPackages = with pkgs; [
        gamemode
        mangohud
      ];
      extraCompatPackages = [ pkgs.proton-ge-bin ];
      gamescopeSession.enable = true;
    };
  };

  users.users.maxwell.extraGroups = [ "gamemode" ];
  home-manager.users.maxwell = {
    programs.mangohud.enable = true;
  };
}
