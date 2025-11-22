# iOS Wi-Fi Scanning and Connection Setup

This document explains how to enable Wi-Fi scanning and connection features on iOS.

## Requirements

iOS Wi-Fi operations (scanning, connecting, disconnecting) require:

1. **iOS 11.0+** for NEHotspotConfiguration (connecting/disconnecting)
2. **iOS 14.0+** for NEHotspotNetwork (improved scanning)
3. **Special Entitlement from Apple** (Hotspot Configuration entitlement)

## What Works Without Entitlement

✅ **Basic Wi-Fi Info**: SSID, BSSID, IP Address (limited on iOS 13+)
✅ **Network Connectivity**: Connection type, status, internet availability
✅ **Streams**: Real-time connectivity and Wi-Fi state monitoring

## What Requires Entitlement

⚠️ **Scanning Networks**: Requires "Hotspot Configuration" entitlement
⚠️ **Connecting to Networks**: Requires "Hotspot Configuration" entitlement  
⚠️ **Disconnecting**: Works without entitlement using NEHotspotConfigurationManager

## Step 1: Request Entitlement from Apple

### Entitlement Type
**"Hotspot Configuration"** (com.apple.developer.networking.HotspotConfiguration)

### How to Request

1. **Visit Apple's Entitlement Request Form**:
   https://developer.apple.com/contact/request/network-extension/

2. **Select Request Type**:
   - Choose "Hotspot Configuration"

3. **Provide Justification**:
   Example justifications that Apple typically approves:
   - "Network utility app for managing Wi-Fi connections"
   - "Wi-Fi analyzer and diagnostic tool"
   - "Network configuration app for enterprise/carrier deployments"
   - "Wi-Fi network scanner for troubleshooting"

4. **Wait for Approval**:
   - Processing time: Usually 1-2 weeks
   - Apple will email you when approved

5. **Add to Your Apple Developer Account**:
   - Once approved, the entitlement appears in your developer account
   - Enable it in Xcode for your app

## Step 2: Update Info.plist

Add the following to your `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to scan for Wi-Fi networks</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs location access to provide Wi-Fi network information</string>
```

**Note**: iOS requires location permission to access Wi-Fi information, even though we're not actually using location services.

## Step 3: Enable Entitlement in Xcode

1. Open your iOS project in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. Select your app target → **Signing & Capabilities**

3. Click **+ Capability**

4. Add **"Hotspot Configuration"**

5. The entitlement file (`Runner.entitlements`) will be created automatically with:
   ```xml
   <key>com.apple.developer.networking.HotspotConfiguration</key>
   <true/>
   ```

## Step 4: Update Podspec (Optional)

If distributing as a package, update `ios/wifi_world.podspec`:

```ruby
s.platform = :ios, '11.0'  # Minimum for NEHotspotConfiguration
```

## Testing

### Without Entitlement

The app will:
- ✅ Show current Wi-Fi connection info
- ✅ Monitor connectivity changes
- ❌ Return empty list when scanning
- ❌ Fail to connect to networks

### With Entitlement

The app will:
- ✅ Scan for nearby Wi-Fi networks (iOS 14+)
- ✅ Show current network only (iOS 11-13)
- ✅ Connect to Wi-Fi networks (shows system password prompt if needed)
- ✅ Disconnect from networks
- ✅ All other features

## API Behavior by iOS Version

| Feature | iOS 11-13 | iOS 14+ |
|---------|-----------|---------|
| Current Network Info | ✅ | ✅ |
| Scan Networks | Current network only | NEHotspotNetwork.fetchCurrent |
| Connect to Network | ✅ NEHotspotConfiguration | ✅ NEHotspotConfiguration |
| Disconnect | ✅ Remove config | ✅ Remove config |
| Signal Strength | ❌ | ✅ (limited) |

## Important Notes

### User Privacy

- iOS will show a system prompt when connecting to a network
- Users can deny the connection even if your app requests it
- The app cannot force a connection without user consent

### Testing on Simulator

- Wi-Fi features **do not work on iOS Simulator**
- You **must test on a physical device**
- Simulator will return empty results or errors

### Production Considerations

1. **Graceful Degradation**: The plugin already handles missing entitlement gracefully
2. **User Feedback**: Show appropriate messages based on what's available
3. **Alternative Flow**: Direct users to iOS Settings if entitlement is not approved

## Troubleshooting

### "Network scanning is not supported on iOS"

✅ **Solution**: Request and enable the Hotspot Configuration entitlement

### Empty scan results

**Possible causes**:
- Entitlement not enabled
- iOS version < 14 (will only return current network)
- Location permission not granted
- Testing on Simulator instead of physical device

### Connection fails silently

**Possible causes**:
- User cancelled the system prompt
- Incorrect password
- Network out of range
- iOS security restrictions (e.g., enterprise networks)

## Example: Requesting Location Permission

```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  // Location permission required for Wi-Fi scanning on iOS
  if (await Permission.location.request().isGranted) {
    // Can now scan for networks
    final networks = await WifiWorld.instance.scanNetworks();
  }
}
```

## References

- [NEHotspotConfiguration Documentation](https://developer.apple.com/documentation/networkextension/nehotspotconfiguration)
- [NEHotspotNetwork Documentation](https://developer.apple.com/documentation/networkextension/nehotspotnetwork)
- [Apple Developer: Network Extension Entitlement](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_developer_networking_hotspotconfiguration)
- [Request Network Extension Entitlement](https://developer.apple.com/contact/request/network-extension/)

## Support

If you have issues:

1. Check if entitlement is properly configured in Xcode
2. Verify you're testing on a physical iOS device
3. Ensure location permission is granted
4. Check iOS version compatibility
5. Review console logs for specific error messages
