# MediVault Android App - Quick Start

Get your Android app running in 5 minutes!

## Prerequisites

- ✅ Android Studio Hedgehog (2023.1.1) or later
- ✅ JDK 17 or later
- ✅ Rails server running on port 7000

## Step 1: Install Android Studio

**Download**: https://developer.android.com/studio

**Linux**:
```bash
sudo snap install android-studio --classic
```

**Mac**:
```bash
brew install --cask android-studio
```

**Windows**: Download installer from website

## Step 2: Open Project

1. Launch Android Studio
2. Click **"Open"**
3. Navigate to: `/home/kalyan/platform/personal/seva_care/android-app`
4. Click **"OK"**
5. Wait for Gradle sync (5-10 minutes first time)

## Step 3: Configure Server URL

Open `app/src/main/java/com/medivault/app/MainActivity.kt`

**For Android Emulator** (default):
```kotlin
const val BASE_URL = "http://127.0.0.1:9000"
```

**For Physical Device**:
```kotlin
// Find your computer's IP:
// Linux/Mac: ifconfig | grep "inet "
// Windows: ipconfig

const val BASE_URL = "http://YOUR_COMPUTER_IP:9000"
// Example: "http://192.168.1.100:7000"
```

## Step 4: Start Rails Server

```bash
cd /home/kalyan/platform/personal/seva_care
docker compose up
```

Verify it's running: http://localhost:7000

**For Physical Device**: Update `docker-compose.yml`:
```yaml
services:
  web:
    ports:
      - "0.0.0.0:7000:7000"  # Expose on all interfaces
```

## Step 5: Run the App

### Option A: Android Emulator

1. In Android Studio: **Tools → Device Manager**
2. Click **"Create Device"**
3. Select **Pixel 6** (recommended)
4. Select **API 34** (Android 14)
5. Click **Finish**
6. Click the green **"Run"** button (▶️)
7. Select your emulator
8. Wait for app to launch!

### Option B: Physical Device

1. Enable Developer Mode:
   - Settings → About Phone
   - Tap "Build Number" 7 times

2. Enable USB Debugging:
   - Settings → Developer Options
   - Enable "USB Debugging"

3. Connect via USB

4. Click **"Run"** in Android Studio

5. Select your device

## What You Should See

✅ App launches with MediVault branding
✅ Rails homepage loads in the app
✅ Navigation works smoothly
✅ Pull-to-refresh works
✅ Back button navigates correctly

## Features to Test

1. **Find Doctors**: Browse and search doctors
2. **Doctor Profile**: View doctor details
3. **Login**: Test authentication
4. **Messages**: Test messaging (if logged in)
5. **QR Scanner**: Test scanning doctor QR codes

## Quick Commands

```bash
cd android-app

# Build debug APK
./gradlew assembleDebug

# Install on connected device
adb install app/build/outputs/apk/debug/app-debug.apk

# View logs
adb logcat | grep MediVault

# Uninstall
adb uninstall com.medivault.app
```

## Troubleshooting

### "Cannot connect to server"

**Emulator**:
```kotlin
const val BASE_URL = "http://10.0.2.2:7000"  // ✅ Correct
const val BASE_URL = "http://localhost:7000" // ❌ Wrong
```

**Physical Device**:
- Check both devices on same WiFi
- Use computer's IP address
- Update docker-compose.yml to expose on 0.0.0.0
- Check firewall settings

### Gradle Sync Failed

```bash
# In terminal
./gradlew clean
./gradlew build --refresh-dependencies

# In Android Studio
File → Invalidate Caches → Invalidate and Restart
```

### Build Errors

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for detailed solutions.

## Testing Native Features

Add to your Rails views:

```erb
<% if request.user_agent&.include?("Turbo Native") %>
  <button onclick="NativeBridge.scanQRCode()">
    📸 Scan QR Code
  </button>

  <button onclick="NativeBridge.showToast('Hello from native!')">
    🔔 Show Toast
  </button>
<% end %>
```

## Building APK for Sharing

```bash
# Debug APK (for testing)
./gradlew assembleDebug

# APK location:
# app/build/outputs/apk/debug/app-debug.apk

# Share via USB or cloud storage
# Recipients can install directly
```

## Next Steps

1. ✅ Test all app features
2. ✅ Customize app icon (see [README.md](README.md))
3. ✅ Add push notifications
4. ✅ Build release APK
5. ✅ Publish to Google Play Store

## Need Help?

- 📖 Full docs: [README.md](README.md)
- 🔧 Troubleshooting: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- 🚀 Setup guide: [/ANDROID_SETUP.md](/ANDROID_SETUP.md)
- 💬 Hotwire docs: https://native.hotwired.dev/android

## Success! 🎉

Your MediVault Android app is now running!

The app wraps your entire Rails application in a native Android shell with smooth navigation and native features.
