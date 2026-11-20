#!/bin/bash
# Menerapkan scroll alami dan ketuk-untuk-klik ke touchpad pertama yang ditemukan.
# Mengulang sampai berhasil, karena driver kadang belum siap tepat setelah login.
# Hanya perlu bila pengaturan Cinnamon (natural-scroll, tap-to-click) tidak bertahan setelah login.
for _ in $(seq 1 40); do
  D=$(xinput list --name-only 2>/dev/null | grep -i touchpad | head -1)
  if [ -n "$D" ]; then
    xinput set-prop "$D" "libinput Natural Scrolling Enabled" 1 2>/dev/null
    xinput set-prop "$D" "libinput Tapping Enabled" 1 2>/dev/null
    BELUM=$(xinput list-props "$D" 2>/dev/null \
      | grep -E "Natural Scrolling Enabled \(|Tapping Enabled \(" \
      | grep -vcE ':[[:space:]]*1[[:space:]]*$')
    [ "$BELUM" = 0 ] && exit 0
  fi
  sleep 1
done
exit 0
