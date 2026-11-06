{ ... }:

{
  # zram для повседневного давления памяти; дисковый swap — для гибернации
  zramSwap.enable = true;

  # Крышка: 30 минут сна, затем гибернация в зашифрованный swap.
  # Во время обычного сна диск остаётся открыт: блокировка экрана обязательна.
  # TPM+PIN при возобновлении из гибернации требует отдельного теста на железе.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend-then-hibernate";
    HandleLidSwitchDocked = "ignore";
  };
  systemd.sleep.settings.Sleep.HibernateDelaySec = "30min";

  # Прошивка ThinkPad. Обновления fwupd делать ДО включения Secure Boot.
  services.fwupd.enable = true;

  # TLP управляет питанием ThinkPad; второй менеджер PPD одновременно не нужен.
  services.upower.enable = true;
  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    # Совместимый с PPD интерфейс: профили доступны KDE, без запуска самого PPD.
    pd.enable = true;
    settings = {
      START_CHARGE_THRESH_BAT0 = 60;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };
}
