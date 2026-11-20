# Modul: gestures  (di-source oleh install.sh)
# Gestur touchpad lewat Touchégg:
#   geser 3 jari ke atas   : Overview (semua jendela)       [di XFCE: xfdashboard]
#   geser 3 jari ke bawah  : tampilkan desktop
#   geser 3 jari kiri/kanan: Alt+Tab berulang (jendela berikutnya/sebelumnya)
# Plus skrip kecil yang menerapkan scroll alami dan tap-to-click setiap login.

have touchegg || { warn "touchegg belum terpasang (sudo apt install touchegg); modul gestur dilewati"; return 0; }

BIN="$HOME/.local/bin"
install_file "$REPO_DIR/files/overview.sh"       "$BIN/overview.sh" 755
install_file "$REPO_DIR/files/natural-scroll.sh" "$BIN/natural-scroll.sh" 755

# touchegg.conf memuat jalur skrip; tempat pengguna dituliskan saat pemasangan (bukan di repositori)
TMP=$(mktemp)
sed "s|__HOME__|$HOME|g" "$REPO_DIR/files/touchegg.conf" > "$TMP"
install_file "$TMP" "$HOME/.config/touchegg/touchegg.conf"
rm -f "$TMP"

# autostart skrip touchpad
TMP=$(mktemp)
printf '[Desktop Entry]\nType=Application\nName=Touchpad: scroll alami dan tap\nExec=%s/natural-scroll.sh\nX-GNOME-Autostart-enabled=true\n' "$BIN" > "$TMP"
install_file "$TMP" "$HOME/.config/autostart/cmstyle-natural-scroll.desktop"
rm -f "$TMP"

# muat ulang klien Touchégg milik pengguna (daemon sistemnya tidak disentuh)
if [ "$DRY_RUN" != 1 ]; then
  pkill -u "$(id -u)" -x touchegg 2>/dev/null
  sleep 1
  setsid nohup touchegg >/dev/null 2>&1 < /dev/null &
  ok "klien Touchégg dimuat ulang"
fi
note "Gestur memakai daemon Touchégg yang berjalan sebagai layanan sistem (dipasang oleh paketnya)."
