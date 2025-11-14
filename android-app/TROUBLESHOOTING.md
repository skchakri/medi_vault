# Android App Troubleshooting

## Common Build Issues

### Issue: "Failed to resolve: dev.hotwire:turbo"

**Solution**: The app uses Hotwire Turbo Native 7.1.0. If you're having issues:

1. **Update Gradle sync**:
   - In Android Studio: File → Invalidate Caches → Invalidate and Restart
   - Or run: `./gradlew clean build --refresh-dependencies`

2. **Check internet connection** - Gradle needs to download dependencies

3. **Alternative**: Use the simplified WebView version (see below)

### Simplified WebView Version (No Hotwire)

If Hotwire Turbo dependency issues persist, you can use a simple WebView implementation:

**Update `app/build.gradle`** - Remove Hotwire dependency:

```gradle
dependencies {
    // Remove this line:
    // implementation 'dev.hotwire:turbo:7.1.0'

    // Keep other dependencies
    implementation 'androidx.core:core-ktx:1.12.0'
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.10.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
    implementation 'androidx.swiperefreshlayout:swiperefreshlayout:1.1.0'
    implementation 'com.journeyapps:zxing-android-embedded:4.3.0'
}
```

**Simplified MainActivity.kt**:

```kotlin
package com.medivault.app

import android.annotation.SuppressLint
import android.os.Bundle
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.appcompat.app.AppCompatActivity
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout

class MainActivity : AppCompatActivity() {
    private lateinit var webView: WebView
    private lateinit var swipeRefreshLayout: SwipeRefreshLayout

    @SuppressLint("SetJavaScriptEnabled")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // Enable WebView debugging
        if (BuildConfig.DEBUG) {
            WebView.setWebContentsDebuggingEnabled(true)
        }

        swipeRefreshLayout = findViewById(R.id.swipe_refresh)
        webView = findViewById(R.id.webview)

        // Configure WebView
        webView.settings.apply {
            javaScriptEnabled = true
            domStorageEnabled = true
            databaseEnabled = true
            setSupportZoom(true)
            builtInZoomControls = true
            displayZoomControls = false
        }

        // Add JavaScript bridge
        webView.addJavascriptInterface(NativeBridge(this), "NativeBridge")

        // Handle page loading
        webView.webViewClient = object : WebViewClient() {
            override fun onPageFinished(view: WebView?, url: String?) {
                super.onPageFinished(view, url)
                swipeRefreshLayout.isRefreshing = false
            }
        }

        // Pull to refresh
        swipeRefreshLayout.setOnRefreshListener {
            webView.reload()
        }

        // Load the app
        webView.loadUrl(BASE_URL)
    }

    override fun onBackPressed() {
        if (webView.canGoBack()) {
            webView.goBack()
        } else {
            super.onBackPressed()
        }
    }

    companion object {
        const val BASE_URL = "http://10.0.2.2:7000"
    }
}
```

**Simplified activity_main.xml**:

```xml
<?xml version="1.0" encoding="utf-8"?>
<androidx.swiperefreshlayout.widget.SwipeRefreshLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:id="@+id/swipe_refresh"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <WebView
        android:id="@+id/webview"
        android:layout_width="match_parent"
        android:layout_height="match_parent" />

</androidx.swiperefreshlayout.widget.SwipeRefreshLayout>
```

This simplified version:
- ✅ Still works perfectly with your Rails app
- ✅ Includes JavaScript bridge for native features
- ✅ Has pull-to-refresh
- ✅ Supports back navigation
- ✅ No complex dependencies

### Other Common Issues

#### Gradle Sync Failed

```bash
# Clean and rebuild
./gradlew clean
./gradlew build --stacktrace

# Or in Android Studio
File → Invalidate Caches → Invalidate and Restart
```

#### Build Tools Version Issues

Update in `app/build.gradle`:
```gradle
android {
    compileSdk 34
    buildToolsVersion "34.0.0"  // Add this if needed
}
```

#### Minimum SDK Issues

If you need to support older Android versions:
```gradle
defaultConfig {
    minSdk 21  // Android 5.0+ instead of 26
}
```

#### WebView Issues

1. **Enable debugging**:
```kotlin
WebView.setWebContentsDebuggingEnabled(true)
```

2. **Check in Chrome**: chrome://inspect/#devices

3. **Clear cache**:
```kotlin
webView.clearCache(true)
webView.clearHistory()
```

#### QR Scanner Permission Denied

Add to `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" android:required="false" />
```

Request permission at runtime (already implemented in QRScannerActivity).

#### Network Security Issues

For development with HTTP (not HTTPS):

`res/xml/network_security_config.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="true">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>
</network-security-config>
```

Add to `AndroidManifest.xml`:
```xml
<application
    android:networkSecurityConfig="@xml/network_security_config"
    ...>
```

## Still Having Issues?

1. Check Android Studio version (Hedgehog 2023.1.1+)
2. Check JDK version (17+)
3. Update Gradle: `./gradlew wrapper --gradle-version 8.2`
4. Check error logs: View → Tool Windows → Logcat
5. Search error message on Stack Overflow
6. Open an issue with full error log

## Quick Test

To test if everything works:

```bash
cd android-app

# Test build
./gradlew assembleDebug

# If successful, APK will be at:
# app/build/outputs/apk/debug/app-debug.apk

# Install on connected device
adb install app/build/outputs/apk/debug/app-debug.apk
```
