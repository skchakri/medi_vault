# Quick Start - MediVault iOS

## 🚀 Launch in 3 Steps

### 1. Setup Dependencies
```bash
cd ios
make setup
```

### 2. Start Rails Server
```bash
# In another terminal
cd /home/kalyan/platform/personal/medi_vault
rails server -b 0.0.0.0
```

### 3. Open & Run
```bash
cd ios
open MediVault.xcworkspace
```

Then click the **Run** button (▶️) in Xcode!

## ✅ Done!
Your app should launch and connect to Rails!

## 📖 Need Help?
- Full docs: [README.md](README.md)
- Setup guide: [../IOS_SETUP.md](../IOS_SETUP.md)

## 🔧 Server URL
**Simulator**: `http://localhost:3000` ✅ (default)

**Device**: Edit `SceneDelegate.swift`:
```swift
private let baseURL = URL(string: "http://YOUR_MAC_IP:3000")!
```

Find your Mac's IP:
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

## 💡 Important
Always open `MediVault.xcworkspace`, NOT `MediVault.xcodeproj`!
