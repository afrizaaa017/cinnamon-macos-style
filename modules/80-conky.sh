# Modul: conky (OPSIONAL)  (di-source oleh install.sh)
# Tiga widget di wallpaper: nama hari + jam (kiri atas), disk/suhu/baterai/volume/kecerahan
# (kanan atas), dan pemakaian RAM (kanan bawah). Transparan, digambar dengan Cairo.
#
# Perlu: conky-all, font Montserrat, FontAwesome, dan Titillium Web (font terakhir TIDAK ada di apt,
# lihat docs/DEPENDENCIES.md). Bagian khusus perangkat (nama baterai, backlight) dideteksi otomatis.

have conky || { warn "conky belum terpasang (sudo apt install conky-all); dilewati"; return 0; }
for f in "Montserrat" "Font Awesome|FontAwesome" "Titillium Web"; do
  font_ada "$f" || warn "font '${f%%|*}' belum terpasang; tampilan widget bisa berbeda"
done
ask "Pasang 3 widget Conky ke ~/.config/conky ? (tidak menimpa berkas conky Anda yang bernama lain)" || { warn "dilewati"; return 0; }

BAT=$(ls /sys/class/power_supply 2>/dev/null | grep -m1 '^BAT')
BL=$(ls /sys/class/backlight 2>/dev/null | head -1)
note "Baterai terdeteksi: ${BAT:-tidak ada} | Backlight terdeteksi: ${BL:-tidak ada}"

DST="$HOME/.config/conky"
for f in hari.conf ram.conf disk.conf dayname.lua ram.lua; do
  install_file "$REPO_DIR/files/conky/$f" "$DST/$f"
done
# disk.lua berisi nama baterai/backlight khusus perangkat: sesuaikan sebelum dipasang
TMP=$(mktemp)
sed -e "s|power_supply/BAT1/|power_supply/${BAT:-BAT0}/|" \
    -e "s|backlight/intel_backlight|backlight/${BL:-intel_backlight}|" \
    "$REPO_DIR/files/conky/disk.lua" > "$TMP"
install_file "$TMP" "$DST/disk.lua"
rm -f "$TMP"

TMP=$(mktemp)
printf '[Desktop Entry]\nType=Application\nName=Conky (cinnamon-macos-style)\nExec=sh -c "sleep 5 && conky -c %s/hari.conf && conky -c %s/ram.conf && conky -c %s/disk.conf"\nX-GNOME-Autostart-enabled=true\n' "$DST" "$DST" "$DST" > "$TMP"
install_file "$TMP" "$HOME/.config/autostart/cmstyle-conky.desktop"
rm -f "$TMP"

if [ "$DRY_RUN" != 1 ]; then
  for w in hari ram disk; do
    pkill -u "$(id -u)" -f "conky -c $DST/$w.conf" 2>/dev/null
    (cd "$HOME" && setsid nohup conky -c "$DST/$w.conf" >/dev/null 2>&1 < /dev/null &)
  done
  ok "widget Conky dijalankan"
fi
note "Suhu CPU dibaca dari sensor 'coretemp' (Intel). Di AMD, ubah nama sensor di disk.lua (fungsi cpu_temp)."
