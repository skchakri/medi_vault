# MediVault Android App

A native Android application for MediVault built with [Hotwire Native](https://native.hotwired.dev/android), wrapping the Rails web application in a native mobile experience.

## 🚀 Features

- **Hotwire Native**: Fast, native-feeling app using your existing Rails views
- **Turbo**: Lightning-fast page navigation without full page reloads
- **Native Navigation**: Android-native navigation with proper back button handling
- **Offline Support**: Graceful handling of offline scenarios
- **Deep Linking**: Direct links to specific content in the app
- **File Uploads**: Native camera and file picker integration
- **Material Design**: Beautiful UI following Android design guidelines

## 📋 Prerequisites

- **Android Studio** Arctic Fox (2020.3.1) or newer
- **JDK** 17 or newer
- **Android SDK** API 26+ (Android 8.0) minimum
- **Rails Server** running locally or accessible via network

## 🛠 Setup Instructions

### 1. Open Project in Android Studio

```bash
# Open Android Studio and select "Open an Existing Project"
# Navigate to: /path/to/medi_vault/android
```

Or from terminal:
```bash
cd /home/kalyan/platform/personal/medi_vault/android
android-studio .
```

### 2. Configure Server URL

Edit `MainActivity.kt` and update the base URL:

```kotlin
// For Android Emulator (localhost):
val baseUrl = "http://10.0.2.2:3000"

// For Physical Device (use your computer's local IP):
val baseUrl = "http://192.168.1.100:3000"

// For Production:
val baseUrl = "https://medivault.com"
```

**Finding your local IP address:**
```bash
# On Linux/Mac:
ip addr show | grep inet

# Or:
ifconfig | grep inet
```

### 3. Sync Gradle

Android Studio will automatically prompt you to sync Gradle files. If not:

- Click **File → Sync Project with Gradle Files**
- Or click the **Sync Now** banner that appears

### 4. Start Rails Server

Make sure your Rails server is running and accessible:

```bash
# In the Rails project directory
cd /home/kalyan/platform/personal/medi_vault
rails server -b 0.0.0.0 -p 3000
```

The `-b 0.0.0.0` flag allows external connections (needed for physical devices).

### 5. Run the App

**Using Android Studio:**
1. Select a device/emulator from the dropdown
2. Click the **Run** button (green play icon)

**Using Command Line:**
```bash
cd android
./gradlew installDebug
```

## 📱 Testing

### Android Emulator

1. **Open AVD Manager**: Tools → Device Manager
2. **Create Device**: Click **Create Device**
3. **Select Hardware**: Choose Pixel 5 or newer
4. **System Image**: API 33 (Android 13) recommended
5. **Start Emulator**: Click the play icon

### Physical Device

1. **Enable Developer Options**:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times

2. **Enable USB Debugging**:
   - Go to Settings → Developer Options
   - Enable "USB Debugging"

3. **Connect Device**:
   - Connect via USB
   - Verify: `adb devices`

4. **Configure Network**:
   - Ensure device is on the same Wi-Fi as your computer
   - Update `MainActivity.kt` with your computer's local IP

## 🔧 Configuration

### Path Configuration

The app uses a JSON configuration file to control navigation behavior:

**Location**: `app/src/main/assets/json/configuration.json`

```json
{
  "rules": [
    {
      "patterns": ["/new$", "/edit$"],
      "properties": {
        "context": "modal",
        "pull_to_refresh_enabled": false
      }
    }
  ]
}
```

**Available contexts:**
- `default`: Normal navigation with back stack
- `modal`: Presents as bottom sheet dialog

### Customizing Navigation

Edit `WebFragment.kt` and `WebModalFragment.kt` to customize:
- Navigation behavior
- JavaScript bridging
- Error handling
- Progress indicators

## 🎨 Branding

### App Icon

Replace launcher icons in:
- `app/src/main/res/mipmap-hdpi/ic_launcher.png` (72x72)
- `app/src/main/res/mipmap-mdpi/ic_launcher.png` (48x48)
- `app/src/main/res/mipmap-xhdpi/ic_launcher.png` (96x96)
- `app/src/main/res/mipmap-xxhdpi/ic_launcher.png` (144x144)
- `app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` (192x192)

### Colors & Theme

Edit `app/src/main/res/values/colors.xml`:

```xml
<color name="purple_600">#7E22CE</color>
<color name="blue_600">#2563EB</color>
```

Edit `app/src/main/res/values/themes.xml` for theming.

### App Name

Edit `app/src/main/res/values/strings.xml`:

```xml
<string name="app_name">MediVault</string>
```

## 🚀 Building for Production

### Generate Signed APK

1. **Create Keystore**:
```bash
keytool -genkey -v -keystore medivault-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias medivault-key
```

2. **Configure Signing** in `app/build.gradle`:
```gradle
android {
    signingConfigs {
        release {
            storeFile file("../medivault-release-key.jks")
            storePassword "your-password"
            keyAlias "medivault-key"
            keyPassword "your-password"
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

3. **Build Release APK**:
```bash
./gradlew assembleRelease
```

APK location: `app/build/outputs/apk/release/app-release.apk`

### Generate App Bundle (for Play Store)

```bash
./gradlew bundleRelease
```

Bundle location: `app/build/outputs/bundle/release/app-release.aab`

## 🐛 Troubleshooting

### Connection Issues

**Problem**: App shows "Could not connect to server"

**Solutions**:
1. Check Rails server is running: `curl http://localhost:3000`
2. Verify URL in `MainActivity.kt`
3. For emulator, use `http://10.0.2.2:3000`
4. For device, check firewall allows port 3000
5. Ensure device and computer on same network

### Gradle Sync Issues

**Problem**: Gradle sync fails

**Solutions**:
```bash
# Clear Gradle cache
rm -rf ~/.gradle/caches/

# In Android Studio:
# File → Invalidate Caches / Restart
```

### Build Errors

**Problem**: Compilation errors

**Solutions**:
1. Clean project: Build → Clean Project
2. Rebuild: Build → Rebuild Project
3. Check Kotlin version matches in build.gradle
4. Update Android Studio to latest version

### Hotwire Navigation Issues

**Problem**: Pages not loading or navigation broken

**Solutions**:
1. Check path configuration in `configuration.json`
2. Verify Rails routes are Turbo-compatible
3. Check browser console for JavaScript errors
4. Test same URL in mobile browser first

## 📚 Resources

- [Hotwire Native Documentation](https://native.hotwired.dev/)
- [Turbo Android Documentation](https://github.com/hotwired/turbo-android)
- [Android Developer Guide](https://developer.android.com/)
- [Material Design Guidelines](https://material.io/design)

## 🤝 Contributing

1. Create feature branch
2. Make changes
3. Test on emulator and physical device
4. Submit pull request

## 📄 License

Same as MediVault main project.

## 💡 Tips

- Use Chrome Remote Debugging to inspect WebView
- Enable debug logging in `MainApplication.kt`
- Test on multiple Android versions
- Test with slow network (use Android Studio Network Profiler)
- Consider adding native features for better UX:
  - Biometric authentication
  - Push notifications
  - Native camera integration
  - Offline data storage

## 🔐 Security Notes

- Always use HTTPS in production
- Enable certificate pinning for production
- Store sensitive data in Android Keystore
- Use ProGuard/R8 for release builds
- Never commit keystore files to git
- Validate all deep links

## 📞 Support

For issues specific to the Android app, create an issue with:
- Android version
- Device model
- Steps to reproduce
- Logcat output (`adb logcat`)
