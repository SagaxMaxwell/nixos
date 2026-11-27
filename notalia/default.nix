{
  imports = [
    ./shell.nix
    ./umbriel.nix
    ./luciole.nix
    ./greeter.nix
    ./plugins.nix
  ];

  services.gnome.gnome-keyring.enable = true;
  services.gvfs.enable = true;

  xdg.portal.config.umbriel = {
    default = [
      "umbriel"
      "gtk"
    ];
    "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
  };

  home-manager.users.maxwell.qt = {
    enable = true;
    platformTheme.name = "xdgdesktopportal";
  };
}
