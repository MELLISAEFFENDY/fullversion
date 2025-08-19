# 🎣 Modern AutoFish - Modular Version

Advanced modular autofish script for Roblox fishing games with GitHub integration.

## 🚀 Features

- **🎣 Smart AutoFishing** - Advanced fishing automation with multiple modes
- **🚀 Movement Enhancement** - Float, NoClip, Auto Spinner
- **📊 Dashboard & Statistics** - Real-time fish tracking and analytics
- **🛒 Auto Sell System** - Intelligent selling with threshold controls
- **🔒 Security Features** - Anti-detection, AntiAFK, Auto Reconnect
- **🌐 GitHub Integration** - Remote loading and auto-updates
- **🎈 Floating Button** - Quick access draggable interface
- **⚙️ Advanced Settings** - Comprehensive configuration options

## 🖥️ User Interface

### Main Features:
- **📊 Live Dashboard**: Real-time statistics display
  - Fish count and rarity distribution
  - Session time and fish per hour
  - Current location tracking
  
- **🎣 AutoFishing Controls**: 
  - Smart Mode (recommended)
  - Secure Mode (extra safe)
  - One-click enable/disable
  
- **🚀 Movement Enhancement**:
  - Float Mode for aerial movement
  - NoClip for wall penetration  
  - Auto Spinner for AFK rotation
  
- **🛒 Auto Sell System**:
  - Threshold-based selling (adjustable 1-1000)
  - Manual sell button
  - Rarity filtering options
  
- **⚙️ Security Settings**:
  - AntiAFK with random jumps
  - Auto Reconnect on disconnect
  - Suspicion monitoring

### UI Controls:
- **🎈 Floating Button**: Click the 🎣 button to toggle main UI
- **Draggable Interface**: Drag title bar or floating button to reposition
- **Live Updates**: Dashboard refreshes every 2 seconds
- **Responsive Design**: Scrollable interface with organized sections

## 📦 Modular Architecture

```
📁 AutoFishScript/
├── 📄 main_modular.lua (main loader)
├── 📁 modules/
│   ├── 📄 autofish.lua
│   ├── 📄 movement.lua
│   ├── 📄 dashboard.lua
│   ├── 📄 autosell.lua
│   ├── 📄 security.lua
│   └── 📄 ui.lua
├── 📁 config/
│   ├── 📄 settings.lua
│   └── 📄 fish_data.lua
└── 📄 README.md
```

## 🛠️ Installation

### Method 1: GitHub Remote Loading (Recommended)
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/MELLISAEFFENDY/fullversion/main/main_modular.lua"))()
```

### Method 2: UI Test Loader
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/MELLISAEFFENDY/fullversion/main/ui_test.lua"))()
```

### Method 3: Basic Test
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/MELLISAEFFENDY/fullversion/main/test_loader.lua"))()
```

### Method 2: Local Loading
1. Download all files
2. Place in your script executor
3. Run `main_modular.lua`

## ⚙️ Configuration

Edit `config/settings.lua` to customize:

```lua
local Config = {
    autofish = {
        mode = "smart", -- "smart", "secure", "fast"
        safeModeChance = 70
    },
    movement = {
        floatHeight = 16,
        spinnerSpeed = 2
    },
    autosell = {
        threshold = 50,
        allowedRarities = {
            COMMON = true,
            RARE = false
        }
    }
}
```

## 🎮 Usage

1. **Load Script**: Execute main loader
2. **Configure**: Adjust settings via UI or config file
3. **Start Fishing**: Enable autofish mode
4. **Monitor**: Check dashboard for statistics

## 🔧 Modules

### AutoFish Module
- Smart fishing logic
- Multiple automation modes
- Animation-based detection

### Movement Module  
- Float mode for aerial movement
- NoClip for wall penetration
- Auto Spinner for AFK fishing

### Dashboard Module
- Real-time fish statistics  
- Location-based tracking
- Rarity distribution analysis

### AutoSell Module
- Threshold-based selling
- Rarity filtering
- Automatic teleportation

## 🔒 Security Features

- Rate limiting to avoid detection
- Random delays and variations
- Cooldown systems
- Error handling and recovery

## 📈 Updates

Script automatically checks for updates from GitHub. Manual update:
```bash
git pull origin main
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## ⚠️ Disclaimer

This script is for educational purposes. Use responsibly and follow game terms of service.

## 📝 License

MIT License - See LICENSE file for details

## 👤 Author

**Spinner_xxx**
- GitHub: [@MELLISAEFFENDY](https://github.com/MELLISAEFFENDY)

---
⭐ Star this repo if you find it helpful!
