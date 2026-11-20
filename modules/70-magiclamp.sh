# Modul: magiclamp  (di-source oleh install.sh)
# Efek "genie" macOS saat minimize/unminimize, lewat ekstensi komunitas Magic Lamp Effect.
#
# Ekstensi ini KODE PIHAK KETIGA yang berjalan di dalam Cinnamon. Karena itu skrip ini
# TIDAK mengunduh atau mengaktifkannya. Anda memasangnya sendiri setelah memeriksa kodenya
# (lihat docs/DEPENDENCIES.md). Modul ini hanya menyetel nilainya bila sudah terpasang.

UUID="CinnamonMagicLamp@klangman"
ada=0
[ -d "$HOME/.local/share/cinnamon/extensions/$UUID" ] && ada=1
[ -d "/usr/share/cinnamon/extensions/$UUID" ] && ada=1
if [ "$ada" = 0 ]; then
  warn "ekstensi $UUID belum terpasang."
  note "Cara memasang: Pengaturan Sistem > Ekstensi > tab Unduh > cari 'Magic Lamp Effect'."
  note "Sumber dan peringatan: docs/DEPENDENCIES.md. Periksa kodenya dulu bila Anda ragu."
  return 0
fi

CFG=$(ls "$HOME/.config/cinnamon/spices/$UUID/"*.json 2>/dev/null | head -1)
if [ -z "$CFG" ]; then
  warn "berkas pengaturan ekstensi belum dibuat (aktifkan ekstensinya sekali dulu, lalu jalankan modul ini lagi)"
  return 0
fi
if [ "$DRY_RUN" = 1 ]; then note "[dry-run] mengatur durasi 250 ms di $CFG"; return 0; fi

backup_file "$CFG"
python3 - "$CFG" <<'PY'
import json, sys
f = sys.argv[1]
d = json.load(open(f))
d["duration"]["value"] = 250      # milidetik; makin besar makin lambat
d["effect"]["value"] = 0          # 0 = melengkung halus, 1 = bergelombang (sine)
json.dump(d, open(f, "w"), indent=4)
print("    [ok] Magic Lamp: durasi 250 ms, efek melengkung")
PY
note "Muat ulang ekstensi agar nilai baru terbaca: nonaktifkan lalu aktifkan di Pengaturan Sistem > Ekstensi."
