#!/bin/bash
# Membatalkan pemasangan: mengembalikan pengaturan dan berkas dari cadangan terakhir.
#   ./uninstall.sh          pakai cadangan terbaru
#   ./uninstall.sh --list   tampilkan semua cadangan yang ada
# Paket apt yang Anda pasang sendiri TIDAK dihapus (hapus manual bila perlu).
set -u
ROOT="$HOME/.cinnamon-macos-style-backup"
[ -d "$ROOT" ] || { echo "Tidak ada cadangan di $ROOT (belum pernah memasang?)"; exit 1; }

if [ "${1:-}" = "--list" ]; then ls -1 "$ROOT"; exit 0; fi

TERBARU=$(ls -1 "$ROOT" | sort | tail -1)
[ -n "$TERBARU" ] || { echo "Folder cadangan kosong."; exit 1; }
DIR="$ROOT/$TERBARU"
[ -x "$DIR/restore.sh" ] || { echo "Skrip pembatalan tidak ditemukan di $DIR"; exit 1; }

echo "Cadangan yang akan dipulihkan: $DIR"
echo "Isi skrip pembatalan (periksa dulu, hanya berisi perintah gsettings, cp, dan rm):"
echo "----"; cat "$DIR/restore.sh"; echo "----"
read -r -p "Pulihkan sekarang? [y/N] " j
case "$j" in y|Y|ya|YA|Ya) ;; *) echo "Dibatalkan."; exit 0 ;; esac
bash "$DIR/restore.sh"
echo "Selesai. Logout lalu login lagi. Folder cadangan tetap disimpan di $DIR"
