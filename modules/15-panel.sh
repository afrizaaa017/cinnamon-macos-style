# Modul: panel (OPSIONAL)  (di-source oleh install.sh)
# Satu panel di atas, ramping: menu di kiri; jaringan, suara, baterai, dan jam di kanan.
# Mengganti susunan panel Anda, jadi hanya dijalankan bila Anda setuju.

cinnamon_aktif || { warn "Bukan sesi Cinnamon; modul panel dilewati."; return 0; }
note "Modul ini MENGGANTI susunan panel Cinnamon (daftar jendela dihapus, panel dipindah ke atas)."
note "Dock (Plank) di bawah menggantikan daftar jendela."
ask "Lanjut mengganti susunan panel?" || { warn "dilewati atas permintaan Anda"; return 0; }

gs_set org.cinnamon panels-enabled "['1:0:top']"
gs_set org.cinnamon panels-height "['1:32']"
gs_set org.cinnamon enabled-applets "['panel1:left:0:menu@cinnamon.org:0', 'panel1:left:1:separator@cinnamon.org:1', 'panel1:right:0:systray@cinnamon.org:3', 'panel1:right:1:xapp-status@cinnamon.org:4', 'panel1:right:2:notifications@cinnamon.org:5', 'panel1:right:4:removable-drives@cinnamon.org:7', 'panel1:right:7:network@cinnamon.org:10', 'panel1:right:8:sound@cinnamon.org:11', 'panel1:right:9:power@cinnamon.org:12', 'panel1:right:10:calendar@cinnamon.org:13']"
note "Bila Plank sudah berjalan, restart dengan:  pkill -x plank; plank &   agar posisinya menyesuaikan panel baru."
