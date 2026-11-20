#!/bin/bash
# cinnamon-macos-style: pemasang bertahap yang aman.
#
#   ./install.sh --dry-run            lihat dulu apa yang akan dilakukan (tidak mengubah apa pun)
#   ./install.sh                      pasang modul bawaan, tanya sebelum tiap langkah
#   ./install.sh gestures dock        pasang modul tertentu saja
#   ./install.sh --yes all            jawab ya untuk semua pertanyaan (tidak untuk apt, lihat bawah)
#
# Yang TIDAK dilakukan skrip ini: tidak memakai sudo sendiri (apt hanya dijalankan bila
# Anda mengetik y), tidak mengunduh apa pun, tidak mengirim data ke mana pun, dan tidak
# menyentuh GRUB, layar login, atau berkas sistem.
set -u
REPO_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
export REPO_DIR
# shellcheck source=modules/lib.sh
source "$REPO_DIR/modules/lib.sh"

[ "$(id -u)" -ne 0 ] || die "Jangan jalankan sebagai root. Jalankan sebagai pengguna biasa."

BAWAAN="cinnamon terminal gestures dock vscode overview-css magiclamp"
OPSIONAL="panel conky"
MODUL=()
for a in "$@"; do
  case "$a" in
    --dry-run) DRY_RUN=1 ;;
    --yes|-y)  ASSUME_YES=1 ;;
    -h|--help) sed -n '2,13p' "$0"; exit 0 ;;
    all)       MODUL+=($BAWAAN $OPSIONAL) ;;
    *)         MODUL+=("$a") ;;
  esac
done
[ ${#MODUL[@]} -gt 0 ] || MODUL=($BAWAAN)
export DRY_RUN ASSUME_YES

say "cinnamon-macos-style"
note "Modul yang dijalankan : ${MODUL[*]}"
note "Modul opsional        : $OPSIONAL (tambahkan namanya, atau pakai 'all')"
[ "$DRY_RUN" = 1 ] && note "MODE DRY-RUN: tidak ada yang diubah."
if [ "$DRY_RUN" != 1 ]; then
  ask "Lanjut memasang? Semua perubahan dicadangkan di ~/.cinnamon-macos-style-backup" || die "Dibatalkan."
fi
init_backup
[ "$DRY_RUN" = 1 ] || note "Cadangan: $BACKUP_DIR"

# --- paket apt yang dibutuhkan (hanya ditawarkan, tidak otomatis) ---------------------------
BUTUH=(plank touchegg xfce4-terminal fonts-inter fonts-jetbrains-mono wmctrl x11-utils xinput \
       python3-gi python3-gi-cairo gir1.2-gtk-3.0 dconf-cli libglib2.0-bin papirus-icon-theme)
case " ${MODUL[*]} " in *" conky "*) BUTUH+=(conky-all fonts-montserrat fonts-font-awesome) ;; esac
KURANG=$(paket_belum "${BUTUH[@]}" | tr '\n' ' ')
if [ -n "${KURANG// /}" ]; then
  say "Paket yang belum terpasang: $KURANG"
  note "Perintah yang akan dijalankan:  sudo apt install $KURANG"
  if [ "$DRY_RUN" != 1 ] && ask "Jalankan perintah apt di atas sekarang? (meminta kata sandi sudo)"; then
    # shellcheck disable=SC2086
    sudo apt install $KURANG || warn "apt gagal; modul yang butuh paket itu akan dilewati"
  else
    note "Dilewati. Modul yang butuh paket tersebut akan memberi tahu bila tidak bisa jalan."
  fi
fi

for m in "${MODUL[@]}"; do
  f=$(ls "$REPO_DIR"/modules/[0-9][0-9]-"$m".sh 2>/dev/null | head -1)
  if [ -z "$f" ]; then warn "modul '$m' tidak dikenal"; continue; fi
  say "Modul: $m"
  # shellcheck disable=SC1090
  source "$f"
done

echo
say "Selesai."
if [ "$DRY_RUN" = 1 ]; then
  note "Itu tadi simulasi. Jalankan tanpa --dry-run untuk benar-benar memasang."
else
  note "Cadangan dan skrip pembatalan: $BACKUP_DIR"
  note "Untuk membatalkan semuanya: ./uninstall.sh"
  note "Logout lalu login lagi agar semua perubahan (font, tema, autostart) berlaku penuh."
fi
