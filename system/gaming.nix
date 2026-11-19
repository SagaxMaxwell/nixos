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
      gamescopeSession.enable = true;
    };
  };

  users.users.maxwell.extraGroups = [ "gamemode" ];
  home-manager.users.maxwell = {
    programs.mangohud.enable = true;
    home.packages = [ pkgs.wineWow64Packages.stagingFull ];
  };
}
