#!/usr/bin/env bash
# Установка NixOS на ОДИН диск. Стирает диск полностью.
set -euo pipefail

DISK="${1:-/dev/nvme0n1}"

if [[ ! -b "$DISK" ]]; then
  echo "Устройство $DISK не найдено. Проверь lsblk." >&2
  exit 1
fi

echo "=============================================================="
echo " ВНИМАНИЕ: диск $DISK будет полностью стёрт (GPT, LUKS, LVM)."
echo " Всё, что на нём есть, будет потеряно безвозвратно."
echo "=============================================================="
read -r -p "Напиши yes, чтобы продолжить: " answer
[[ "$answer" == "yes" ]] || { echo "Отменено."; exit 1; }

export NIX_CONFIG="experimental-features = nix-command flakes"

# disko.nix по умолчанию /dev/nvme0n1 — подставляем переданный диск
sed -i "s|device = \"/dev/nvme0n1\";|device = \"$DISK\";|" disko.nix

echo "==> Разметка и монтирование (спросит фразу LUKS)"
sudo env NIX_CONFIG="$NIX_CONFIG" nix run github:nix-community/disko/latest -- --mode disko ./disko.nix

echo "==> Фиксируем flake.lock (иначе path-флейк меняет хеш при установке)"
sudo env NIX_CONFIG="$NIX_CONFIG" nix flake lock "path:$PWD"

echo "==> Установка системы"
sudo env NIX_CONFIG="$NIX_CONFIG" nixos-install --flake "path:$PWD#thinkpad" --no-root-passwd

echo "==> Пароль пользователя yuki"
sudo nixos-enter --root /mnt -c 'passwd yuki'

echo
echo "Готово. Вынь флешку и перезагрузись:"
echo "  sudo reboot"
