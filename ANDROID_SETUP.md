# MediVault Android App - Quick Setup Guide

This guide will help you get the MediVault Android app up and running quickly.

## ✅ Quick Start (5 minutes)

### Step 1: Open Android Studio

```bash
android-studio ./android
```

Or: **File → Open** → Select `android` folder

### Step 2: Configure Server URL

Open `android/app/src/main/java/com/medivault/app/MainActivity.kt` and set your server URL:

```kotlin
// Line 25-31
val baseUrl = BuildConfig.DEBUG.let { debug ->
    if (debug) {
        "http://10.0.2.2:3000"  // Android Emulator
        // Or use: "http://192.168.1.X:3000" for physical device
    } else {
        "https://medivault.com"  // Production
    }
}
```

### Step 3: Start Rails Server

```bash
cd /home/kalyan/platform/personal/medi_vault
rails server -b 0.0.0.0 -p 3000
```

### Step 4: Sync Gradle & Run

1. Android Studio will prompt to sync Gradle - click **Sync Now**
2. Wait for sync to complete (~2-5 minutes first time)
3. Select device/emulator from dropdown
4. Click **Run** (green play button)

## 📱 Device Setup

### For Android Emulator (Recommended for Development)

1. Open **Device Manager** (phone icon in toolbar)
2. Click **Create Device**
3. Select **Pixel 5** → **Next**
4. Select **API 33** (Android 13) → **Next** → **Finish**
5. Click **Play** to start emulator

### For Physical Device

1. **Enable Developer Mode**:
   - Settings → About Phone → Tap "Build Number" 7 times

2. **Enable USB Debugging**:
   - Settings → Developer Options → Enable "USB Debugging"

3. **Connect Device & Verify**:
   ```bash
   adb devices
   # Should show your device
   ```

4. **Get Your Computer's IP**:
   ```bash
   ip addr show | grep "inet "
   # Look for 192.168.x.x address
   ```

5. **Update MainActivity.kt** with your IP:
   ```kotlin
   "http://192.168.1.100:3000"  // Replace with your IP
   ```

## 🔍 Verify Everything Works

After running the app, you should see:

1. ✅ App launches with purple MediVault branding
2. ✅ Shows your Rails app homepage
3. ✅ Can navigate between pages smoothly
4. ✅ Login/signup works
5. ✅ Back button works correctly

## 🐛 Common Issues & Fixes

### Issue: "Could not connect to server"

**Fix**:
```bash
# 1. Check Rails is running:
curl http://localhost:3000

# 2. For emulator, use:
http://10.0.2.2:3000

# 3. For device, check computer IP:
ip addr show | grep inet

# 4. Verify firewall allows port 3000:
sudo ufw allow 3000
```

### Issue: Gradle sync fails

**Fix**:
```bash
# Clear Gradle cache
cd android
./gradlew clean
rm -rf ~/.gradle/caches

# In Android Studio:
# File → Invalidate Caches / Restart
```

### Issue: "SDK not found"

**Fix**:
1. Open **Tools → SDK Manager**
2. Ensure these are installed:
   - Android SDK Platform 34
   - Android SDK Build-Tools 34
   - Android SDK Command-line Tools

## 📂 Project Structure

```
android/
├── app/
│   ├── src/main/
│   │   ├── java/com/medivault/app/
│   │   │   ├── MainActivity.kt          # Main entry point
│   │   │   ├── MainApplication.kt       # App initialization
│   │   │   └── features/web/
│   │   │       ├── WebFragment.kt       # Main web view
│   │   │       └── WebModalFragment.kt  # Modal dialogs
│   │   ├── res/
│   │   │   ├── layout/                   # UI layouts
│   │   │   ├── values/                   # Strings, colors, themes
│   │   │   └── navigation/               # Navigation graph
│   │   └── assets/
│   │       └── json/configuration.json   # Path config
│   └── build.gradle                      # App dependencies
├── build.gradle                          # Project config
└── settings.gradle                       # Gradle settings
```

## 🎨 Customization Quick Reference

### Change App Name
**File**: `android/app/src/main/res/values/strings.xml`
```xml
<string name="app_name">MediVault</string>
```

### Change Colors
**File**: `android/app/src/main/res/values/colors.xml`
```xml
<color name="purple_600">#7E22CE</color>
```

### Change Server URL
**File**: `android/app/src/main/java/com/medivault/app/MainActivity.kt`
```kotlin
val baseUrl = "https://your-domain.com"
```

### Configure Navigation
**File**: `android/app/src/main/assets/json/configuration.json`
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

1. **Test on Device**: Deploy to physical Android device
2. **Customize Theme**: Match your brand colors
3. **Add App Icon**: Replace launcher icons
4. **Configure Deep Links**: Set up URL schemes
5. **Add Native Features**: Biometrics, notifications, etc.
6. **Prepare for Release**: Generate signed APK

## 📚 Learn More

- **Full Documentation**: See [android/README.md](android/README.md)
- **Hotwire Native**: https://native.hotwired.dev/
- **Android Docs**: https://developer.android.com/

## 💡 Pro Tips

1. **Fast Reload**: Use Turbo's live reload instead of rebuilding app
2. **Debug WebView**: Chrome DevTools → Inspect WebView
3. **Test Network**: Use Android Studio's Network Profiler
4. **Check Logs**: `adb logcat` for debugging

## ✅ Checklist

Before deploying to users:

- [ ] Test login/signup flow
- [ ] Test file uploads
- [ ] Test offline behavior
- [ ] Test on multiple Android versions (8.0+)
- [ ] Test on different screen sizes
- [ ] Verify back button behavior
- [ ] Check performance on slow networks
- [ ] Enable ProGuard for release build
- [ ] Generate signed release APK
- [ ] Test deep linking
- [ ] Update app icon
- [ ] Set proper app name

## 🆘 Get Help

1. Check logs: `adb logcat | grep MediVault`
2. Review [android/README.md](android/README.md)
3. Check Hotwire Native issues: https://github.com/hotwired/turbo-android/issues
4. Rails server logs: `tail -f log/development.log`

---

**Ready to build?** Run `./gradlew assembleDebug` to create an APK!
