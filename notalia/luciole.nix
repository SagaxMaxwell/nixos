{
  inputs,
  pkgs,
  opacity,
  ...
}:

let
  package = inputs.luciole.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  imports = [ inputs.luciole.nixosModules.default ];

  programs.luciole = {
    enable = true;
    inherit package;
  };

  xdg.portal.config.umbriel."org.freedesktop.impl.portal.FileChooser" = [ "luciole" ];

  home-manager.users.maxwell = {
    imports = [ inputs.luciole.homeModules.default ];

    programs.luciole = {
      enable = true;
      inherit package;
      settings.browser = {
        background_opacity = opacity;
        show_preview = true;
        chooser_show_preview = true;
        thumbnail_policy = "local";
      };
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = [ "dev.noctalia.luciole.desktop" ];
        "x-scheme-handler/trash" = [ "dev.noctalia.luciole.desktop" ];
      };
    };
  };
}
