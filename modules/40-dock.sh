# Modul: dock  (di-source oleh install.sh)
# Plank (dock bergaya macOS) dengan tema MacCard, dan "penanda dock": garis tipis di tengah
# bawah layar yang menunjukkan di mana dock tersembunyi, hilang saat dock muncul.

have plank || { warn "plank belum terpasang (sudo apt install plank); modul dock dilewati"; return 0; }

# --- tema MacCard ---
install_file "$REPO_DIR/files/plank/MacCard/dock.theme" "$HOME/.local/share/plank/themes/MacCard/dock.theme"

# --- pengaturan Plank (dconf). Nilai lama dicatat; yang sebelumnya belum diatur akan di-reset ---
D=/net/launchpad/plank/docks/dock1
dc() { # dc KUNCI NILAI
  local lama
  lama=$(dconf read "$D/$1" 2>/dev/null)
  if [ "$DRY_RUN" = 1 ]; then printf '    [dry-run] dconf write %s/%s %s (sekarang: %s)\n' "$D" "$1" "$2" "${lama:-belum diatur}"; return 0; fi
  if [ -n "$lama" ]; then restore_line "dconf write $D/$1 $(printf '%q' "$lama")"; else restore_line "dconf reset $D/$1"; fi
  dconf write "$D/$1" "$2" && ok "plank $1 = $2"
}
dc theme "'MacCard'"
dc hide-mode "'auto'"          # sembunyi otomatis, muncul saat kursor menyentuh tepi bawah
dc position "'bottom'"
dc icon-size 36
dc zoom-enabled true
dc zoom-percent 160
dc hide-delay 300
dc unhide-delay 0

# --- penanda dock (butuh python3-gi, python3-gi-cairo, wmctrl, x11-utils) ---
FALTA=$(paket_belum python3-gi python3-gi-cairo gir1.2-gtk-3.0 wmctrl x11-utils | tr '\n' ' ')
[ -n "${FALTA// /}" ] && warn "penanda dock butuh paket: $FALTA"
BIN="$HOME/.local/bin"
install_file "$REPO_DIR/files/dock-hint.py" "$BIN/dock-hint.py" 755
TMP=$(mktemp)
printf '[Desktop Entry]\nType=Application\nName=Penanda dock\nExec=%s/dock-hint.py\nX-GNOME-Autostart-enabled=true\n' "$BIN" > "$TMP"
install_file "$TMP" "$HOME/.config/autostart/cmstyle-dock-hint.desktop"
rm -f "$TMP"

# Plank sendiri harus ikut jalan saat login
if [ ! -e "$HOME/.config/autostart/plank.desktop" ] && [ ! -e /etc/xdg/autostart/plank.desktop ]; then
  TMP=$(mktemp)
  printf '[Desktop Entry]\nType=Application\nName=Plank\nExec=plank\nX-GNOME-Autostart-enabled=true\n' > "$TMP"
  install_file "$TMP" "$HOME/.config/autostart/plank.desktop"
  rm -f "$TMP"
fi

if [ "$DRY_RUN" != 1 ]; then
  pkill -u "$(id -u)" -x plank 2>/dev/null; sleep 1
  setsid nohup plank >/dev/null 2>&1 < /dev/null &
  pkill -u "$(id -u)" -f "[d]ock-hint.py" 2>/dev/null; sleep 1
  setsid nohup "$BIN/dock-hint.py" >/dev/null 2>&1 < /dev/null &
  ok "Plank dan penanda dock dijalankan ulang"
fi
