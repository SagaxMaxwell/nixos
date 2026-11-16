{
  config,
  pkgs,
  inputs,
  ...
}:

let
  strata = inputs.strata.packages.${pkgs.stdenv.hostPlatform.system}.default;

  # NixOS-level value, captured here because the home-manager block below takes
  # its own `config` argument, which shadows this one.
  systemTimeZone = config.time.timeZone;
in
{
  imports = [ ./input.nix ];

  programs.umbriel.enable = true;

  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
  };

  services = {
    displayManager.noctalia-greeter = {
      enable = true;
      settings.session.default = "umbriel";
    };
    gnome.gnome-keyring.enable = true;
    gvfs.enable = true;
    dbus.packages = [ strata.fileManagerService ];
  };

  xdg.portal.config.umbriel = {
    default = [
      "umbriel"
      "gtk"
    ];
    "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
  };

  fonts.fontconfig = {
    hinting.style = "medium";
    useEmbeddedBitmaps = false;
    defaultFonts = {
      sansSerif = [
        "IBM Plex Sans"
        "Source Han Sans SC"
      ];
      serif = [ "Source Han Serif SC" ];
      monospace = [
        "JetBrainsMono Nerd Font Mono"
        "Source Han Mono SC"
      ];
    };
  };

  fonts.packages = with pkgs; [
    ibm-plex
    lxgw-wenkai
    nerd-fonts.jetbrains-mono
    source-han-mono
    source-han-sans
    source-han-serif
  ];

  home-manager.users.maxwell = { config, lib, ... }: {
    imports = [
      "${pkgs.umbriel.src}/nix/home-module.nix"
      ./compositor.nix
      ./noctalia.nix
    ];

    home.packages = [ strata ];
    qt = {
      enable = true;
      platformTheme.name = "xdgdesktopportal";
    };

    home.activation.strataAppearance = lib.hm.dag.entryAfter [ "linkGeneration" ] (
      lib.hm.generators.mkImpureConfigMerger {
        inherit pkgs;
        format = "toml";
        empty = "{}";
        jqOperation = "$dynamic * $static";
        path = "${config.xdg.configHome}/strata/settings.toml";
        staticSettings = (pkgs.formats.toml { }).generate "strata-appearance.toml" {
          mode = "system";
          theme = "atelier-cave-light";
        };
      }
    );
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = [ "io.github.lgse.Strata.desktop" ];
        "x-scheme-handler/trash" = [ "io.github.lgse.Strata.desktop" ];
      };
    };

    systemd.user.services.noctalia.Unit.X-Restart-Triggers = lib.optional (
      systemTimeZone != null
    ) systemTimeZone;
  };
}
