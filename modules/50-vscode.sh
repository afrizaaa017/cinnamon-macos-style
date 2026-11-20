# Modul: vscode  (di-source oleh install.sh)
# Menambahkan aksen warna hijau ke VS Code lewat "workbench.colorCustomizations".
# Pengaturan lain Anda tidak disentuh. Bagian ini HANYA menggabungkan warna ke settings.json.

S="$HOME/.config/Code/User/settings.json"
[ -d "$HOME/.config/Code/User" ] || { warn "VS Code belum pernah dijalankan (folder pengaturan tidak ada); dilewati"; return 0; }
have python3 || { warn "python3 tidak ada; dilewati"; return 0; }

if [ "$DRY_RUN" = 1 ]; then
  note "[dry-run] menggabungkan $(python3 -c "import json;print(len(json.load(open('$REPO_DIR/files/vscode-colors.json'))))") warna ke $S"
  return 0
fi

backup_file "$S"
python3 - "$S" "$REPO_DIR/files/vscode-colors.json" <<'PY'
import json, os, sys
tujuan, warna = sys.argv[1], sys.argv[2]
baru = json.load(open(warna))
if os.path.exists(tujuan) and os.path.getsize(tujuan) > 0:
    try:
        s = json.load(open(tujuan))
    except Exception:
        print("    [lewati] settings.json berisi komentar/format khusus, tidak aman digabung otomatis.")
        print("             Salin isi files/vscode-colors.json ke \"workbench.colorCustomizations\" secara manual.")
        sys.exit(0)
else:
    s = {}
cc = s.get("workbench.colorCustomizations", {})
cc.update(baru)
s["workbench.colorCustomizations"] = cc
json.dump(s, open(tujuan, "w"), indent=4, ensure_ascii=False)
print(f"    [ok] {len(baru)} warna digabung; pengaturan lain dipertahankan")
PY
