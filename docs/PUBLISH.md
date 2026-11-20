# Panduan menerbitkan dengan aman

Dokumen ini untuk pemilik repositori (bukan pengguna). Tujuannya: bagikan racikan Anda tanpa
membocorkan data pribadi. Lakukan berurutan.

## 1. Periksa isi repositori

```bash
./tools/cek-privasi.sh
```

Alat ini membaca **nama akun, nama komputer, serta nama dan email Git Anda**, lalu mencari
jejaknya di semua berkas, ditambah jalur `/home`, email, IP, MAC, token, dan metadata gambar.
Harus berakhir dengan **BERSIH**. Setelah itu tetap baca daftar berkas yang dicetaknya dengan
mata Anda sendiri; alat otomatis tidak menangkap semuanya.

## 2. Tangkapan layar yang aman

Tangkapan layar adalah sumber kebocoran paling umum. Sebelum memotret:

- [ ] Tutup semua jendela pribadi (chat, email, browser dengan tab pribadi, editor berisi kode lain).
- [ ] Pindah ke workspace kosong dan buka hanya jendela contoh.
- [ ] Prompt terminal tidak boleh menampilkan `nama@komputer`. Pakai `PS1='$ '` sebelum memotret.
- [ ] Judul jendela dan jalur berkas jangan memuat nama akun Anda.
- [ ] Notifikasi, jam yang menunjukkan jadwal pribadi, dan nama Wi-Fi tidak ikut terlihat.
- [ ] Gunakan **wallpaper yang boleh dibagikan** (buatan sendiri atau berlisensi bebas). Wallpaper
      dari situs bergambar sering punya syarat atribusi/lisensi yang melarang tayang ulang.
- [ ] Simpan sebagai PNG baru dari tangkapan, bukan hasil sunting dari foto yang punya metadata EXIF.

Letakkan di `docs/images/` lalu jalankan `./tools/cek-privasi.sh` lagi (ia ikut memeriksa
metadata gambar).

## 3. Atur identitas Git yang tidak membuka email

Setiap *commit* mencantumkan nama dan email, dan itu **publik selamanya** di repositori publik.

```bash
git config user.name  "Nama Panggung Anda"
git config user.email "ID+username@users.noreply.github.com"
```

Alamat `noreply` ada di GitHub: *Settings > Emails*. Aktifkan juga **"Keep my email addresses
private"** dan **"Block command line pushes that expose my email"**.

## 4. Isi nama di LICENSE dan README

- `LICENSE`: ganti `<ISI NAMA ANDA ATAU NAMA PANGGUNG DI SINI>` dengan nama yang mau Anda
  tampilkan (boleh nama panggung).
- `README.md`: ganti `NAMA-ANDA` pada tautan `git clone` dengan username GitHub Anda.

## 5. Terbitkan

```bash
git init
git add .
git status          # BACA daftarnya. Pastikan tak ada berkas yang tidak Anda kenal.
git commit -m "Versi awal cinnamon-macos-style"
git branch -M main
git remote add origin https://github.com/USERNAME/cinnamon-macos-style.git
git push -u origin main
```

Buat dulu repositorinya di GitHub (kosong, tanpa README otomatis). Mulai dengan **privat** bila
ingin menguji dulu, lalu ubah ke publik setelah yakin.

## 6. Untuk tulisan blog

- Sebut jelas bahwa ini **diuji di satu perangkat** (lihat bagian Persyaratan README).
- Jangan menjanjikan angka performa yang tidak Anda ukur sendiri.
- Tautkan ke proyek pihak ketiga (WhiteSur, Papirus, Magic Lamp, dst.) dan hormati lisensinya;
  jangan menyalin file mereka ke repositori Anda.
- Cantumkan cara membatalkan (`./uninstall.sh`) agar pembaca merasa aman mencoba.

## Bila terlanjur membocorkan sesuatu

- **Rahasia (token, kata sandi, kunci)**: anggap sudah terbaca siapa pun. Cabut/ganti segera di
  layanan terkait. Menghapus commit saja tidak cukup karena salinannya bisa sudah terambil.
- **Email atau nama**: ganti riwayat dengan `git filter-repo` atau buat repositori baru dari
  berkas bersih. Perlu diketahui GitHub dapat menyimpan salinan cache untuk sementara.
- Hapus tangkapan layar bermasalah dari riwayat juga, bukan hanya dari versi terbaru.
