#!/bin/bash
# Fungsi bersama untuk semua modul. Dipakai lewat:  source modules/lib.sh
# Aturan keamanan: semua perubahan dicadangkan dulu, dicatat di restore.sh, dan
# tidak ada yang mengirim data keluar atau mengunduh apa pun.

DRY_RUN=${DRY_RUN:-0}
ASSUME_YES=${ASSUME_YES:-0}
BACKUP_DIR=${BACKUP_DIR:-}
RESTORE_FILE=${RESTORE_FILE:-}
REPO_DIR=${REPO_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}

say()  { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
ok()   { printf '    \033[32m[ok]\033[0m %s\n' "$*"; }
note() { printf '    %s\n' "$*"; }
warn() { printf '    \033[33m[lewati]\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[31m[galat]\033[0m %s\n' "$*" >&2; exit 1; }

# ask "pertanyaan?"  -> status 0 bila dijawab ya
ask() {
  [ "$ASSUME_YES" = 1 ] && return 0
  [ -t 0 ] || return 1
  local jawab
  read -r -p "    $1 [y/N] " jawab
  case "$jawab" in y|Y|ya|YA|Ya) return 0 ;; *) return 1 ;; esac
}

# run perintah...  -> hanya dicetak bila --dry-run
run() {
  if [ "$DRY_RUN" = 1 ]; then printf '    [dry-run] %s\n' "$*"; return 0; fi
  "$@"
}

have() { command -v "$1" >/dev/null 2>&1; }

init_backup() {
  [ -n "$BACKUP_DIR" ] && return 0
  BACKUP_DIR="$HOME/.cinnamon-macos-style-backup/$(date +%Y%m%d-%H%M%S)"
  RESTORE_FILE="$BACKUP_DIR/restore.sh"
  export BACKUP_DIR RESTORE_FILE
  [ "$DRY_RUN" = 1 ] && return 0
  mkdir -p "$BACKUP_DIR/files"
  {
    echo '#!/bin/bash'
    echo '# Dibuat otomatis oleh install.sh. Mengembalikan keadaan sebelum pemasangan.'
  } > "$RESTORE_FILE"
  chmod 700 "$BACKUP_DIR"; chmod +x "$RESTORE_FILE"
}

restore_line() { [ "$DRY_RUN" = 1 ] || echo "$*" >> "$RESTORE_FILE"; }

# gs_set SKEMA KUNCI NILAI  -> simpan nilai lama, lalu atur nilai baru
gs_set() {
  local skema=$1 kunci=$2 nilai=$3 lama
  if ! gsettings list-keys "$skema" 2>/dev/null | grep -qx "$kunci"; then
    warn "kunci $skema $kunci tidak ada di sistem ini"; return 0
  fi
  lama=$(gsettings get "$skema" "$kunci")
  if [ "$DRY_RUN" = 1 ]; then printf '    [dry-run] gsettings set %s %s %s  (sekarang: %s)\n' "$skema" "$kunci" "$nilai" "$lama"; return 0; fi
  restore_line "gsettings set $skema $kunci $(printf '%q' "$lama")"
  gsettings set "$skema" "$kunci" "$nilai" && ok "$kunci = $nilai"
}

# backup_file BERKAS  -> salin berkas lama; bila belum ada, catat agar dihapus saat dibatalkan
backup_file() {
  local f=$1
  [ "$DRY_RUN" = 1 ] && return 0
  if [ -e "$f" ]; then
    mkdir -p "$BACKUP_DIR/files$(dirname "$f")"
    cp -a "$f" "$BACKUP_DIR/files$f"
    restore_line "cp -a $(printf '%q' "$BACKUP_DIR/files$f") $(printf '%q' "$f")"
  else
    restore_line "rm -f $(printf '%q' "$f")"
  fi
}

# install_file SUMBER TUJUAN [mode]
install_file() {
  local src=$1 dst=$2 mode=${3:-644}
  if [ "$DRY_RUN" = 1 ]; then printf '    [dry-run] pasang %s -> %s\n' "${src#"$REPO_DIR"/}" "$dst"; return 0; fi
  backup_file "$dst"
  mkdir -p "$(dirname "$dst")"
  install -m "$mode" "$src" "$dst" && ok "terpasang: $dst"
}

# Pengecek keberadaan tema/font (hanya membaca, tidak mengubah apa pun)
gtk_theme_ada()    { [ -d "$HOME/.themes/$1" ] || [ -d "/usr/share/themes/$1" ]; }
icon_theme_ada()   { [ -d "$HOME/.icons/$1" ] || [ -d "$HOME/.local/share/icons/$1" ] || [ -d "/usr/share/icons/$1" ]; }
font_ada()         { fc-list 2>/dev/null | grep -qiE -- "$1"; }
cinnamon_aktif()   { case "${XDG_CURRENT_DESKTOP:-}" in *Cinnamon*) return 0 ;; *) return 1 ;; esac; }

# paket_belum LIST... -> cetak nama paket apt yang belum terpasang
paket_belum() {
  local p
  for p in "$@"; do dpkg -s "$p" >/dev/null 2>&1 || printf '%s\n' "$p"; done
}
