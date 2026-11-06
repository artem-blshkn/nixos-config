# Сгенерировано вручную под ThinkPad T14 Gen 1 (AMD, 20UD000GUS).
# Написан вручную под эту машину; при замене железа перегенерировать:
#   sudo nixos-generate-config --no-filesystems --root /mnt
# fileSystems сюда не входят: их задаёт disko.nix.

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "dm_mod"
    "dm_crypt"
    "xhci_pci"
    "thunderbolt"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "rtsx_pci_sdmmc"
  ];

  boot.kernelModules = [ "kvm-amd" ];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
