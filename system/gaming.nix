{ pkgs, ... }:

{
  programs = {
    gamemode.enable = true;

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
      package = pkgs.steam.override {
        extraLibraries = p: [ p.gamemode.lib ];
      };
      gamescopeSession.enable = true;
    };
  };

  users.users.maxwell.extraGroups = [ "gamemode" ];
  home-manager.users.maxwell.programs.mangohud.enable = true;

  environment.systemPackages = with pkgs; [ wineWow64Packages.stagingFull ];
}
