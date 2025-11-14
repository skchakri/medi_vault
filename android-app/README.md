# MediVault Android App (Hotwire Native)

This is the native Android application for MediVault healthcare platform, built using Hotwire Native (Turbo Native).

## Features

- 🚀 **Hotwire Native** - Wraps the Rails web app in a native Android shell
- 📱 **Native Performance** - Fast, smooth navigation with native transitions
- 📸 **QR Code Scanner** - Scan doctor QR codes to view profiles
- 🔔 **Push Notifications** - Receive appointment reminders and messages
- 🌐 **Offline Support** - Graceful handling of network issues
- 🎨 **Material Design** - Hospital green theme matching the web app

## Prerequisites

- Android Studio Hedgehog (2023.1.1) or later
- JDK 17 or later
- Android SDK (API Level 26+)
- Kotlin 1.9.0+

## Setup Instructions

### 1. Install Android Studio

Download and install Android Studio from: https://developer.android.com/studio

### 2. Open the Project

1. Open Android Studio
2. Click "Open" and select the `android-app` directory
3. Wait for Gradle sync to complete (first time takes 5-10 minutes)
4. If Gradle sync fails, click "Sync Project with Gradle Files" button in toolbar

**Note**: The Android app must be built using Android Studio. It includes JDK 17 and Android SDK. Command-line builds require separate JDK installation.

### 3. Configure the Server URL

Edit `MainActivity.kt` and update the `BASE_URL`:

```kotlin
companion object {
    // For Android Emulator (connects to host machine's localhost)
    const val BASE_URL = "http://10.0.2.2:7000"

    // For physical device on same network
    // const val BASE_URL = "http://192.168.1.100:7000"

    // For production
    // const val BASE_URL = "https://your-production-url.com"
}
```

**Important**:
- For Android Emulator: Use `10.0.2.2` (special alias for host machine's localhost)
- For physical device: Use your computer's local IP address (find with `ipconfig` or `ifconfig`)
- For production: Use your deployed app URL

### 4. Run the Rails Server

Make sure your Rails server is accessible:

```bash
# From the main project directory
docker compose up

# Verify it's running
curl http://localhost:7000
```

**For physical device testing**, you need to expose the server on your network:

```bash
# Option 1: Update docker-compose.yml to bind to 0.0.0.0
# Change ports from "7000:7000" to "0.0.0.0:7000:7000"

# Option 2: Use ngrok for external access
ngrok http 7000
# Then use the ngrok URL in MainActivity.kt
```

### 5. Build and Run

1. Connect an Android device or start an emulator
2. Click the "Run" button (green play icon) in Android Studio
3. Select your device
4. Wait for the app to install and launch

## Project Structure

```
android-app/
├── app/
│   ├── src/
│   │   └── main/
│   │       ├── java/com/medivault/app/
│   │       │   ├── MainActivity.kt           # Main entry point
│   │       │   ├── MainSessionNavHostFragment.kt  # Navigation host
│   │       │   ├── WebFragment.kt           # Web view fragment
│   │       │   ├── NativeBridge.kt          # JS-Native bridge
│   │       │   ├── QRScannerActivity.kt     # QR code scanner
│   │       │   └── TurboActivity.kt         # Turbo interface
│   │       ├── res/
│   │       │   ├── layout/                  # XML layouts
│   │       │   ├── values/                  # Strings, colors, themes
│   │       │   └── xml/                     # Config files
│   │       ├── assets/
│   │       │   └── json/
│   │       │       └── configuration.json   # Turbo path config
│   │       └── AndroidManifest.xml
│   └── build.gradle                         # App dependencies
├── build.gradle                             # Project build file
├── settings.gradle                          # Project settings
└── README.md                                # This file
```

## Key Files

### MainActivity.kt
The main activity that hosts the Turbo session and handles navigation.

### NativeBridge.kt
JavaScript bridge that exposes native functionality to the web app:
- `showToast(message)` - Show native toast messages
- `scanQRCode()` - Open QR code scanner
- `vibrate(duration)` - Trigger device vibration
- `shareText(text, title)` - Native share dialog

### QRScannerActivity.kt
Handles QR code scanning for doctor profiles. Automatically navigates to the scanned doctor's profile.

### configuration.json
Turbo path configuration that defines how different URLs are handled in the app.

## Using Native Features from Web App

You can call native functions from your Rails app using JavaScript:

```javascript
// Show a toast message
if (window.NativeBridge) {
  NativeBridge.showToast("Hello from native!");
}

// Open QR scanner
if (window.NativeBridge) {
  NativeBridge.scanQRCode();
}

// Vibrate device
if (window.NativeBridge) {
  NativeBridge.vibrate(100);  // milliseconds
}

// Share content
if (window.NativeBridge) {
  NativeBridge.shareText("Check out this doctor!", "Share");
}
```

## Building APK

### Debug APK

```bash
./gradlew assembleDebug
```

APK location: `app/build/outputs/apk/debug/app-debug.apk`

### Release APK

1. Create a keystore (first time only):
```bash
keytool -genkey -v -keystore medivault-release-key.keystore \
  -alias medivault -keyalg RSA -keysize 2048 -validity 10000
```

2. Create `app/keystore.properties`:
```properties
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=medivault
storeFile=../medivault-release-key.keystore
```

3. Build release APK:
```bash
./gradlew assembleRelease
```

APK location: `app/build/outputs/apk/release/app-release.apk`

## Testing

### Run Unit Tests
```bash
./gradlew test
```

### Run Instrumented Tests
```bash
./gradlew connectedAndroidTest
```

## Troubleshooting

### App shows "Cannot connect to server"

1. Check if Rails server is running: `curl http://localhost:7000`
2. For emulator: Ensure using `10.0.2.2:7000`
3. For physical device: Check firewall settings and use local IP
4. Verify network connectivity in app

### QR Scanner not working

1. Grant camera permission in app settings
2. Check camera is working in other apps
3. Ensure good lighting when scanning

### Slow performance

1. Enable hardware acceleration in WebView
2. Check network speed
3. Clear app data and cache

### Build errors

1. Clean and rebuild:
```bash
./gradlew clean
./gradlew build
```

2. Invalidate caches in Android Studio:
   File → Invalidate Caches → Invalidate and Restart

3. Update dependencies in `app/build.gradle`

## Publishing to Google Play

1. **Prepare**:
   - Create Google Play Developer account
   - Create app in Play Console
   - Prepare screenshots, description, and graphics

2. **Build**:
   - Generate signed release APK/AAB
   - Test thoroughly on multiple devices

3. **Upload**:
   - Upload to Play Console
   - Fill in store listing details
   - Set pricing and distribution
   - Submit for review

4. **Monitor**:
   - Check for crashes in Play Console
   - Monitor user reviews
   - Push updates regularly

## Contributing

1. Create a feature branch
2. Make your changes
3. Test on multiple devices
4. Submit pull request

## License

Copyright © 2024 MediVault. All rights reserved.

## Support

For issues and questions:
- Email: support@medivault.app
- GitHub Issues: [Create issue](https://github.com/your-repo/issues)
