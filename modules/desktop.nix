{ pkgs, ... }:

{
  # KDE Plasma 6 на Wayland; sddm включает сам модуль plasma6, но enable — вручную.
  services.xserver.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;

  # Раскладки: US + RU, переключение Alt+Shift. В initrd остаётся US.
  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:alt_shift_toggle";
  };
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
  ];

  # Flatpak нужен для приложений, которых нет в nixpkgs (например Zen Browser).
  services.flatpak.enable = true;
  xdg.portal.enable = true;

  # HP Ink Tank Wireless 419 (410 series): HPLIP с vendor plug-in.
  # Очередь/URI зададим после уточнения USB или Wi-Fi; адрес не угадываем.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplipWithPlugin ];
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  programs.system-config-printer.enable = true;
}
