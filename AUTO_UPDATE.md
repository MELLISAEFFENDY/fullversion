# 🚀 AutoFish Pro - Auto Update Scripts

Collection of scripts to automatically update the AutoFish Pro repository to GitHub.

## 📋 Available Scripts

### 1. 🪟 **PowerShell Script** (`auto_update.ps1`)
**Best for:** Windows users with PowerShell
**Features:** 
- Advanced error handling
- Smart commit message generation
- Force push option
- Detailed logging
- Color output

**Usage:**
```powershell
# Basic update
.\auto_update.ps1

# With custom message
.\auto_update.ps1 -commitMessage "Added new fishing features"

# Force push (use with caution)
.\auto_update.ps1 -force

# Show help
.\auto_update.ps1 -help
```

### 2. 📦 **Batch Script** (`auto_update.bat`)
**Best for:** Windows users who prefer simple batch files
**Features:**
- Simple and reliable
- Automatic timestamp
- Basic error handling
- Works on all Windows versions

**Usage:**
```cmd
# Double-click the file or run from command prompt
auto_update.bat
```

### 3. 🐍 **Python Script** (`auto_update.py`)
**Best for:** Cross-platform users, advanced features
**Features:**
- GUI interface with tkinter
- CLI mode available
- Real-time progress tracking
- File preview
- Advanced commit message generation

**Requirements:**
```bash
# Python 3.6+ required
pip install tkinter  # Usually included with Python
```

**Usage:**
```bash
# Launch GUI (default)
python auto_update.py
python auto_update.py --gui

# CLI mode
python auto_update.py --message "Custom commit message"
python auto_update.py --force --yes  # Auto-confirm and force push
python auto_update.py -m "Update" -f -y  # Short form
```

## 🔧 Setup Instructions

### First Time Setup:

1. **Initialize Git Repository** (if not done):
```bash
git init
git remote add origin https://github.com/MELLISAEFFENDY/fullversion.git
```

2. **Set Git Credentials**:
```bash
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

3. **Test Connection**:
```bash
git remote -v
git status
```

### Script Permissions:

**Windows PowerShell:**
```powershell
# Allow script execution (run as Administrator)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Python:**
```bash
# Make executable on Linux/Mac
chmod +x auto_update.py
```

## 📊 What Each Script Does

### Automatic Process:
1. **Check Status** - Verifies git repository and detects changes
2. **Stage Changes** - Adds all modified files (`git add .`)
3. **Generate Message** - Creates smart commit message with timestamp
4. **Commit** - Commits changes locally (`git commit`)
5. **Push** - Uploads to GitHub (`git push origin main`)

### Smart Commit Messages:
Scripts automatically generate descriptive commit messages:
- `🔄 Auto-update: Updated 3 Lua modules, 1 documentation file - 2025-08-19 15:30:45`
- `🔄 Auto-update: Added new fishing features - 2025-08-19 15:30:45`
- `🔄 Auto-update: General improvements - 2025-08-19 15:30:45`

## 🛡️ Safety Features

### All Scripts Include:
- ✅ **Repository Validation** - Ensures you're in a git repository
- ✅ **Change Detection** - Only updates if changes exist
- ✅ **Error Handling** - Proper error messages and rollback
- ✅ **Status Reporting** - Clear success/failure feedback

### Python Script Additional Features:
- ✅ **Preview Changes** - See what will be committed
- ✅ **Progress Tracking** - Real-time update status
- ✅ **Confirmation Prompts** - Prevent accidental updates
- ✅ **Force Push Warning** - Extra safety for destructive operations

## 🎯 Recommended Usage

### For Daily Development:
```powershell
# Quick update with PowerShell
.\auto_update.ps1 -commitMessage "Daily progress update"
```

### For Major Changes:
```bash
# Use Python GUI for review
python auto_update.py --gui
```

### For Automated CI/CD:
```bash
# Automated script for deployment
python auto_update.py --message "Automated deployment" --yes
```

## 🔍 Troubleshooting

### Common Issues:

**"Not a git repository"**
```bash
git init
git remote add origin <your-repo-url>
```

**"Permission denied"**
```bash
# Check git credentials
git config --list
# Or use GitHub token authentication
```

**"Push failed"**
```bash
# Pull latest changes first
git pull origin main
# Then try update script again
```

**"No changes detected"**
- Repository is already up to date
- Check `git status` manually

### Getting Help:
- PowerShell: `.\auto_update.ps1 -help`
- Python: `python auto_update.py --help`
- Batch: Messages are displayed during execution

## 📝 File Structure

```
AutoFish Pro/
├── auto_update.ps1      # PowerShell script
├── auto_update.bat      # Batch script  
├── auto_update.py       # Python script with GUI
├── AUTO_UPDATE.md       # This documentation
├── modules/             # AutoFish modules
├── main_rayfield.lua    # Main script
└── ...                  # Other project files
```

## 🌟 Features Comparison

| Feature | PowerShell | Batch | Python |
|---------|------------|-------|--------|
| **GUI Interface** | ❌ | ❌ | ✅ |
| **CLI Interface** | ✅ | ✅ | ✅ |
| **Custom Messages** | ✅ | ❌ | ✅ |
| **Force Push** | ✅ | ❌ | ✅ |
| **Change Preview** | ❌ | ❌ | ✅ |
| **Progress Tracking** | ❌ | ❌ | ✅ |
| **Cross-Platform** | ❌ | ❌ | ✅ |
| **Color Output** | ✅ | ✅ | ✅ |
| **Error Handling** | ✅ | ✅ | ✅ |

## 🚀 Quick Start

**Fastest Method:**
1. Double-click `auto_update.bat` (Windows)
2. Or run `python auto_update.py` for GUI

**Most Powerful:**
1. Use Python GUI: `python auto_update.py --gui`
2. Preview changes, customize message, then update

**For Power Users:**
1. PowerShell with custom messages: `.\auto_update.ps1 -commitMessage "Your message"`

---

**Made for AutoFish Pro** 🎣
*Automated repository management for seamless development*
