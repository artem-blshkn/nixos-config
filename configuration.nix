{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/boot.nix
    ./modules/desktop.nix
    ./modules/security.nix
    ./modules/power.nix
    ./modules/gaming.nix
    ./modules/virt.nix
  ];

  # --- сеть ---
  networking.hostName = "thinkpad";
  networking.networkmanager.enable = true;

  # --- локаль и время ---
  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "en_US.UTF-8";
  # initrd работает в US-раскладке: фраза LUKS и PIN должны быть латиницей
  console.keyMap = "us";

  # --- сам Nix ---
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nixpkgs.config.allowUnfree = true;

  # --- пользователь ---
  # Пароль задаётся при установке: nixos-enter --root /mnt -c 'passwd yuki'
  # В git пароля нет.
  users.users.yuki = {
    isNormalUser = true;
    description = "yuki";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "audio"
      "podman"
      "libvirtd"
      "wireshark"
    ];
  };

  # --- системные пакеты ---
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    htop
    ripgrep
    fd
    unzip
    pciutils
    usbutils
    sbctl          # ключи Secure Boot
    btrfs-progs    # subvolume/snapshot/scrub
    cryptsetup     # luksDump, cryptenroll
    tpm2-tools     # диагностика TPM
  ];

  # --- железо ThinkPad T14 Gen 1 AMD ---
  hardware.enableRedistributableFirmware = true; # Wi-Fi AX200, звук
  hardware.graphics.enable = true;               # Mesa для Radeon Vega
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # --- состояние: фиксируется при установке, не менять при обновлениях ---
  system.stateVersion = "26.05";
}
