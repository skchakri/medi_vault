# MediVault iOS App - Quick Setup Guide

This guide will help you get the MediVault iOS app up and running quickly.

## ✅ Quick Start (5 minutes)

### Step 1: Install CocoaPods (if needed)

```bash
sudo gem install cocoapods
```

### Step 2: Setup Project

```bash
cd ios
make setup
```

This installs all dependencies and generates the Xcode workspace.

### Step 3: Start Rails Server

```bash
cd /home/kalyan/platform/personal/medi_vault
rails server -b 0.0.0.0 -p 3000
```

### Step 4: Open in Xcode & Run

```bash
cd ios
open MediVault.xcworkspace
```

Then:
1. Select iPhone 15 Pro simulator
2. Click **Run** button (▶️) or press `Cmd+R`

## 📱 Device Setup

### For iOS Simulator (Recommended for Development)

Simulators are included with Xcode - just select one from the dropdown!

**Recommended**:
- iPhone 15 Pro (iOS 17)
- iPhone 14 (iOS 16)
- iPad Pro 12.9"

### For Physical Device

1. **Connect Device**: Plug in iPhone/iPad via USB

2. **Configure Signing**:
   - In Xcode, select project
   - Go to "Signing & Capabilities" tab
   - Select your Apple ID team
   - Xcode handles the rest!

3. **Trust Developer**:
   - On device: Settings → General → VPN & Device Management
   - Trust your developer certificate

4. **Run on Device**:
   - Select your device from dropdown
   - Click Run

## 🔍 Verify Everything Works

After running the app, you should see:

1. ✅ App launches with purple MediVault branding
2. ✅ Shows your Rails app homepage
3. ✅ Can navigate between pages smoothly
4. ✅ Login/signup works
5. ✅ Swipe from left edge goes back

## 🐛 Common Issues & Fixes

### Issue: "No such module 'Turbo'"

**Fix**:
```bash
cd ios
pod install
# In Xcode: Product → Clean Build Folder (Cmd+Shift+K)
```

### Issue: "Could not connect to server"

**Fix**:
```bash
# 1. Check Rails is running:
curl http://localhost:3000

# 2. For simulator: localhost works fine ✅

# 3. For device, get your Mac's IP:
ifconfig | grep "inet " | grep -v 127.0.0.1

# 4. Update SceneDelegate.swift with your IP:
# private let baseURL = URL(string: "http://192.168.1.100:3000")!

# 5. Verify firewall allows port 3000:
sudo ufw allow 3000
```

### Issue: Pod install fails

**Fix**:
```bash
sudo gem update cocoapods
cd ios
pod repo update
pod install
```

### Issue: Can't run on device - signing error

**Fix**:
1. Xcode → Preferences → Accounts
2. Add your Apple ID if not present
3. In project settings → Signing & Capabilities
4. Enable "Automatically manage signing"
5. Select your Team

## 📂 Project Structure

```
ios/
├── MediVault/
│   ├── AppDelegate.swift               ← App initialization
│   ├── SceneDelegate.swift             ← Navigation & routing
│   ├── Controllers/
│   │   └── WebViewController.swift     ← Web views
│   ├── Models/
│   │   └── PathConfiguration.swift     ← Path routing
│   ├── Views/
│   │   ├── Main.storyboard            ← UI layouts
│   │   └── LaunchScreen.storyboard    ← Splash screen
│   ├── Resources/
│   │   └── configuration.json          ← Navigation config
│   └── Assets.xcassets/                ← Images & colors
├── Podfile                             ← Dependencies
└── MediVault.xcworkspace              ← Open this in Xcode!
```

## 🎨 Customization Quick Reference

### Change App Name
**File**: `MediVault/Supporting Files/Info.plist`
```xml
<key>CFBundleDisplayName</key>
<string>MediVault</string>
```

### Change Colors
1. Open `Assets.xcassets` in Xcode
2. Select `PurplePrimary`
3. Update color values

### Change Server URL
**File**: `MediVault/SceneDelegate.swift`
```swift
private let baseURL = URL(string: "https://your-domain.com")!
```

### Configure Navigation
**File**: `MediVault/Resources/configuration.json`
```json
{
  "rules": [
    {
      "patterns": ["/new$", "/edit$"],
      "properties": {
        "context": "modal"
      }
    }
  ]
}
```

## 🚀 Next Steps

1. **Test on Device**: Deploy to physical iPhone/iPad
2. **Customize Theme**: Match your brand colors
3. **Add App Icon**: Use Assets.xcassets
4. **Configure Deep Links**: Set up URL schemes
5. **Add Native Features**: Biometrics, notifications
6. **Prepare for Release**: App Store listing

## 📚 Learn More

- **Full Documentation**: See [ios/README.md](ios/README.md)
- **Hotwire Native**: https://native.hotwired.dev/ios
- **iOS Docs**: https://developer.apple.com/documentation/

## 💡 Pro Tips

1. **Fast Reload**: Changes to Rails views appear instantly!
2. **Debug WebView**: Safari → Develop → Simulator → Your Page
3. **View Logs**: Xcode → View → Debug Area (Cmd+Shift+Y)
4. **Shortcuts**: Cmd+R (run), Cmd+B (build), Cmd+Shift+K (clean)

## ✅ Checklist

Before deploying to users:

- [ ] Test login/signup flow
- [ ] Test file uploads (camera & photo library)
- [ ] Test offline behavior
- [ ] Test on multiple iOS versions (16+)
- [ ] Test on iPhone and iPad
- [ ] Verify swipe-back gesture
- [ ] Check performance on slow networks
- [ ] Update app icon
- [ ] Set proper app name
- [ ] Configure proper server URL

## 🆘 Get Help

1. Check logs in Xcode (Cmd+Shift+Y)
2. Review [ios/README.md](ios/README.md)
3. Check Hotwire issues: https://github.com/hotwired/turbo-ios/issues
4. Rails server logs: `tail -f log/development.log`

## 🎯 Make Commands

```bash
make setup    # Full project setup
make install  # Install dependencies
make open     # Open in Xcode
make clean    # Clean build artifacts
make help     # Show all commands
```

---

**Ready to build?** Open `MediVault.xcworkspace` and click Run! 📱✨
