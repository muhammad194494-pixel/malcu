# Skill: GitHub Operations

Gunakan skill ini ketika user minta operasi GitHub: push, pull, clone, commit, buat repo, release, dll.
Git dan gh CLI sudah terinstall dan sudah login. Langsung eksekusi tanpa perlu setup.

---

## Operasi Git Dasar

### Clone repo
```bash
git clone https://github.com/username/repo.git /path/tujuan
```

### Cek status
```bash
git status
git log --oneline -5
```

### Add + Commit + Push
```bash
cd /path/repo
git add .
git commit -m "pesan commit"
git push origin main
```

### Pull update terbaru
```bash
git pull origin main
```

### Buat branch baru
```bash
git checkout -b nama-branch
git push origin nama-branch
```

---

## GitHub CLI (gh)

### Buat repo baru dari folder lokal
```bash
cd /path/folder
gh repo create nama-repo --public --source=. --remote=origin --push
```

### Buat repo private
```bash
gh repo create nama-repo --private --source=. --remote=origin --push
```

### Clone repo
```bash
gh repo clone username/nama-repo
```

### List repo
```bash
gh repo list
```

### Buat release + upload file
```bash
gh release create v1.0 /path/file.zip \
  --title "Release v1.0" \
  --notes "Deskripsi release"
```

### Buat issue
```bash
gh issue create --title "judul" --body "isi issue"
```

---

## Auto Backup Skills ke GitHub

### Setup repo skills (sekali saja)
```bash
cd /root/Untitled-3d55e6f8/ai-company/proxy/skills
git init
gh repo create malcu-skills --public --source=. --push
```

### Backup manual
```bash
cd /root/Untitled-3d55e6f8/ai-company/proxy/skills
git add .
git commit -m "backup skills $(date +%Y%m%d_%H%M)"
git push origin main
```

### Auto backup via cron tiap hari jam 00:00
```bash
echo "0 0 * * * cd /root/Untitled-3d55e6f8/ai-company/proxy/skills && git add . && git commit -m 'auto backup' && git push origin main" | crontab -
```

---

## Use Case Malcu

- Auto backup skills ke GitHub setelah learned skill baru
- Push update proxy ke repo setelah self-upgrade
- Auto commit setelah self-healing fix
- Download script/tools dari GitHub releases
- Simpan backup proxy di GitHub private repo
