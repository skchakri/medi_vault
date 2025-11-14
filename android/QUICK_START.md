# Quick Start - MediVault Android

## 🚀 Launch in 3 Steps

### 1. Open Android Studio
```bash
android-studio ./android
```

### 2. Start Rails Server
```bash
# In another terminal
cd /home/kalyan/platform/personal/medi_vault
rails server -b 0.0.0.0
```

### 3. Run App
- Wait for Gradle sync to finish
- Click green **Run** button ▶️
- Select **Pixel 5 API 33** emulator

## ✅ Done!
Your app should launch and connect to Rails!

## 📖 Need Help?
- Full docs: [README.md](README.md)
- Setup guide: [../ANDROID_SETUP.md](../ANDROID_SETUP.md)

## 🔧 Server URL
Using emulator? Default is `http://10.0.2.2:3000` ✅

Using device? Edit `MainActivity.kt`:
```kotlin
val baseUrl = "http://YOUR_IP:3000"
```

Find your IP: `ip addr show | grep inet`
