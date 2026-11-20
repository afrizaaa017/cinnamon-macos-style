# Modul: cinnamon  (di-source oleh install.sh, jangan dijalankan langsung)
# Tema, ikon, kursor, font, Alt+Tab Coverflow, efek jendela, layar kunci, touchpad.
# Semua lewat gsettings; nilai lama dicatat sehingga bisa dikembalikan.

cinnamon_aktif || { warn "Bukan sesi Cinnamon (XDG_CURRENT_DESKTOP='${XDG_CURRENT_DESKTOP:-kosong}'). Login ke Cinnamon lalu jalankan lagi."; return 0; }

ICON_THEME=${ICON_THEME:-Papirus-Dark}        # ubah bila ingin ikon lain: ICON_THEME=Yaru ./install.sh
CURSOR_THEME=${CURSOR_THEME:-Bibata-Modern-Classic}
GTK_THEME_NAME=${GTK_THEME_NAME:-WhiteSur-Dark}

# --- tema (hanya bila sudah terpasang; lihat docs/DEPENDENCIES.md cara memasangnya) ---
if gtk_theme_ada "$GTK_THEME_NAME"; then
  [ -d "$HOME/.themes/$GTK_THEME_NAME/cinnamon" ] || [ -d "/usr/share/themes/$GTK_THEME_NAME/cinnamon" ] \
    && gs_set org.cinnamon.theme name "'$GTK_THEME_NAME'"
  gs_set org.cinnamon.desktop.interface gtk-theme "'$GTK_THEME_NAME'"
  gs_set org.cinnamon.desktop.wm.preferences theme "'$GTK_THEME_NAME'"
else
  warn "tema $GTK_THEME_NAME belum terpasang; bagian tema dilewati (lihat docs/DEPENDENCIES.md)"
fi
icon_theme_ada "$ICON_THEME"   && gs_set org.cinnamon.desktop.interface icon-theme "'$ICON_THEME'"   || warn "ikon $ICON_THEME belum terpasang"
icon_theme_ada "$CURSOR_THEME" && gs_set org.cinnamon.desktop.interface cursor-theme "'$CURSOR_THEME'" || warn "kursor $CURSOR_THEME belum terpasang"

# --- font ---
if font_ada "Inter"; then
  gs_set org.cinnamon.desktop.interface font-name "'Inter 10'"
  gs_set org.cinnamon.desktop.screensaver font-time "'Inter 72'"
  gs_set org.cinnamon.desktop.screensaver font-date "'Inter 22'"
  gs_set org.cinnamon.desktop.screensaver font-message "'Inter 14'"
else
  warn "font Inter belum terpasang (sudo apt install fonts-inter); bagian font dilewati"
fi
gs_set org.cinnamon.desktop.screensaver date-format "'%A, %-e %B %Y'"
gs_set org.cinnamon.desktop.screensaver show-album-art false

# --- Alt+Tab dan efek jendela ---
gs_set org.cinnamon alttab-switcher-style "'coverflow'"
gs_set org.cinnamon desktop-effects true
gs_set org.cinnamon desktop-effects-map "'traditional'"
gs_set org.cinnamon desktop-effects-close "'traditional'"
gs_set org.cinnamon desktop-effects-minimize "'fade'"        # ditimpa Magic Lamp bila dipasang
gs_set org.cinnamon desktop-effects-change-size true
gs_set org.cinnamon desktop-effects-on-dialogs true
gs_set org.cinnamon desktop-effects-on-menus true
gs_set org.cinnamon window-effect-speed 0                    # 0 = paling lambat (efek lebih terasa)

# --- touchpad: scroll alami dan ketuk untuk klik ---
gs_set org.cinnamon.desktop.peripherals.touchpad natural-scroll true
gs_set org.cinnamon.desktop.peripherals.touchpad tap-to-click true

# --- terminal bawaan: xfce4-terminal (hanya bila terpasang) ---
if have xfce4-terminal; then
  gs_set org.cinnamon.desktop.default-applications.terminal exec "'xfce4-terminal'"
fi

# --- opsional: sembunyikan ikon partisi di desktop ---
if ask "Sembunyikan ikon partisi/drive dari desktop?"; then
  gs_set org.nemo.desktop volumes-visible false
fi
