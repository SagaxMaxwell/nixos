{ pkgs, ... }:

{
  fonts = {
    packages = with pkgs; [
      ibm-plex
      lxgw-wenkai
      nerd-fonts.jetbrains-mono
      source-han-mono
      source-han-sans
      source-han-serif
    ];
  };
}
