{ lib, ... }:

# Этап 1 (установка): systemd-boot, Secure Boot выключен.
# Этап 2 (после sbctl create-keys / enroll-keys): secureBoot = true.
# Ключи должны существовать ДО сборки с lanzaboote, иначе сборка упадёт.
let
  secureBoot = false;
in
{
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  boot.loader.systemd-boot.enable = lib.mkForce (!secureBoot);
  boot.loader.systemd-boot.configurationLimit = 4;

  boot.lanzaboote = lib.mkIf secureBoot {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
    # ESP 2 ГБ: 4 поколения UKI (~320 МБ) + запас.
    configurationLimit = 4;
  };
}
