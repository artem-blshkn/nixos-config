{ ... }:

{
  # Podman с совместимостью docker (docker → podman, /run/docker.sock)
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
  };

  # KVM/QEMU + virt-manager для сетевой лаборатории
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  security.polkit.enable = true;
}
