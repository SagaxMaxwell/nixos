{ lib, pkgs, ... }:

let
  version = "1.0.0";
  agent = pkgs.stdenvNoCC.mkDerivation {
    pname = "smartha-agent";
    inherit version;
    src = pkgs.fetchurl {
      url = "https://github.com/DAB-LABS/smart-sniffer/releases/download/v${version}/smartha-agent-linux-amd64";
      sha256 = "cc68f1652caab18d0f5f921b2c004bee138ed44ffa4598dbea7ab70a42243120";
    };
    dontUnpack = true;
    installPhase = ''
      runHook preInstall
      install -Dm755 "$src" "$out/bin/smartha-agent"
      runHook postInstall
    '';
    meta = {
      license = lib.licenses.mit;
      platforms = [ "x86_64-linux" ];
      mainProgram = "smartha-agent";
    };
  };
  integration = pkgs.buildHomeAssistantComponent {
    owner = "DAB-LABS";
    domain = "smart_sniffer";
    inherit version;
    src = pkgs.fetchFromGitHub {
      owner = "DAB-LABS";
      repo = "smart-sniffer";
      tag = "v${version}";
      hash = "sha256-PuKngEObxfLybTOecJEHyRg/zCqq7aZlESQysYl3qiI=";
    };
    meta.license = lib.licenses.mit;
  };
  agentConfig = (pkgs.formats.yaml { }).generate "smartha-agent.yaml" {
    smartctl_path = "${pkgs.smartmontools}/sbin/smartctl";
    scan_interval = "5m";
    standby_mode = "standby";
    mdns = false;
  };
in
{
  services.home-assistant = {
    enable = true;
    extraComponents = [
      "panel_custom"
      "websocket_api"
    ];
    customComponents = [ integration ];
    config = {
      frontend = { };
      history = { };
      recorder = { };
      zeroconf = { };
      http.server_host = "127.0.0.1";
    };
  };

  systemd.services.smartha-agent = {
    description = "SMART Sniffer disk health agent";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${lib.getExe agent} --config ${agentConfig}";
      Restart = "on-failure";
      RestartSec = 10;
      StateDirectory = "smartha-agent";
      WorkingDirectory = "/var/lib/smartha-agent";
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;

      # Keep the agent API local.
      IPAddressDeny = "any";
      IPAddressAllow = "localhost";
    };
  };
}
