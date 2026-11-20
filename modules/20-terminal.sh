# Modul: terminal  (di-source oleh install.sh)
# Tema xfce4-terminal: palet hijau gelap, JetBrains Mono, transparan ringan, tanpa menu/scrollbar.
#
# PENTING: xfce4-terminal 1.1.x menyimpan pengaturan di xfconf (bukan berkas terminalrc).
# Menulis terminalrc tidak berpengaruh apa pun di versi itu.

have xfce4-terminal && have xfconf-query || { warn "xfce4-terminal/xfconf-query tidak ada (sudo apt install xfce4-terminal)"; return 0; }
font_ada "JetBrains Mono" || warn "font JetBrains Mono belum terpasang (sudo apt install fonts-jetbrains-mono); terminal akan memakai font cadangan"

KEPEKATAN=${KEPEKATAN:-0.70}     # 1.0 = pekat penuh, makin kecil makin transparan

if [ "$DRY_RUN" != 1 ]; then
  xfconf-query -c xfce4-terminal -lv > "$BACKUP_DIR/xfce4-terminal-xfconf.txt" 2>/dev/null || true
  restore_line "# xfce4-terminal: pengaturan lama ada di $BACKUP_DIR/xfce4-terminal-xfconf.txt"
  restore_line "xfconf-query -c xfce4-terminal -r -R -p / 2>/dev/null || true   # kembali ke bawaan"
fi

xs() { run xfconf-query -c xfce4-terminal -p "/$1" -n -t string -s "$2"; }
xb() { run xfconf-query -c xfce4-terminal -p "/$1" -n -t bool   -s "$2"; }
xd() { run xfconf-query -c xfce4-terminal -p "/$1" -n -t double -s "$2"; }
xi() { run xfconf-query -c xfce4-terminal -p "/$1" -n -t int    -s "$2"; }

xs font-name "JetBrains Mono 11";                 xb font-use-system false
xb misc-menubar-default false;                    xb misc-toolbar-default false
xs misc-default-geometry "110x30";                xb misc-cursor-blinks true
xs misc-cursor-shape "TERMINAL_CURSOR_SHAPE_IBEAM"
xs scrolling-bar "TERMINAL_SCROLLBAR_NONE";       xi scrolling-lines 10000
xs background-mode "TERMINAL_BACKGROUND_TRANSPARENT"; xd background-darkness "$KEPEKATAN"
xs color-foreground "#d3e3dd";                    xs color-background "#0d1117"
xs color-cursor "#6fcf97";                        xb color-cursor-use-default false
xb color-selection-use-default false;             xs color-selection "#0d1117"
xs color-selection-background "#6fcf97"
xs color-palette "#1b2028;#e06c75;#6fcf97;#e5c07b;#61afef;#c678dd;#56b6c2;#c9d3dc;#5c6773;#ff7b86;#8be3ad;#f0d08c;#7cc0ff;#d78ee8;#6fd0dc;#ffffff"

[ "$DRY_RUN" = 1 ] || ok "tema terminal diterapkan (jendela terminal yang sudah terbuka baru berubah setelah ditutup)"
