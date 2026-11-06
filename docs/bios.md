# BIOS ThinkPad T14 Gen 1 AMD — разбор по фото (02.11.2026)

Машина: 20UD000GUS, BIOS **R1BET87W (1.56)**, EC 1.56, дата BIOS 2026-06-04.
CPU Ryzen 7 PRO 4750U, 32 ГБ RAM, TPM 2.0.

Фото: `../bios-thinkpad/`, 27 исходных от 02.11 и две дополнительные фотографии от 04.11.2026. Ниже — что видно на фото и что планируется.
«Сейчас» — по фото; «Рекомендую» — цель до установки, если не указано иное.

## Итоговые решения (02.11.2026)

- Supervisor Password — **ставим**.
- TSME — **On**.
- Camera и Microphone — **оставляем On**.
- Fn/Ctrl swap — **оставляем On** (специально).
- F1-F12 as Primary Function — **оставляем Off**.

## Главное, что нашлось

1. **Security Chip = MFG Mode.** TPM 2.0 в производственном режиме, не Active.
   Без перевода в **Active** TPM+PIN работать не будет.
2. **Sleep State = Windows 10.** Для Linux надо **Linux**, иначе Modern Standby/S0ix
   может ломать suspend и `suspend-then-hibernate`.
3. **Secure RollBack Prevention = Off.** Включить: запрещает откат BIOS на старую
   уязвимую версию.
4. **Secure Boot = Off, Mode = Setup Mode, Key State = Customized.** Это нормально
   для этапа 1. Не нажимать **Restore Factory Keys** — это вернёт ключи Microsoft.
5. **Fn and Ctrl Key swap = On.** Выставлено владельцем специально; оставить On.
6. **Keyboard Beep = On.** Раздражает; выключить.
7. **Fingerprint Reader = On** в I/O Port Access, хотя отпечаток не используем.
   Выключить, чтобы не светить лишнее устройство.
8. **PXE/Network Boot, UEFI IPv4/IPv6 stack, Wake On LAN from Dock** включены.
   Если PXE не нужен — выключить: меньше поверхности атаки и быстрее загрузка.
9. **Supervisor Password = Disabled.** Поставить после настройки BIOS; иначе
   любой с физическим доступом может выключить Secure Boot.
10. **TSME = Off → On (решено).** Включает шифрование RAM (AMD SME): плюс к защите
    от cold boot/DMA. Оверхед небольшой, но после установки проверить стабильность
    и гибернацию; при проблемах — вернуть Off.

## Main

| Пункт | Сейчас | Рекомендую |
|---|---|---|
| BIOS Version | R1BET87W (1.56), 2026-06-04 | проверить у Lenovo, есть ли новее; обновить **до** Secure Boot |
| EC Version | 1.56 | — |
| CPU | Ryzen 7 PRO 4750U | — |
| Memory | 32768 MB | — |
| Secure Boot | Off | Off до этапа 2 |

## Config → Network

| Пункт | Сейчас | Рекомендую |
|---|---|---|
| Wake On LAN | Disabled | оставить Disabled |
| Wake On LAN from Dock | **On** | **Disabled** (если не нужен dock wake) |
| UEFI IPv4 Network Stack | On | **Disabled**, если нет PXE |
| UEFI IPv6 Network Stack | On | **Disabled**, если нет PXE |
| UEFI Network Boot Priority | IPv4 First | не важно при выключенном stack |
| PXE TFTP Window Size | 4 | не важно |
| Wireless Auto Disconnection | Off | оставить |
| MAC Address Pass Through | Disabled | оставить |

## Config → USB

| Пункт | Сейчас | Рекомендую |
|---|---|---|
| Always On USB | On | оставить, если нужно заряжать в выключенном состоянии |
| Charge in Battery Mode | Off | оставить Off (бережёт батарею) |

## Config → Keyboard/Mouse

| Пункт | Сейчас | Рекомендую |
|---|---|---|
| TrackPoint | On | оставить |
| Trackpad | On | оставить |
| Fn and Ctrl Key swap | **On** | **оставить On** — так решил |
| Fn Sticky Key | Off | оставить |
| F1-F12 as Primary Function | Off | **оставить Off** |
| Keyboard Layout | English (US) | оставить |
| Keyboard Beep | **On** | **Off** |

## Config → Display

| Пункт | Сейчас | Рекомендую |
|---|---|---|
| Boot Display Device | ThinkPad LCD | оставить |
| UMA Frame Buffer Size | 2G | оставить 2G; 4G — только если есть в списке и нужен iGPU |
| Boot Time Extension | Disabled | оставить |

## Config → Power

| Пункт | Сейчас | Рекомендую |
|---|---|---|
| CPU Power Management | On | оставить |
| Power On with AC Attach | Off | оставить |
| Sleep State | **Windows 10** | **Linux** — критично для suspend/hibernate |
| Automatic Power On | не сфотографировано | по умолчанию/Off; прислать фото, если хочешь точный разбор |
| Disable Built-in Battery | Enter | не трогать без необходимости |
| Lid Sensor | On | оставить |

## Config → Beep and Alarm

| Пункт | Сейчас | Рекомендую |
|---|---|---|
| Password Beep | Off | оставить |
| Keyboard Beep | **On** | **Off** |

## Config → HDMI / Setup UI

| Пункт | Сейчас | Рекомендую |
|---|---|---|
| HDMI Mode Select | HDMI 2.0 | оставить |
| Setup UI | Graphical | оставить |

## Security → Password

| Пункт | Сейчас | Рекомендую |
|---|---|---|
| Supervisor Password | **Disabled** | **поставить** (решено) после настройки; хранить в Bitwarden + бумага |
| System Management Password | Disabled | оставить |
| Lock UEFI BIOS Settings | Off | **On** после настройки (защита от изменений BIOS) |
| Password at Unattended Boot | On | **Off**, если нет Power-On Password (иначе смысла нет) |
| Password at Restart | Off | оставить |
| Password at Boot Device List | Off | **On** после установки: F12 только по паролю |
| Password Count Exceeded Error | On | оставить |
| Set Minimum Length | Disabled | можно 8, если ставишь supervisor |
| Set Strong Password | Off | оставить (пароль хранится в Bitwarden) |
| Power-On Password | Disabled | **оставить Disabled**: LUKS уже спрашивает фразу |
| Hard Disk1 Password | Disabled | **оставить Disabled**: LUKS, не надо второй пароль |

## Security → Fingerprint

| Пункт | Сейчас | Рекомендую |
|---|---|---|
| Predesktop Authentication | Off | оставить |
| Security Mode | Normal | оставить |
| Reset Fingerprint Data | Enter | не нужно |
| Fingerprint Reader (I/O Port Access) | On | **Off**, раз не используем |

## Security → Security Chip

| Пункт | Сейчас | Рекомендую |
|---|---|---|
| Security Chip Type | TPM 2.0 | — |
| Security Chip | **MFG Mode** | **Active** (обязательно для TPM+PIN) |
| Clear Security Chip | Enter | **не выполнять как обычный шаг установки**: очистка удаляет TPM-секреты, может затронуть Windows Hello и другие привязки; сначала диагностика и независимые способы восстановления |
| Physical Presence for Clear | On | оставить |
| Security Reporting Options | не сфотографировано | по умолчанию |

## Security → UEFI BIOS Update Option

| Пункт | Сейчас | Рекомендую |
|---|---|---|
| Flash BIOS Updating by End-Users | On | оставить On (нужно для fwupd) |
| Secure RollBack Prevention | **Off** | **On** — запрет отката на старую BIOS |
| Windows UEFI Firmware Update | Off | оставить Off (Windows не будет) |

## Security → Memory Protection / Virtualization

| Пункт | Сейчас | Рекомендую |
|---|---|---|
| Execution Prevention | On | оставить |
| TSME | Off | **On** (решено) |
| Enhanced Windows Biometric Security | Off | оставить |
| AMD V(TM) Technology | On | оставить (нужно для KVM) |
| IOMMU отдельным пунктом | нет | проверить `dmesg | grep -i iommu` после установки |

## Security → I/O Port Access

| Пункт | Сейчас | Рекомендую |
|---|---|---|
| Ethernet LAN | On | оставить |
| Wireless LAN | On | оставить |
| Bluetooth | On | оставить |
| USB Port | On | оставить |
| Memory Card Slot | On | оставить, если пользуешься SD |
| Integrated Camera | On | **оставить On** |
| Integrated Audio | On | оставить |
| Microphone | On | **оставить On** |
| Fingerprint Reader | **On** | **Off** |

## Security → Internal Device Access / Absolute / Secure Boot / Device Guard / DASH

| Пункт | Сейчас | Рекомендую |
|---|---|---|
| Bottom Cover Tamper Detection | Off | опционально On (детект вскрытия), но может мешать |
| Absolute Persistence Module | Disabled / Not Activated | оставить |
| Secure Boot | Off | Off до этапа 2 |
| Secure Boot Mode | **Setup Mode** | оставить до enroll |
| Secure Boot Key State | **Customized** | не жать Restore Factory Keys; проверить `sbctl status` |
| Reset to Setup Mode | Enter | использовать только если enroll не идёт |
| Restore Factory Keys | Enter | **не нажимать**: вернёт ключи Microsoft |
| Clear All Secure Boot Keys | Enter | только если нужно начать с чистого листа перед своими ключами |
| Key Management | submenu | не трогать без необходимости |
| Device Guard | Off | оставить |
| DASH Support | Off | оставить |
| ThinkShield secure wipe in App Menu | Off | оставить |

## Startup

| Пункт | Сейчас | Рекомендую |
|---|---|---|
| Boot (submenu) | фото 04.11: Edit Boot Order | см. точный порядок ниже; до отдельного этапа установки записи не удалять |
| Network Boot | PXE BOOT | **Disabled**, если PXE не нужен |
| Boot Mode | Quick | оставить |
| Option key Display | On | оставить |
| Boot device List F12 Option | On | оставить на установку; после — Password at Boot Device List On |
| Boot Order Lock | Off | **On** после установки (защита порядка загрузки) |

### Дополнительные фото от 04.11.2026

`photo_1_2026-11-04_09-17-26.jpg` показывает **F12 Boot Menu**, а не страницу настройки UEFI/Legacy. Видны Limine, Windows Boot Manager, NVMe0 и PXE BOOT с Realtek IPv4/IPv6.

`photo_2_2026-11-04_09-17-26.jpg` — **Startup → Edit Boot Order**. Порядок сверху вниз:

1. Limine.
2. Windows Boot Manager.
3. USB CD.
4. USB FDD.
5. NVMe0 SKHynix_HFS256GEJ4X112N.
6. ATA HDD0.
7. USB HDD.
8. PXE BOOT (Realtek: Sys IPv4, Sys IPv6, Das IPv4, Das IPv6).

Поля UEFI Only / Legacy / CSM на этих фото **не показаны**; их конкретное значение по этим снимкам не подтверждено. Наличие записи Limine само по себе не доказывает, что соответствующая ОС сейчас установлена.

Для установочной флешки используем F12, не удаляя пока Windows/Limine. После успешной установки проверяем новую запись Linux Boot Manager/systemd-boot и ставим её первой. Старые NVRAM-записи могут сохраниться после стирания диска; их очистка — отдельное действие после проверки загрузки.

## План изменений по шагам

1. **Сначала обновить BIOS**, если у Lenovo есть версия новее 1.56. Делать до Secure Boot:
   после включения своих ключей capsule Lenovo может не пройти проверку.
2. Проверить доступные режимы Security Chip и реальное состояние TPM. **Clear Security Chip не делать автоматически**; сначала проверить последствия и восстановление всех существующих TPM-привязок.
3. **Config → Power → Sleep State → Linux**.
4. **Security → UEFI BIOS Update Option → Secure RollBack Prevention → On**.
5. Выключить PXE/network stack/WOL from Dock, если не нужны.
6. Keyboard: Fn/Ctrl swap **On**, Keyboard Beep Off, F1-F12 Primary **Off**.
7. Fingerprint Reader Off; Camera/Mic **On**.
8. **Supervisor Password** — поставить последним, после всех изменений.
   Затем при желании: Lock UEFI BIOS Settings On, Boot Order Lock On,
   Password at Boot Device List On.
9. **Secure Boot не включать** до установки и первой успешной загрузки.
   `Restore Factory Keys` не нажимать.
10. **TSME → On** (решено). Шифрование RAM; после установки проверить
    стабильность и гибернацию, при проблемах вернуть Off.

## Что ещё нужно сфотографировать

- `Startup → Boot`: порядок уже получен 04.11; отдельные UEFI/Legacy/CSM-поля на новых фото не видны.
- `Config → Power → Automatic Power On` (если хочешь разобрать таймеры/WOL).
- `Security → Secure Boot → Key Management` — только если `sbctl` будет ругаться
  на существующие ключи.
