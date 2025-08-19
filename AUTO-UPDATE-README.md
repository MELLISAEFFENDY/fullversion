# 🚀 AutoFish Pro - Auto Update Scripts

Koleksi script untuk otomatis update repository AutoFish Pro ke GitHub.

## 📁 Script yang Tersedia

### 1. 🖥️ PowerShell Script (`auto-update.ps1`)
Script PowerShell dengan fitur lengkap untuk Windows.

**Penggunaan:**
```powershell
# Update dengan pesan otomatis
.\auto-update.ps1

# Update dengan pesan custom
.\auto-update.ps1 -CommitMessage "Added new fishing features"

# Dry run (lihat perubahan tanpa commit)
.\auto-update.ps1 -DryRun

# Force update tanpa konfirmasi
.\auto-update.ps1 -Force
```

**Fitur:**
- ✅ Deteksi perubahan otomatis
- ✅ Konfirmasi sebelum update
- ✅ Pesan commit dengan timestamp
- ✅ Dry run mode
- ✅ Force update mode
- ✅ Output berwarna

### 2. 📝 Batch Script (`quick-update.bat`)
Script batch sederhana untuk Windows.

**Penggunaan:**
```batch
# Update dengan pesan otomatis
quick-update.bat

# Update dengan pesan custom
quick-update.bat "My custom commit message"
```

**Fitur:**
- ✅ Interface sederhana
- ✅ Deteksi perubahan
- ✅ Konfirmasi user
- ✅ Timestamp otomatis

### 3. 🎨 GUI Python (`auto-update-gui.py`)
Interface grafis untuk update repository.

**Penggunaan:**
```bash
python auto-update-gui.py
```

**Fitur:**
- ✅ GUI yang user-friendly
- ✅ Real-time status monitoring
- ✅ Progress bar
- ✅ Custom commit messages
- ✅ Force update option
- ✅ Threaded operations

**Requirements:**
```bash
pip install tkinter  # Biasanya sudah terinstall dengan Python
```

### 4. ⚡ Shell Script (`update.sh`)
One-liner script untuk update cepat.

**Penggunaan:**
```bash
# Update dengan pesan otomatis
./update.sh

# Update dengan pesan custom
./update.sh "Added new features"
```

## 🔧 Konfigurasi

Semua script menggunakan konfigurasi yang sama:

```
Git Path: C:\Git\cmd\git.exe
Repository: D:\ssciprtgame\New folder
Branch: main
```

Jika path berbeda, edit variabel di bagian atas setiap script:
- `$GitPath` / `GIT_PATH` - Path ke git.exe
- `$RepoPath` / `REPO_PATH` - Path ke repository
- `$Branch` / `BRANCH` - Branch target

## 📋 Workflow Update

Semua script mengikuti workflow yang sama:

1. **Check Git** - Memastikan Git tersedia
2. **Check Repository** - Memastikan dalam git repository
3. **Detect Changes** - Mencari file yang berubah
4. **Stage Changes** - `git add .`
5. **Commit Changes** - `git commit -m "message"`
6. **Push to Remote** - `git push origin main`

## 🎯 Rekomendasi Penggunaan

### Untuk Development Harian:
```powershell
# Quick check
.\auto-update.ps1 -DryRun

# Update dengan konfirmasi
.\auto-update.ps1
```

### Untuk Update Cepat:
```batch
quick-update.bat
```

### Untuk Monitoring Visual:
```bash
python auto-update-gui.py
```

### Untuk Automation/CI:
```powershell
.\auto-update.ps1 -Force -CommitMessage "Automated update"
```

## 🛡️ Safety Features

- ✅ **Dry Run Mode** - Preview perubahan tanpa commit
- ✅ **Confirmation Prompts** - Konfirmasi sebelum push
- ✅ **Error Handling** - Rollback jika ada error
- ✅ **Status Checking** - Validasi repository state
- ✅ **Force Override** - Bypass konfirmasi untuk automation

## 🚨 Error Handling

Jika mengalami error:

1. **Git tidak ditemukan:**
   ```
   ❌ Git not found at: C:\Git\cmd\git.exe
   ```
   - Pastikan Git terinstall di `C:\Git`
   - Atau update path di script

2. **Bukan git repository:**
   ```
   ❌ Not a git repository
   ```
   - Pastikan di folder yang benar
   - Jalankan `git init` jika perlu

3. **Push failure:**
   ```
   ❌ Failed to push to remote repository
   ```
   - Check koneksi internet
   - Pastikan GitHub credentials tersedia
   - Check branch permissions

## 📝 Contoh Output

```
🎣 AutoFish Pro - Auto Update Script
📁 Repository: D:\ssciprtgame\New folder
🌿 Branch: main
💬 Commit Message: Auto-update: 2025-08-19 15:30:45

📊 Changes detected:
  📝 Modified: modules/autofish.lua
  📝 Modified: modules/rayfield_ui.lua
  🆕 Untracked: auto-update.ps1

🔄 Starting auto-update process...
📋 Staging changes...
💾 Committing changes...
🚀 Pushing to remote repository...
✅ Auto-update completed successfully!
🎉 Changes have been pushed to GitHub repository
```

## 🔗 Integration dengan IDE

### VS Code:
1. Add script ke tasks.json:
```json
{
    "label": "AutoFish Update",
    "type": "shell",
    "command": "powershell",
    "args": ["-File", ".\\auto-update.ps1"],
    "group": "build"
}
```

2. Bind ke keyboard shortcut di keybindings.json:
```json
{
    "key": "ctrl+shift+u",
    "command": "workbench.action.tasks.runTask",
    "args": "AutoFish Update"
}
```

### File Explorer:
1. Right-click di folder repository
2. "Open PowerShell window here"
3. Run: `.\auto-update.ps1`

## 🎉 Tips & Tricks

### Alias untuk PowerShell:
```powershell
# Tambahkan ke $PROFILE
function Update-AutoFish { .\auto-update.ps1 @args }
Set-Alias -Name "update" -Value "Update-AutoFish"

# Usage: update -DryRun
```

### Scheduled Updates:
```powershell
# Task Scheduler untuk auto-update harian
schtasks /create /tn "AutoFish-Update" /tr "powershell.exe -File 'D:\ssciprtgame\New folder\auto-update.ps1' -Force" /sc daily /st 12:00
```

### Git Hooks:
```bash
# pre-commit hook untuk validasi
#!/bin/sh
echo "🔍 Running AutoFish validation..."
# Add validation logic here
```

---

**🎣 Happy Fishing & Happy Coding! ✨**
