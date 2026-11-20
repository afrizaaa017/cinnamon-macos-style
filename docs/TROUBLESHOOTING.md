# Pemecahan masalah

Semua yang di bawah ini adalah masalah yang benar-benar ditemui saat menyusun paket ini.

> **Saat melaporkan masalah (misalnya di issue GitHub)**, jangan tempel keluaran perintah
> mentah. Hapus nama akun, nama komputer, jalur rumah (mis. /home/NAMA), alamat IP, dan nama jaringan Wi-Fi
> dulu. Jalankan `./tools/cek-privasi.sh <folder-berisi-log>` untuk memeriksanya.

## Tema dan tampilan

**Tema WhiteSur tidak terpakai / Overview tidak berubah setelah modul `overview-css`.**
CSS tema hanya dibaca saat tema dimuat. Ganti tema Cinnamon ke tema lain lalu kembali ke
`WhiteSur-Dark` (Pengaturan Sistem > Tema), atau logout lalu login.

**Modul `cinnamon` melewati bagian tema/ikon/kursor.** Itu berarti tema belum terpasang. Lihat
[DEPENDENCIES](DEPENDENCIES.md). Cek: `ls ~/.themes ~/.icons /usr/share/themes | grep -i whitesur`.

**Efek jendela terasa tidak ada.** Animasi bawaan Cinnamon hanya 120 ms (di kodenya), jadi
memang nyaris tak terasa. Slider kecepatan hanya mengalikannya 0,6 sampai 1,4 kali. Pasang
Magic Lamp bila ingin efek yang terasa untuk minimize.

## Dock

**Dock Plank tidak muncul saat kursor menyentuh tepi bawah.** Bila Anda memindahkan atau
mengubah panel setelah Plank berjalan, Plank bisa tertinggal di posisi lama (naik setinggi panel
yang dulu ada) sehingga zona pemicunya tidak di tepi layar. Restart:

```bash
pkill -x plank; plank &
```

**Garis penanda dock tidak terlihat.** Pastikan jalan: `pgrep -af dock-hint`. Bila kursor sedang
dekat zona dock, garis memang disembunyikan. Butuh paket `wmctrl x11-utils python3-gi python3-gi-cairo`.

## Terminal

**Pengaturan terminal tidak berlaku.** `xfce4-terminal` 1.1.x menyimpan pengaturan di **xfconf**,
bukan di `~/.config/xfce4/terminal/terminalrc`. Menyunting `terminalrc` tidak berpengaruh.
Periksa dengan `xfconf-query -c xfce4-terminal -lv`. Jendela yang sudah terbuka tetap memakai
tampilan lama; buka jendela baru.

**Terlalu transparan / terlalu pekat.** `KEPEKATAN=0.8 ./install.sh terminal`. Atau langsung:
`xfconf-query -c xfce4-terminal -p /background-darkness -s 0.8`.

## Gestur touchpad

**Geser 3 jari tidak berbuat apa-apa.** Periksa berurutan:

```bash
systemctl is-active touchegg      # daemon harus: active
pgrep -ax touchegg                # harus ada proses klien milik Anda
gsettings get org.cinnamon.gestures enabled   # sebaiknya false (agar tidak bentrok)
```

Bila klien tidak ada: `touchegg &`. Pastikan `~/.config/touchegg/touchegg.conf` berisi jalur
`overview.sh` yang benar (pemasang menggantinya dengan folder rumah Anda). Uji skripnya
langsung: `~/.local/bin/overview.sh` seharusnya membuka/menutup Overview.

**Alt+Tab lewat gestur melompat banyak.** Tombol Tab yang ditahan memicu auto-repeat. Itu perilaku
Alt+Tab biasa; geser lebih pendek.

## Ekstensi genie (Magic Lamp)

**Nilai baru (durasi, jenis efek) tidak berlaku.** Ekstensi membaca pengaturannya saat dimuat.
Nonaktifkan lalu aktifkan lagi di Pengaturan Sistem > Ekstensi.

**Jendela Steam hitam saat minimize.** Keterbatasan yang diketahui dari ekstensinya.

**Mau mematikan genie.** Nonaktifkan ekstensinya; efek minimize kembali ke `fade`.

## Conky

**Widget tidak muncul.** Cek font (`fc-list | grep -iE "montserrat|titillium|awesome"`) dan paket
`conky-all` (versi biasa tidak punya dukungan Cairo/Lua). Lihat pesan galat:
`conky -c ~/.config/conky/disk.conf` di terminal.

**Baterai atau kecerahan menampilkan `?` atau `-`.** Nama perangkat berbeda di tiap laptop.
Cek `ls /sys/class/power_supply /sys/class/backlight` dan sesuaikan di `~/.config/conky/disk.lua`.

**Suhu CPU kosong (AMD).** Fungsi `cpu_temp` di `disk.lua` mencari sensor `coretemp` (Intel).
Ganti ke nama sensor Anda (`k10temp` untuk AMD).

## Mengembalikan semuanya

```bash
./uninstall.sh --list
./uninstall.sh
```

Pemasang tidak menyentuh GRUB, layar login, atau berkas sistem, jadi tidak ada risiko tak bisa
boot. Bila sesuatu salah di desktop, pilih sesi lain (misalnya Xfce) di layar login atau buka
TTY (`Ctrl+Alt+F3`) lalu jalankan `./uninstall.sh`.
