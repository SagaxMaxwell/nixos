{ pkgs, ... }:

{
  virtualisation.podman.enable = true;

  virtualisation.containerd = {
    enable = true;
    settings.plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runsc.runtime_type =
      "io.containerd.runsc.v1";
  };

  systemd.services.containerd.path = [ pkgs.gvisor ];

  environment.systemPackages = with pkgs; [
    buildkit
    cloud-hypervisor
  ];
}
