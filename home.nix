{ ... }:

{
  imports = [
    ./editor/helix.nix
    ./editor/zed.nix
    ./apps/terminal.nix
    ./apps/development.nix
    ./apps/desktop.nix
  ];

  home.stateVersion = "26.05";
  xdg.enable = true;
}
