#!/bin/bash
# Pemeriksa kebocoran data pribadi. JALANKAN SEBELUM menerbitkan ke GitHub/blog.
#   ./tools/cek-privasi.sh            periksa seluruh repositori
#   ./tools/cek-privasi.sh <folder>   periksa folder lain
#
# Skrip ini membaca identitas PENGGUNA YANG MENJALANKANNYA (nama akun, nama komputer, nama dan
# email Git) lalu mencari jejaknya di semua berkas teks. Ia juga mencari pola umum: jalur /home,
# alamat email, IP, kunci/token, dan teks di dalam gambar. Keluar dengan status 1 bila ada temuan.
set -u
ROOT=$(cd "${1:-$(dirname "$0")/..}" && pwd)
SELF=$(basename "$0")
temuan=0

merah()  { printf '\033[31m%s\033[0m\n' "$*"; }
hijau()  { printf '\033[32m%s\033[0m\n' "$*"; }

cari() { # cari "judul" "regex" [grep-v regex pengecualian]
  local judul=$1 pola=$2 kecuali=${3:-^$}
  local hasil
  hasil=$(grep -rIniE --exclude-dir=.git --exclude="$SELF" -e "$pola" "$ROOT" 2>/dev/null | grep -viE "$kecuali" | head -15)
  if [ -n "$hasil" ]; then
    merah "[TEMUAN] $judul"; echo "$hasil" | sed "s|$ROOT/|  |"; temuan=1
  fi
}

echo "Memeriksa: $ROOT"
# 1. identitas pemeriksa (dibaca saat dijalankan, tidak tertulis di repositori)
for kata in "$USER" "$(hostname 2>/dev/null)" "$(git config user.name 2>/dev/null)" "$(git config --global user.name 2>/dev/null)"; do
  [ "${#kata}" -ge 4 ] && cari "mengandung '$kata' (nama akun/komputer/Git Anda)" "$(printf '%s' "$kata" | sed 's/[][\.*^$/]/\\&/g')"
done
for em in "$(git config user.email 2>/dev/null)" "$(git config --global user.email 2>/dev/null)"; do
  [ -n "$em" ] && cari "mengandung email Git Anda" "$(printf '%s' "$em" | sed 's/[][\.*^$/]/\\&/g')"
done
# 2. pola umum
cari "jalur rumah pengguna (/home/NAMA atau /Users/NAMA)" "(/home/|/Users/)[A-Za-z0-9._-]+" "(/home/(NAMA|USER|nama|user|<)|/Users/(NAMA|USER|<))"
cari "alamat email" "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}" "(noreply\.github\.com|example\.(com|org)|@(types|babel)/|@cinnamon\.org)"
cari "alamat IP" "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" "(127\.0\.0\.1|0\.0\.0\.0|255\.255\.|\b[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+[-/]|version|v[0-9])"
cari "alamat MAC" "\b([0-9a-f]{2}:){5}[0-9a-f]{2}\b"
cari "kunci/token/kata sandi" "(ghp_[A-Za-z0-9]{20,}|github_pat_|AKIA[0-9A-Z]{12,}|xox[baprs]-|BEGIN [A-Z ]*PRIVATE KEY|api[_-]?key[\"' ]*[:=]|password[\"' ]*[:=]|secret[\"' ]*[:=])"

# 3. gambar: teks tersembunyi (metadata) yang memuat identitas
if command -v strings >/dev/null 2>&1; then
  while IFS= read -r -d '' img; do
    for kata in "$USER" "$(hostname 2>/dev/null)"; do
      [ "${#kata}" -ge 4 ] && strings "$img" | grep -qiF -- "$kata" && { merah "[TEMUAN] gambar memuat '$kata' di metadatanya: ${img#"$ROOT"/}"; temuan=1; }
    done
  done < <(find "$ROOT" -path "$ROOT/.git" -prune -o -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) -print0)
fi

# 4. berkas besar atau mencurigakan
besar=$(find "$ROOT" -path "$ROOT/.git" -prune -o -type f -size +5M -print | sed "s|$ROOT/|  |")
[ -n "$besar" ] && { merah "[TEMUAN] berkas > 5 MB (periksa apakah memang boleh dibagikan):"; echo "$besar"; temuan=1; }
aneh=$(find "$ROOT" -path "$ROOT/.git" -prune -o -type f \( -name '.env' -o -name '*.pem' -o -name '*.key' -o -name 'id_rsa*' -o -name '*.kdbx' -o -name '*.sqlite' -o -name '.bash_history' -o -name 'credentials*' \) -print | sed "s|$ROOT/|  |")
[ -n "$aneh" ] && { merah "[TEMUAN] berkas yang tidak seharusnya dibagikan:"; echo "$aneh"; temuan=1; }

echo
echo "Daftar berkas yang akan ikut dibagikan (periksa dengan mata Anda sendiri):"
find "$ROOT" -path "$ROOT/.git" -prune -o -type f -print | sed "s|$ROOT/|  |" | sort
echo
if [ "$temuan" = 0 ]; then hijau "BERSIH: tidak ada jejak identitas, email, IP, kunci, atau token yang terdeteksi."; echo "Tetap lihat daftar berkas dan tangkapan layar secara manual sebelum menerbitkan."
else merah "ADA TEMUAN di atas. Perbaiki dulu sebelum menerbitkan."; exit 1; fi
