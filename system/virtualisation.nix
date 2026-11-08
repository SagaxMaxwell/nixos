{ pkgs, ... }:

{
  virtualisation.podman.enable = true;

  virtualisation.containerd = {
    enable = true;
    settings.plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runsc = {
      runtime_type = "io.containerd.runsc.v1";
      options.BinaryName = "${pkgs.gvisor}/bin/runsc";
    };
  };

  environment.systemPackages = with pkgs; [
    buildkit
    cloud-hypervisor
  ];
}
