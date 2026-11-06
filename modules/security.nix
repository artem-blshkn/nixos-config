{ config, lib, pkgs, ... }:

{
  # --- поверхность атаки ---
  networking.firewall.enable = true;
  # На ноутбуке sshd не нужен: к VPS ходим исходящим ssh.
  services.openssh.enable = false;
  security.sudo.wheelNeedsPassword = true;

  # --- LUKS: TPM2 открывает диск, PIN и политика подписи лежат в LUKS-токене ---
  # crypttab понимает только tpm2-device= (tpm2-pin= нужен лишь без метаданных в токене).
  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.tpm2.enable = true;
  boot.initrd.luks.devices.cryptroot.crypttabExtraOpts = [ "tpm2-device=auto" ];

  # --- снапшоты btrfs: часовые/дневные/недельные, хранятся в /.snapshots ---
  services.snapper.configs.root = {
    SUBVOLUME = "/";
    ALLOW_USERS = [ "yuki" ];
    TIMELINE_CREATE = true;
    TIMELINE_CLEANUP = true;
    TIMELINE_LIMIT_HOURLY = 5;
    TIMELINE_LIMIT_DAILY = 7;
    TIMELINE_LIMIT_WEEKLY = 4;
    TIMELINE_LIMIT_MONTHLY = 0;
    TIMELINE_LIMIT_YEARLY = 0;
    NUMBER_CLEANUP = true;
    NUMBER_LIMIT = 20;
  };

  # --- обслуживание btrfs ---
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

  # --- сеть: wireshark с capabilities, пользователь yuki в группе wireshark ---
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark; # GUI, а не только tshark
  };

  # --- автообновления ---
  # Включать после стабилизации и проверки публичного чтения репозитория.
  # Для Public чтение идёт без ключей; deploy keys нужны только для записи.
  # Процесс обновления flake.lock ещё надо зафиксировать.
  system.autoUpgrade = {
    enable = false;
    flake = "github:artem-blshkn/nixos-config#thinkpad";
    dates = "weekly";
    allowReboot = false;
    randomizedDelaySec = "45min";
  };
}
