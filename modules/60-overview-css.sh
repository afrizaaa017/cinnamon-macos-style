# Modul: overview-css  (di-source oleh install.sh)
# Mempercantik tampilan Overview dan Alt+Tab Cinnamon (label kapsul, bingkai terpilih, latar redup)
# dengan menambahkan blok CSS ke salinan pengguna tema WhiteSur-Dark. Berkas sistem tidak disentuh.

TEMA=WhiteSur-Dark
CSS="$HOME/.themes/$TEMA/cinnamon/cinnamon.css"
PENANDA="cinnamon-macos-style"

if [ ! -f "$CSS" ]; then
  if [ -d "/usr/share/themes/$TEMA/cinnamon" ]; then
    note "Tema $TEMA terpasang di sistem. Modul ini butuh SALINAN di ~/.themes (berkas sistem tidak diubah)."
    ask "Salin /usr/share/themes/$TEMA ke ~/.themes sekarang?" || { warn "dilewati"; return 0; }
    if [ "$DRY_RUN" != 1 ]; then
      mkdir -p "$HOME/.themes"
      cp -r "/usr/share/themes/$TEMA" "$HOME/.themes/$TEMA"
      restore_line "rm -rf $(printf '%q' "$HOME/.themes/$TEMA")   # salinan yang dibuat pemasang"
    fi
  else
    warn "tema $TEMA belum terpasang (lihat docs/DEPENDENCIES.md); dilewati"; return 0
  fi
fi

if grep -q "$PENANDA" "$CSS" 2>/dev/null; then
  ok "blok CSS sudah ada, tidak ditambahkan dua kali"
  return 0
fi
if [ "$DRY_RUN" = 1 ]; then note "[dry-run] menambahkan $(wc -l < "$REPO_DIR/files/overview.css") baris CSS ke $CSS"; return 0; fi

backup_file "$CSS"
{ echo; cat "$REPO_DIR/files/overview.css"; } >> "$CSS"
ok "CSS Overview ditambahkan ke $CSS"
note "Agar terbaca: ganti tema Cinnamon ke tema lain lalu kembali ke $TEMA (Pengaturan Sistem > Tema)."
