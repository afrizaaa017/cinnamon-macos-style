# Komponen pihak ketiga

Repositori ini **tidak menyertakan** tema, ikon, kursor, font, maupun ekstensi milik pihak lain.
Semuanya dipasang dari sumber resminya, dan Anda yang memutuskan memercayainya. Periksa lisensi di
halaman masing-masing proyek sebelum membagikan ulang apa pun.

## Daftar

| Komponen | Fungsi | Cara memasang | Sumber |
|---|---|---|---|
| **WhiteSur GTK theme** | Tema gelap (GTK, Cinnamon, bingkai jendela) | Ikuti README proyeknya | https://github.com/vinceliuice/WhiteSur-gtk-theme |
| **Papirus** | Tema ikon | `sudo apt install papirus-icon-theme` | https://github.com/PapirusDevelopmentTeam/papirus-icon-theme |
| **Bibata** | Tema kursor | Unduh rilis, ekstrak ke `~/.icons` | https://github.com/ful1e5/Bibata_Cursor |
| **Inter** | Font antarmuka | `sudo apt install fonts-inter` | https://github.com/rsms/inter |
| **JetBrains Mono** | Font terminal | `sudo apt install fonts-jetbrains-mono` | https://github.com/JetBrains/JetBrainsMono |
| **Plank** | Dock | `sudo apt install plank` | https://launchpad.net/plank |
| **Touchégg** | Gestur touchpad | `sudo apt install touchegg` | https://github.com/JoseExposito/touchegg |
| **xfce4-terminal** | Terminal | `sudo apt install xfce4-terminal` | https://docs.xfce.org/apps/xfce4-terminal |
| **Magic Lamp Effect** | Efek genie (ekstensi Cinnamon) | Manual, lihat di bawah | https://github.com/klangman/CinnamonMagicLamp |
| Montserrat, Font Awesome *(Conky)* | Font widget | `sudo apt install fonts-montserrat fonts-font-awesome` | |
| **Titillium Web** *(Conky)* | Font widget | Manual, lihat di bawah (tidak ada di apt) | Google Fonts |
| **conky-all** *(Conky)* | Widget desktop | `sudo apt install conky-all` | https://github.com/brndnmtthws/conky |

Paket pendukung untuk skrip: `wmctrl x11-utils xinput python3-gi python3-gi-cairo gir1.2-gtk-3.0 dconf-cli libglib2.0-bin`.
Pemasang menawarkan `sudo apt install` untuk semua yang belum ada, dan hanya jalan bila Anda
menjawab `y`.

## Memasang WhiteSur

Cara pasti dan opsi terbarunya ada di README proyek WhiteSur; ikuti itu. Pastikan komponen
**GTK** dan **Cinnamon**-nya ikut terpasang (varian gelap, `WhiteSur-Dark`). Hasilnya biasanya
ada di `~/.themes/WhiteSur-Dark` (pemasangan pengguna) atau `/usr/share/themes` (sistem).
Modul `overview-css` bekerja pada salinan di `~/.themes`; bila temanya terpasang di sistem,
modul akan menawarkan membuat salinan pengguna dan tidak mengubah berkas sistem.

## Memasang kursor Bibata

1. Unduh arsip `Bibata-Modern-Classic` dari halaman rilis proyeknya.
2. Ekstrak: `mkdir -p ~/.icons && tar -xf Bibata-Modern-Classic.tar.xz -C ~/.icons`.
3. Cek: `ls ~/.icons | grep Bibata`.

## Memasang font Titillium Web (opsional, hanya untuk Conky)

1. Unduh keluarga **Titillium Web** dari Google Fonts.
2. Salin berkas `.ttf` ke `~/.local/share/fonts/` lalu jalankan `fc-cache -f`.
3. Cek: `fc-list | grep -i titillium`.

## Magic Lamp Effect (genie)

Ini **kode JavaScript pihak ketiga yang berjalan di dalam Cinnamon**. Sebelum memakainya:

1. Lihat sumbernya di GitHub (tautan di tabel). Ukurannya kecil, sehingga bisa dibaca sendiri.
2. Pasang lewat **Pengaturan Sistem > Ekstensi > tab Unduh**, cari *Magic Lamp Effect*, lalu aktifkan.
3. Jalankan `./install.sh magiclamp` untuk menyetel durasi 250 ms dan efek melengkung.
4. Muat ulang ekstensi (nonaktifkan lalu aktifkan) agar nilai baru terbaca.

Hal yang perlu diketahui:
- Ekstensi mengambil alih efek **minimize dan unminimize** saja. Efek buka/tutup jendela tidak
  berubah.
- Aplikasi Steam dilaporkan tampil hitam saat diminimalkan.
- Tujuan sedotan adalah dasar layar. Bila daftar jendela panel dihapus, tidak ada tombol jendela
  sebagai target.
- Untuk membatalkan: nonaktifkan di jendela Ekstensi, atau hapus
  `~/.local/share/cinnamon/extensions/CinnamonMagicLamp@klangman`.
