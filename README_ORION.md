# AutoFish Pro - ORION Edition

🎣 **AutoFish Pro dengan ORION UI** - Sistem modular AutoFish yang canggih dengan interface yang modern dan user-friendly menggunakan ORION UI Library.

## ✨ Fitur Utama

### 🎮 ORION UI Interface
- **Modern Design**: Interface yang clean dan responsif
- **Tab-based Organization**: Semua fitur terorganisir dalam tab yang mudah digunakan
- **Real-time Updates**: Dashboard yang update secara real-time
- **Mobile Friendly**: Responsive untuk berbagai ukuran layar
- **Theme Support**: Mendukung berbagai tema UI

### 🎣 AutoFish Core
- **Smart Mode**: Fishing otomatis dengan AI detection
- **Secure Mode**: Mode aman dengan anti-detection
- **Fast Mode**: Mode cepat untuk efficiency maksimal
- **Stealth Mode**: Mode tersembunyi untuk keamanan ekstra
- **Perfect Catch**: Mode perfect catch otomatis
- **Customizable Delays**: Pengaturan delay yang dapat disesuaikan

### 🚀 Movement Enhancement
- **Float Mode**: Karakter melayang di atas air
- **NoClip**: Tembus dinding dan objek
- **Auto Spinner**: Spinner otomatis dengan kecepatan yang dapat diatur

### 💰 AutoSell System
- **Smart Threshold**: Jual otomatis berdasarkan persentase inventory
- **Fish Type Filter**: Pilih jenis ikan yang akan dijual
- **Rarity Control**: Kontrol berdasarkan rarity ikan
- **Real-time Sync**: Sinkronisasi dengan server

### 🛡️ Security Features
- **Anti-Detection**: Sistem anti-deteksi yang canggih
- **Anti-AFK**: Pencegahan AFK otomatis
- **Auto-Reconnect**: Reconnect otomatis jika terputus
- **Randomization**: Pola randomisasi untuk menghindari deteksi

### 📊 Dashboard & Analytics
- **Real-time Statistics**: Statistik fishing real-time
- **Fish Counter**: Penghitung ikan yang tertangkap
- **Session Timer**: Timer sesi fishing
- **Value Tracker**: Pelacak nilai ikan yang didapat
- **Export Data**: Export data statistik

## 🚀 Cara Penggunaan

### Method 1: Direct Load (Recommended)
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/MELLISAEFFENDY/fullversion/main/main_orion.lua"))()
```

### Method 2: Manual Download
1. Download `main_orion.lua`
2. Execute di executor pilihan Anda

## 🎮 Interface Guide

### 🎣 AutoFish Tab
- **Enable AutoFish**: Toggle untuk mengaktifkan/nonaktifkan AutoFish
- **Fishing Mode**: Pilih mode fishing (Smart/Secure/Fast/Stealth)
- **Cast Power**: Atur kekuatan cast (50-100%)
- **Auto Re-cast**: Toggle auto re-cast
- **Perfect Catch Mode**: Toggle perfect catch
- **Cast Delay**: Atur delay antar cast (0.1-5.0s)

### 🚀 Movement Tab
- **Float Mode**: Toggle mode melayang
- **NoClip**: Toggle tembus dinding
- **Auto Spinner**: Toggle spinner otomatis
- **Spinner Speed**: Atur kecepatan spinner (1-20x)

### 💰 AutoSell Tab
- **Enable AutoSell**: Toggle AutoSell
- **Inventory Threshold**: Atur threshold inventory (10-100%)
- **Sell Common Fish**: Toggle jual ikan common
- **Sell Rare Fish**: Toggle jual ikan rare
- **Sell Legendary Fish**: Toggle jual ikan legendary

### 🛡️ Security Tab
- **Anti-Detection**: Toggle anti-detection
- **Randomization Level**: Atur level randomisasi (1-10)
- **Anti-AFK**: Toggle anti-AFK
- **AFK Check Interval**: Atur interval check AFK (30-300s)
- **Auto-Reconnect**: Toggle auto-reconnect

### 📊 Dashboard Tab
- **Real-time Stats**: Lihat statistik real-time
- **Reset Statistics**: Reset semua statistik
- **Export Data**: Export data ke clipboard

### ⚙️ Settings Tab
- **UI Theme**: Pilih tema UI
- **Save/Load Config**: Simpan/muat konfigurasi
- **Check Updates**: Cek update terbaru

## 🔧 API Access

Script ini menyediakan global API untuk kontrol eksternal:

```lua
-- Access main system
local autofish = getgenv().AutoFishPro

-- Quick functions
autofish.toggleAutoFish()  -- Toggle AutoFish on/off
autofish.getStats()        -- Get current statistics
autofish.showUI()          -- Show UI
autofish.hideUI()          -- Hide UI

-- Access modules directly
local modules = autofish.modules
modules.autofish.start()   -- Start AutoFish
modules.autofish.stop()    -- Stop AutoFish
```

## 🏗️ Arsitektur Modular

### 📁 Struktur File
```
main_orion.lua              # Main loader dengan ORION UI
├── modules/
│   ├── orion_ui.lua        # ORION UI interface
│   ├── autofish.lua        # Core AutoFish logic
│   ├── movement.lua        # Movement enhancements
│   ├── autosell.lua        # AutoSell system
│   ├── security.lua        # Security features
│   └── dashboard.lua       # Dashboard & analytics
└── config/
    └── settings.lua        # Configuration management
```

### 🔄 Module Loading
- Semua modul dimuat dari GitHub secara real-time
- Error handling untuk module loading
- Fallback system jika ada modul yang gagal load
- Auto-update capabilities

## 🎯 Keunggulan ORION UI

### ✅ Dibanding UI Custom Sebelumnya
- **Professional Look**: Interface yang lebih professional
- **Better Organization**: Fitur terorganisir dengan baik dalam tab
- **Responsive Design**: Lebih responsive di berbagai ukuran layar
- **Rich Components**: Lebih banyak komponen UI yang tersedia
- **Built-in Features**: Notification, configuration management, themes

### 📱 Mobile Optimization
- **Touch Friendly**: Interface yang mudah digunakan di mobile
- **Proper Scaling**: Scaling yang tepat untuk layar kecil
- **Gesture Support**: Mendukung gesture mobile
- **Portrait/Landscape**: Optimized untuk semua orientasi

## 🛠️ Development

### 🔧 Adding New Features
1. Buat module baru di folder `modules/`
2. Tambahkan ke `moduleNames` di `main_orion.lua`
3. Buat tab baru di `orion_ui.lua`
4. Implementasikan UI controls

### 🧪 Testing
- Use `test_loader.lua` untuk testing module individual
- Gunakan `ui_test.lua` untuk testing UI components

## 📊 Performance

### ⚡ Optimizations
- **Lazy Loading**: Module dimuat sesuai kebutuhan
- **Efficient Updates**: Dashboard update yang efficient
- **Memory Management**: Proper cleanup dan memory management
- **Network Optimization**: Optimized network requests

## 🔒 Security

### 🛡️ Anti-Detection Features
- **Randomized Patterns**: Pola fishing yang dirandomisasi
- **Human-like Behavior**: Simulasi behavior manusia
- **Rate Limiting**: Pembatasan rate untuk menghindari deteksi
- **Stealth Modes**: Multiple stealth modes

## 📝 Changelog

### v2.0-ORION (Latest)
- ✨ Integrasi penuh dengan ORION UI
- 🎨 Interface yang completely redesigned
- 📱 Mobile optimization yang lebih baik
- 🔧 API yang diperbaiki untuk kontrol eksternal
- 📊 Dashboard real-time yang enhanced
- 🛡️ Security features yang ditingkatkan

## 🤝 Contributing

Ingin berkontribusi? Silakan:
1. Fork repository ini
2. Buat feature branch
3. Commit changes Anda
4. Submit pull request

## 📞 Support

Jika ada masalah atau pertanyaan:
- Buka issue di GitHub repository
- Join Discord community (jika ada)
- Check documentation lebih lanjut

## ⚖️ Disclaimer

Script ini dibuat untuk tujuan educational. Penggunaan di game yang tidak mengizinkan automation adalah tanggung jawab user. Gunakan dengan bijak dan ikuti terms of service game yang berlaku.

---

🌟 **AutoFish Pro - ORION Edition** - The most advanced AutoFish system with modern ORION UI interface!
