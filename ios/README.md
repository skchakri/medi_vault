# MediVault iOS App

A native iOS application for MediVault built with [Hotwire Native](https://native.hotwired.dev/ios), wrapping the Rails web application in a native mobile experience.

## 🚀 Features

- **Hotwire Native**: Fast, native-feeling app using your existing Rails views
- **Turbo**: Lightning-fast page navigation without full page reloads
- **Native Navigation**: iOS-native navigation with proper gestures
- **Strada**: Native bridge components for enhanced functionality
- **Offline Support**: Graceful handling of offline scenarios
- **Deep Linking**: Direct links to specific content in the app
- **File Uploads**: Native camera and photo library integration
- **iOS Design**: Beautiful UI following iOS Human Interface Guidelines

## 📋 Prerequisites

- **macOS** Ventura (13.0) or newer
- **Xcode** 15.0 or newer
- **CocoaPods** 1.14 or newer
- **Ruby** 2.7 or newer (for CocoaPods)
- **Rails Server** running locally or accessible via network

## 🛠 Setup Instructions

### 1. Install Dependencies

**Install CocoaPods** (if not already installed):
```bash
sudo gem install cocoapods
```

**Install Bundler** (recommended):
```bash
gem install bundler
```

### 2. Setup Project

**Quick Setup** (recommended):
```bash
cd ios
make setup
```

**Manual Setup**:
```bash
cd ios
bundle install
pod install
```

This will:
- Install Ruby gems (fastlane, cocoapods)
- Install CocoaPods dependencies (Turbo, Strada)
- Generate `MediVault.xcworkspace`

### 3. Configure Server URL

Edit `SceneDelegate.swift` and update the base URL:

```swift
// Line 5
private let baseURL = URL(string: "http://localhost:3000")!

// For production:
// private let baseURL = URL(string: "https://medivault.com")!
```

**For Physical Device**:
Find your Mac's local IP address:
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

Update to use your IP:
```swift
private let baseURL = URL(string: "http://192.168.1.100:3000")!
```

### 4. Open in Xcode

```bash
cd ios
open MediVault.xcworkspace
```

**⚠️ Important**: Always open `.xcworkspace`, not `.xcodeproj`

### 5. Start Rails Server

Make sure your Rails server is running:

```bash
# In the Rails project directory
cd /home/kalyan/platform/personal/medi_vault
rails server -b 0.0.0.0 -p 3000
```

The `-b 0.0.0.0` flag allows external connections (needed for physical devices).

### 6. Run the App

1. Select a simulator from the dropdown (e.g., "iPhone 15 Pro")
2. Click the **Run** button (▶️) or press `Cmd+R`
3. Wait for the app to build and launch

## 📱 Testing

### iOS Simulator

**Recommended Simulators**:
- iPhone 15 Pro (iOS 17)
- iPhone 14 (iOS 16)
- iPad Pro 12.9" (iOS 17)

**Managing Simulators**:
1. Xcode → Window → Devices and Simulators
2. Click **+** to add new simulators
3. Select device type and iOS version

### Physical Device

1. **Connect Device**:
   - Connect iPhone/iPad via USB or Wi-Fi
   - Trust computer if prompted

2. **Configure Signing**:
   - Select project in Xcode
   - Go to "Signing & Capabilities"
   - Select your Team
   - Xcode will auto-generate provisioning profile

3. **Allow Developer App**:
   - On device: Settings → General → VPN & Device Management
   - Trust your developer certificate

4. **Run on Device**:
   - Select your device from dropdown
   - Click Run

## 🔧 Configuration

### Path Configuration

The app uses a JSON configuration file to control navigation behavior:

**Location**: `MediVault/Resources/configuration.json`

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
- `default`: Normal navigation with push transitions
- `modal`: Presents as modal sheet

### Customizing Navigation

**WebViewController.swift**: Customize web view behavior
- Navigation bar appearance
- Pull to refresh
- Error handling
- Page transitions

**SceneDelegate.swift**: Customize app-level behavior
- Deep link handling
- URL routing
- Session management

## 🎨 Branding

### App Icon

Replace app icons in Xcode:
1. Open `Assets.xcassets`
2. Click `AppIcon`
3. Drag images to appropriate slots:
   - iPhone (2x): 120x120
   - iPhone (3x): 180x180
   - iPad (2x): 152x152
   - App Store: 1024x1024

Or use [App Icon Generator](https://appicon.co/)

### Colors

Colors are defined in `Assets.xcassets`:

**PurplePrimary**: #7E22CE (RGB: 126, 34, 206)

To modify:
1. Open `Assets.xcassets`
2. Select color set
3. Update RGB values

### App Name

Update in `Info.plist`:
```xml
<key>CFBundleDisplayName</key>
<string>MediVault</string>
```

## 🚀 Building for Production

### 1. Configure Release Settings

In Xcode:
1. Select project → MediVault target
2. Build Settings → All
3. Set these for Release configuration:
   - Swift Optimization Level: `-O` (Optimize for Speed)
   - Validate Workspace: Yes
   - Strip Debug Symbols: Yes

### 2. Update Info.plist

Ensure production server URL in code:
```swift
private let baseURL = URL(string: "https://medivault.com")!
```

### 3. Archive the App

1. Product → Scheme → Edit Scheme
2. Set Run scheme to "Release"
3. Select "Any iOS Device (arm64)"
4. Product → Archive
5. Wait for archive to complete

### 4. Distribute to App Store

1. Window → Organizer
2. Select your archive
3. Click "Distribute App"
4. Choose distribution method:
   - **App Store Connect**: For App Store submission
   - **Ad Hoc**: For beta testing (TestFlight)
   - **Enterprise**: For internal distribution
   - **Development**: For testing

### 5. Upload to App Store Connect

1. Select "App Store Connect"
2. Next → Upload
3. Wait for upload to complete
4. Go to [App Store Connect](https://appstoreconnect.apple.com)
5. Complete app listing and submit for review

## 🐛 Troubleshooting

### "Command PhaseScriptExecution failed"

**Solution**:
```bash
cd ios
pod deintegrate
pod install
```

### "Unable to boot simulator"

**Solution**:
```bash
# Reset simulator
xcrun simctl shutdown all
xcrun simctl erase all
```

### "No such module 'Turbo'"

**Solution**:
```bash
cd ios
rm -rf Pods/ Podfile.lock
pod install
# Clean build folder in Xcode: Cmd+Shift+K
```

### Connection Issues

**Problem**: App shows "Could not connect to server"

**Solutions**:
1. Check Rails server is running: `curl http://localhost:3000`
2. Verify URL in `SceneDelegate.swift`
3. For device, use Mac's local IP (not localhost)
4. Check firewall allows port 3000:
   ```bash
   sudo ufw allow 3000
   ```
5. Ensure device and Mac on same Wi-Fi network

### Build Errors

**Problem**: Build fails with errors

**Solutions**:
1. Clean build folder: Product → Clean Build Folder (Cmd+Shift+K)
2. Delete derived data:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```
3. Update CocoaPods:
   ```bash
   sudo gem update cocoapods
   cd ios && pod update
   ```

### Signing Issues

**Problem**: Code signing errors

**Solutions**:
1. Xcode → Preferences → Accounts → Add Apple ID
2. Select project → Signing & Capabilities
3. Ensure "Automatically manage signing" is checked
4. Select your Team

## 📚 Resources

- [Hotwire Native iOS Documentation](https://native.hotwired.dev/ios)
- [Turbo iOS GitHub](https://github.com/hotwired/turbo-ios)
- [Strada iOS GitHub](https://github.com/hotwired/strada-ios)
- [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

## 🤝 Contributing

1. Create feature branch
2. Make changes
3. Test on simulator and device
4. Test on multiple iOS versions
5. Submit pull request

## 💡 Tips

- **Debug WebView**: Safari → Develop → Simulator → Your Page
- **View Logs**: Xcode → View → Debug Area → Show Debug Area (Cmd+Shift+Y)
- **Network Inspection**: Use Charles Proxy or Proxyman
- **Performance**: Use Instruments (Cmd+I) to profile
- **Accessibility**: Enable VoiceOver to test accessibility

## 🔐 Security Notes

- Always use HTTPS in production
- Enable App Transport Security (ATS)
- Store sensitive data in Keychain
- Use certificate pinning for production
- Never commit signing certificates to git
- Validate all deep links
- Implement biometric authentication for sensitive features

## 📞 Support

For iOS-specific issues, create an issue with:
- iOS version
- Device model
- Xcode version
- Steps to reproduce
- Console logs from Xcode

## 🎯 Project Structure

```
ios/
├── MediVault/
│   ├── AppDelegate.swift              # App lifecycle
│   ├── SceneDelegate.swift            # Scene & navigation
│   ├── Controllers/
│   │   └── WebViewController.swift    # Web view controller
│   ├── Models/
│   │   └── PathConfiguration.swift    # Path routing
│   ├── Views/
│   │   ├── Main.storyboard           # Main storyboard
│   │   └── LaunchScreen.storyboard   # Splash screen
│   ├── Resources/
│   │   └── configuration.json         # Nav config
│   ├── Assets.xcassets/               # Images & colors
│   └── Supporting Files/
│       └── Info.plist                 # App metadata
├── Podfile                            # CocoaPods dependencies
├── Package.swift                      # Swift Package Manager
├── Makefile                           # Build commands
└── README.md                          # This file
```

## ⚙️ Available Make Commands

```bash
make setup    # Setup project (install deps and pods)
make install  # Install dependencies only
make open     # Open project in Xcode
make clean    # Clean build artifacts
make help     # Show available commands
```

## 📄 License

Same as MediVault main project.

## 🎊 Next Steps

After setup:

1. **Customize Branding**: Update app icon and colors
2. **Test Features**: Login, file uploads, navigation
3. **Add Native Components**: Biometrics, push notifications
4. **Optimize Performance**: Profile with Instruments
5. **Prepare for Release**: App Store listing, screenshots
6. **Submit to App Store**: Follow Apple's guidelines

**Happy coding!** 📱💜
