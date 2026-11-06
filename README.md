# NixOS 26.05 на ThinkPad T14 Gen 1 (AMD) — установка «под ключ»

Один диск, Windows **стирается**. После установки: LUKS2 + LVM + btrfs,
swap 32G, KDE Plasma 6, Secure Boot (lanzaboote, вариант B), TPM2 + PIN,
snapper, Steam, Podman, KVM, полный набор приложений.

Машина: Ryzen 7 PRO 4750U (8C/16T), 32 ГБ RAM, Radeon Vega, Intel AX200,
NVMe 238.5 ГиБ, TPM 2.0, UEFI. Установка предыдущей конфигурации проверялась в VM;
это не проверка всех функций на физическом ThinkPad.

**Статус 04.11.2026:** установка на железо ещё не разрешена этим документом.
Новые решения и открытые задачи — [PLAN.md](PLAN.md) и [docs/decisions.md](docs/decisions.md).
TLP, HP 419, реальные пороги зарядки, Secure Boot/TPM и гибернация требуют отдельных проверок.
Ещё не закрыты `flake.lock`, закрепление disko CLI и передача checkout в установленную систему.

Раскладка после установки:

| Раздел | Размер | Что |
|---|---|---|
| nvme0n1p1 | 2 ГиБ | ESP, vfat, `/boot` (только UKI) |
| nvme0n1p2 | ~236 ГиБ | LUKS2 `cryptroot` |
| └ LVM `pool` | | |
|   swap | 32 ГиБ | `[SWAP]`, образ гибернации |
|   root | ~204 ГиБ | btrfs: `@ /`, `@home`, `@nix`, `@var`, `@snapshots` |

---

## BIOS: что выставить до установки

Разбор по фото (02.11 и новые снимки 04.11.2026): **[docs/bios.md](docs/bios.md)**.
Там — что стоит сейчас, что менять и почему. Ниже — краткий ориентир.

| Раздел | Пункт | Значение | Зачем |
|---|---|---|---|
| Startup | UEFI/Legacy Boot | **UEFI Only** | NixOS ставится только в UEFI; Legacy не нужен |
| Startup | CSM Support | **No** | то же |
| Security | Secure Boot | **Disabled** (до этапа 2) | включим после подписи загрузчика |
| Security | Secure Boot Mode | **Setup Mode** (перед enroll) | без PK в NVRAM нельзя записать свои ключи |
| Security | Security Chip / TPM | **Enabled / Active** | нужен для TPM+PIN; не очищать |
| Security | Virtualization (AMD SVM) | **Enabled** | KVM/QEMU |
| Security | IOMMU | отдельный пункт на фото не показан | состояние проверить в Linux |
| Security | Fingerprint | Disabled | не используем |
| Security | Absolute Persistence | Disabled | лишняя телеметрия/блокировка |
| Security | Supervisor Password | **ставим** | защищает смену Secure Boot и настройки BIOS |
| Startup | Boot Order | флешка первой на время установки | потом NVMe |
| Config | USB / UEFI Boot | Enabled | установка с флешки |

Supervisor-пароль — единственное, что мешает злоумышленнику с физическим доступом
выключить Secure Boot и записать свои ключи. Минус: забытый пароль = сервис Lenovo.
Пароль выбран отдельным решением; хранить в Bitwarden и независимой резервной копии.

## 0. Что подготовить

1. **Флешка 8 ГБ+** с NixOS 26.05 Graphical ISO (https://nixos.org/download),
   записанная в режиме UEFI (Rufus/Ventoy).
2. **Бэкап всего, что нужно.** Диск будет стёрт полностью, включая Windows и D:.
3. Проверить, что в BIOS: UEFI Only, Secure Boot **выключен** (на этапе 1 не нужен).

## 1. Загрузиться с флешки

F12 → флешка. Сеть: `nmtui` → Wi-Fi, или Ethernet.

## 2. Установка — две команды

```console
$ git clone https://github.com/artem-blshkn/nixos-config.git && cd nixos-config
$ sudo bash install.sh /dev/nvme0n1
```

Команда clone без авторизации будет работать **после** перевода репозитория в Public.
Пока видимость приватная, анонимный доступ не работает. Ключи на запись не нужны для публичного clone.

`install.sh` (не запускать на реальном диске до закрытия блокеров в PLAN.md):

1. показывает, какой диск будет стёрт, и просит подтверждение;
2. размечает GPT, LUKS, LVM, swap, btrfs (спросит парольную фразу LUKS —
   придумай 4 слова латиницей, запиши в Bitwarden и на бумагу);
3. предварительно создаёт lock-файл, затем ставит систему (`nixos-install --flake "path:$PWD#thinkpad"`);
4. просит задать пароль пользователя `yuki`.

Дальше:

```console
$ sudo reboot
```

Вынуть флешку. При загрузке — один запрос фразы LUKS (TPM ещё не настроен).

## 3. Первая проверка

```console
$ lsblk -f
$ findmnt / /home /nix /var /.snapshots
$ sudo btrfs subvolume list /
$ sudo snapper list
$ systemctl --failed
```

Всё должно быть пусто/зелёно. Если что-то не так — `sudo nixos-rebuild switch --flake .#thinkpad`.

### Root и sudo

В NixOS у root по умолчанию **нет пароля** — учётная запись заблокирована. Это не
«root недоступен»: ты получаешь root через `sudo` (пользователь в группе `wheel`),
например `sudo -i` — полноценный root-shell. Прямой вход root в консоль или по SSH
запрещён, пока пароль не задан.

Так сделано намеренно: одна учётная запись с паролем вместо двух, нет пароля root,
который можно забыть, и нет возможности залогиниться root-ом по ошибке. Восстановление
без пароля root работает: загрузился с флешки, `nixos-enter --root /mnt`, `passwd`.

Если хочешь отдельный пароль root — скажи, добавлю в `install.sh` шаг `passwd root`.
Функционально это ничего не даёт, только второй секрет.

## 4. Secure Boot (этап 2)

Сначала прошивка — **до** включения Secure Boot:

```console
$ sudo fwupdmgr refresh --force
$ sudo fwupdmgr get-updates
$ sudo fwupdmgr update
```

Порядок важен: сначала подписанный загрузчик на диске, **потом** ключи в NVRAM.
Если записать ключи раньше, чем появится подписанный UKI, ноутбук перестанет грузиться
до сброса ключей в BIOS.

```console
$ sudo sbctl status          # Secure Boot: Disabled, Setup Mode: Enabled
$ sudo sbctl create-keys
```

Ключи — **только свои**, без Microsoft. Причина: MS-ключи доверяют любому
подписанному Microsoft загрузчику (shim от Ubuntu/Fedora). С физическим доступом
через MokManager можно записать свой ключ и загрузить кейлоггер. Без MS-ключей
грузится только твой подписанный UKI.

Если после включения SB отвалится Wi-Fi, док-станция или fwupd — вернуть MS-ключи:
`sudo sbctl enroll-keys --microsoft` (потребует Setup Mode: сбросить ключи в BIOS).

В `modules/boot.nix` поставить `secureBoot = true;` и пересобрать (SB пока выключен):

```console
$ sudo nixos-rebuild switch --flake .#thinkpad
$ sudo sbctl verify          # все файлы в /boot должны быть signed
$ sudo reboot                # проверка: грузится lanzaboote при SB off
```

Теперь записать ключи (нужен Setup Mode — без PK в NVRAM):

```console
$ sudo sbctl enroll-keys    # без --microsoft
$ sudo reboot
$ sudo sbctl status          # Secure Boot: Enabled
```

Если не грузится — BIOS → Secure Boot off / Setup Mode, флешка, `secureBoot = false`.

## 5. TPM2 + PIN (вариант B — ещё не готов к применению)

Выбрана цель: PIN и signed PCR policy с независимой фразой LUKS для восстановления.
Ранее приведённая команда, использующая сертификат Secure Boot как готовую PCR-политику,
снята с исполнения: подпись EFI-файла и подпись ожидаемых PCR — разные механизмы.
Нужна проверка генерации/доставки PCR-подписей и измерений используемого загрузчика.
Одного `tpm2-device=auto` и `sbctl create-keys` для такой проверки недостаточно.
Не обещаем отсутствие пере-enroll после любых BIOS-обновлений без теста.

## 6. Автообновления

Решено перевести зеркала GitHub/GitLab/Codeberg в Public. До анонимной проверки это
ещё не завершённое изменение видимости. Сейчас deploy keys умеют git-push, но не
изменение настроек; OAuth-приложения отозваны и автоматически не восстанавливаются.

После публикации чтение `github:artem-blshkn/nixos-config#thinkpad` не требует ключей.
Три отдельные deploy key остаются только для push. Ключи и пароли не входят в git.
AutoUpgrade пока выключен; включение и процесс обновления `flake.lock` — отдельная задача.
Публичный репозиторий также открывает историю Actions/логи — их нужно учитывать до смены видимости.

## 6a. Питание, принтер и выбранный софт

- **TLP + tlp-pd**, PPD выключен. Настроены `START_CHARGE_THRESH_BAT0=60` и
  `STOP_CHARGE_THRESH_BAT0=80`. Проверить на ThinkPad: `sudo tlp-stat -s` и `sudo tlp-stat -b`.
  Если заряд уже выше 80%, настройка сама его не разряжает. Это забота о батарее, не обещание прироста FPS.
- **HP Ink Tank 410 series (419):** CUPS + HPLIP с plug-in подготовлены. По памяти
  владельца используется Wi-Fi Direct; USB тоже подходит. URI определим после подключения,
  без сохранения Wi-Fi-пароля в git; нужна пробная печать на реальном принтере.
- **PyCharm:** `jetbrains.pycharm` — unified-дистрибутив, используем бесплатные основные
  функции. Pro-подписку не покупаем; временные Pro-функции не являются требованием.
- **War Thunder:** владелец установит через Steam после установки ОС.
- Дополнительные языки/SDK пока не выбраны; не ставим всё подряд.
- **Рабочие файлы:** бэкап/облако отложены владельцем, автоматический таймер не настраиваем.
  Сейчас цель — восстановить загрузку и доступ к ноутбуку: поколения/откат, флешка и LUKS-фраза.
  Копии LUKS-заголовка и ключей Secure Boot относятся к отдельному набору восстановления,
  который ещё нужно подготовить. Это не резервная копия документов при поломке SSD.

Проверенные источники для этих правок: документация [TLP battery care](https://linrunner.de/tlp/settings/battery.html),
[TLP/PPD](https://linrunner.de/tlp/faq/ppd.html), [модуль TLP nixpkgs 26.05](https://github.com/NixOS/nixpkgs/blob/nixos-26.05/nixos/modules/services/hardware/tlp.nix),
[HPLIP в nixpkgs](https://github.com/NixOS/nixpkgs/blob/nixos-26.05/pkgs/by-name/hp/hplip/package.nix),
[unified PyCharm](https://www.jetbrains.com/pycharm/whatsnew/2025-1/).

## 7. Чего нет и почему

- **Zen Browser** — нет в nixpkgs 26.05. Flatpak включён:
  `flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo`
  `flatpak install flathub app.zen_browser.zen`
- **Бэкап рабочих файлов отложен:** облако не выбираем, таймер с заглушками не запускаем.
- **Отдельного контейнера** для секретов нет: ключи в Bitwarden.
- **Windows** — стирается, dual boot не делаем.

## 8. Если что-то сломалось

| Симптом | Что делать |
|---|---|
| Не грузится после `secureBoot = true` | BIOS → SB off / Setup Mode, флешка, `secureBoot = false` |
| PIN не спрашивают, просит фразу | нет `boot.initrd.systemd.tpm2.enable` или токен не создан |
| Гибернация не работает | `swapon --show`, `cat /sys/power/resume`; swap должен быть 32G |
| Часы сбиваются | `time.hardwareClockInLocalTime` не нужен, если Windows больше нет |
| Мало места в `/nix` | `sudo nix-collect-garbage -d`, `sudo nix-store --optimise` |

## 9. Что проверено, а что проверит железо

Проверено по исходникам nixpkgs 26.05, disko и lanzaboote v1.2.0:

- все `.nix` парсятся tree-sitter-nix без ошибок;
- имена опций: `plasma6`, `sddm`, `xserver.xkb`, `snapper.configs.*`,
  `btrfs.autoScrub`, `wireshark.package`, `lanzaboote.configurationLimit`,
  `efiSysMountPoint`, disko `swap` с `resumeDevice`;
- `crypttab` понимает `tpm2-device=`, а не `tpm2-with-pin=`;
- `boot.resumeDevice` выставляет disko, вручную не дублируется;
- LVM в initrd включается сам (`boot.initrd.services.lvm.enable`).

Предыдущий VM-прогон с диском 100 ГиБ прошёл установку и загрузку в Plasma; проверялись
swap и создание snapshot. Это историческая проверка до новых TLP/HP-изменений.
Реальные Wi-Fi/звук/графику ThinkPad, зарядку 60/80, HP 419, гибернацию,
запись ключей в NVRAM и TPM-enroll нужно проверять отдельно на ноутбуке.

## 10. Структура репозитория

```
flake.nix              nixpkgs 26.05 + home-manager + lanzaboote + disko
configuration.nix      сеть, локаль, пользователь, пакеты, железо
disko.nix              GPT → LUKS → LVM → swap 32G + btrfs
modules/boot.nix       systemd-boot → lanzaboote (secureBoot)
modules/desktop.nix    KDE Plasma 6, SDDM, US/RU, шрифты, Flatpak
modules/security.nix   firewall, sshd off, TPM, snapper, scrub, autoUpgrade
modules/power.nix      zram, suspend-then-hibernate, fwupd, upower
modules/gaming.nix     Steam + gamemode
modules/virt.nix       Podman, libvirt, virt-manager
home.nix               приложения пользователя
install.sh             установка одной командой
docs/security.md       слои защиты, TPM, Secure Boot, граница
docs/decisions.md      решения и принятые риски
```
