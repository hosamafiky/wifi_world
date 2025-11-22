# wifi_world

A comprehensive Flutter plugin for accessing Wi-Fi and network information on Android and iOS.

## Features

### ✅ Wi-Fi Information
- Get SSID (network name)
- Get BSSID (router MAC address)
- Get IP address, gateway, subnet mask
- Get DNS servers
- Get signal strength (RSSI)
- Get link speed
- Get frequency and band (2.4GHz/5GHz/6GHz)
- Calculate signal quality percentage

### ✅ Network Connectivity
- Detect connection type (Wi-Fi, Mobile, Ethernet, VPN, Bluetooth, None)
- Check connection status
- Verify internet availability
- Identify metered connections
- Real-time connectivity monitoring via streams

### ✅ Wi-Fi Operations (Android only)
- Scan for available networks
- Connect to Wi-Fi networks
- Disconnect from networks
- Enable/Disable Wi-Fi

### ✅ Real-time Updates
- Stream network connectivity changes
- Stream Wi-Fi connection changes

## Platform Support

| Feature | Android | iOS |
|---------|---------|-----|
| Get Wi-Fi Info (SSID, BSSID, IP) | ✅ | ✅ (limited)* |
| Get Signal Strength | ✅ | ✅ (iOS 14+)*** |
| Get Network Info | ✅ | ✅ |
| Check Internet Availability | ✅ | ✅ |
| Scan Networks | ✅ | ✅ (requires entitlement)*** |
| Connect to Network | ✅ (limited)** | ✅ (iOS 11+, requires entitlement)*** |
| Disconnect from Network | ✅ | ✅ (iOS 11+) |
| Enable/Disable Wi-Fi | ✅ (limited)** | ⚠️ (opens Settings) |
| Connectivity Stream | ✅ | ✅ |
| Wi-Fi Stream | ✅ | ✅ |

\* **iOS Wi-Fi Info Limitations**: On iOS 13+, apps need "Access WiFi Information" entitlement and must meet specific criteria (VPN/Hotspot configuration apps). Regular apps may receive `null` values.

\*\* **Android 10+ Limitations**: Many Wi-Fi operations are deprecated. The plugin opens system Wi-Fi settings instead of programmatic control.

\*\*\* **iOS Hotspot Configuration Entitlement Required**: Scanning and connecting to networks on iOS requires the "Hotspot Configuration" entitlement from Apple. See [iOS Setup Guide](ios/IOS_SETUP.md) for details on requesting this entitlement. Without it:
- Scanning will return empty results
- Connecting will fail
- Other features work normally

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  wifi_world: ^0.0.1
```

### Android Setup

Add the following permissions to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
<uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

**Important**: You need to request `ACCESS_FINE_LOCATION` permission at runtime on Android 6.0+ to access Wi-Fi SSID/BSSID. Use a permission plugin like `permission_handler`.

### iOS Setup

**Basic Features** (no setup required):
- Wi-Fi information (SSID, BSSID, IP)
- Network connectivity monitoring
- Disconnecting from networks

**Advanced Features** (requires entitlement):
- Scanning for networks
- Connecting to networks

**To enable scanning and connecting on iOS:**
1. Request "Hotspot Configuration" entitlement from Apple
2. Add Info.plist keys for location access
3. Enable the entitlement in Xcode

📖 **See complete iOS setup guide**: [`ios/IOS_SETUP.md`](ios/IOS_SETUP.md)

## Usage

### Get Wi-Fi Information

```dart
import 'package:wifi_world/wifi_world.dart';

// Get comprehensive Wi-Fi info
final wifiInfo = await WifiWorld.instance.getWifiInfo();
if (wifiInfo != null) {
  print('SSID: ${wifiInfo.ssid}');
  print('BSSID: ${wifiInfo.bssid}');
  print('IP Address: ${wifiInfo.ipAddress}');
  print('Signal Strength: ${wifiInfo.signalStrength} dBm');
  print('Signal Quality: ${wifiInfo.signalQuality}%');
  print('Link Speed: ${wifiInfo.linkSpeed} Mbps');
  print('Frequency Band: ${wifiInfo.frequencyBand}');
}

// Or get individual values
final ssid = await WifiWorld.instance.getSSID();
final bssid = await WifiWorld.instance.getBSSID();
final ipAddress = await WifiWorld.instance.getIPAddress();
final signalStrength = await WifiWorld.instance.getSignalStrength();
```

### Check Network Connectivity

```dart
// Get comprehensive network info
final networkInfo = await WifiWorld.instance.getNetworkInfo();
print('Network Type: ${networkInfo.networkType.name}');
print('Connected: ${networkInfo.isConnected}');
print('Internet Available: ${networkInfo.isInternetAvailable}');
print('Metered: ${networkInfo.isMetered}');

// Quick checks
final isConnected = await WifiWorld.instance.isConnected();
final hasInternet = await WifiWorld.instance.isInternetAvailable();
```

### Scan for Wi-Fi Networks (Android only)

```dart
try {
  final networks = await WifiWorld.instance.scanNetworks();
  for (var network in networks) {
    print('SSID: ${network.ssid}');
    print('BSSID: ${network.bssid}');
    print('Signal: ${network.signalStrengthDescription} (${network.signalQuality}%)');
    print('Security: ${network.security.displayName}');
    print('Frequency: ${network.frequencyBand}');
    print('---');
  }
} on UnsupportedError catch (e) {
  print('Scanning not supported: ${e.message}');
}
```

### Connect to Wi-Fi Network (Android only)

```dart
try {
  final success = await WifiWorld.instance.connectToNetwork(
    ssid: 'MyNetwork',
    password: 'mypassword',
    isHidden: false,
  );
  
  if (success) {
    print('Connected successfully');
  } else {
    print('Failed to connect');
  }
} on UnsupportedError catch (e) {
  print('Connection not supported: ${e.message}');
}
```

### Monitor Network Changes in Real-time

```dart
// Listen to connectivity changes
WifiWorld.instance.onConnectivityChanged().listen((networkInfo) {
  print('Network changed: ${networkInfo.networkType.name}');
  print('Connected: ${networkInfo.isConnected}');
  print('Internet: ${networkInfo.isInternetAvailable}');
});

// Listen to Wi-Fi changes
WifiWorld.instance.onWifiChanged().listen((wifiInfo) {
  if (wifiInfo != null) {
    print('Wi-Fi: ${wifiInfo.ssid}');
    print('Signal: ${wifiInfo.signalQuality}%');
  } else {
    print('Disconnected from Wi-Fi');
  }
});
```

### Example with State Management

```dart
class NetworkMonitor extends ChangeNotifier {
  WifiInfo? _wifiInfo;
  NetworkInfo? _networkInfo;
  StreamSubscription? _connectivitySubscription;
  StreamSubscription? _wifiSubscription;

  NetworkMonitor() {
    _init();
  }

  void _init() {
    // Listen to connectivity changes
    _connectivitySubscription = 
        WifiWorld.instance.onConnectivityChanged().listen((info) {
      _networkInfo = info;
      notifyListeners();
    });

    // Listen to Wi-Fi changes
    _wifiSubscription = 
        WifiWorld.instance.onWifiChanged().listen((info) {
      _wifiInfo = info;
      notifyListeners();
    });
  }

  WifiInfo? get wifiInfo => _wifiInfo;
  NetworkInfo? get networkInfo => _networkInfo;

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _wifiSubscription?.cancel();
    super.dispose();
  }
}
```

## API Reference

### WifiWorld

Main class for accessing Wi-Fi and network features. Use `WifiWorld.instance` for singleton access.

#### Wi-Fi Information Methods

- `Future<WifiInfo?> getWifiInfo()` - Get comprehensive Wi-Fi information
- `Future<String?> getSSID()` - Get network name
- `Future<String?> getBSSID()` - Get router MAC address
- `Future<String?> getIPAddress()` - Get device IP address
- `Future<int?> getSignalStrength()` - Get signal strength in dBm

#### Network Connectivity Methods

- `Future<NetworkInfo> getNetworkInfo()` - Get comprehensive network information
- `Future<bool> isConnected()` - Check if connected to any network
- `Future<bool> isInternetAvailable()` - Check if internet is available

#### Wi-Fi Operations Methods

- `Future<List<WifiNetwork>> scanNetworks()` - Scan for available networks
- `Future<bool> connectToNetwork({required String ssid, String? password, bool isHidden})` - Connect to network
- `Future<bool> disconnectFromNetwork()` - Disconnect from current network
- `Future<bool> enableWifi()` - Enable Wi-Fi
- `Future<bool> disableWifi()` - Disable Wi-Fi

#### Stream Methods

- `Stream<NetworkInfo> onConnectivityChanged()` - Stream of connectivity changes
- `Stream<WifiInfo?> onWifiChanged()` - Stream of Wi-Fi changes

### Data Models

#### WifiInfo

```dart
class WifiInfo {
  final String? ssid;              // Network name
  final String? bssid;             // Router MAC address
  final String? ipAddress;         // Device IP
  final String? gateway;           // Gateway IP
  final String? subnetMask;        // Subnet mask
  final List<String>? dnsServers;  // DNS servers
  final int? signalStrength;       // RSSI in dBm
  final int? linkSpeed;            // Link speed in Mbps
  final int? frequency;            // Frequency in MHz
  final WifiSecurity? security;    // Security type
  
  // Helper properties
  String? get frequencyBand;       // "2.4 GHz" or "5 GHz" or "6 GHz"
  int? get signalQuality;          // Signal quality 0-100%
}
```

#### NetworkInfo

```dart
class NetworkInfo {
  final NetworkType networkType;           // wifi, mobile, ethernet, etc.
  final ConnectionStatus connectionStatus; // connected, disconnected, connecting
  final bool isInternetAvailable;          // Internet availability
  final bool isMetered;                    // Is metered connection
  
  // Helper properties
  bool get isConnected;  // Whether connected
  bool get isWifi;       // Whether Wi-Fi connection
  bool get isMobile;     // Whether mobile connection
}
```

#### WifiNetwork

```dart
class WifiNetwork {
  final String ssid;               // Network name
  final String bssid;              // Router MAC
  final int signalStrength;        // RSSI in dBm
  final int? frequency;            // Frequency in MHz
  final WifiSecurity security;     // Security type
  final bool isSaved;              // Is saved network
  
  // Helper properties
  String? get frequencyBand;               // Frequency band
  int get signalQuality;                   // Quality 0-100%
  String get signalStrengthDescription;    // "Excellent", "Good", etc.
}
```

#### Enums

```dart
enum NetworkType {
  wifi, mobile, ethernet, vpn, bluetooth, none, unknown
}

enum ConnectionStatus {
  connected, disconnected, connecting
}

enum WifiSecurity {
  open, wep, wpa, wpa2, wpa3, wpa2Wpa3, unknown
}
```

## Permissions

### Android

The plugin requires runtime permission for `ACCESS_FINE_LOCATION` on Android 6.0+ to access SSID/BSSID information. Use a permission plugin to request it:

```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> requestLocationPermission() async {
  if (await Permission.location.request().isGranted) {
    // Permission granted, can access Wi-Fi info
  } else {
    // Permission denied
  }
}
```

### iOS

No runtime permissions required, but Wi-Fi information may be restricted based on iOS version and app entitlements.

## Troubleshooting

### Wi-Fi SSID returns null on Android

- Ensure `ACCESS_FINE_LOCATION` permission is granted
- Check that location services are enabled on the device

### Wi-Fi information returns null on iOS

- This is expected behavior on iOS 13+ for apps without special entitlements
- Consider using network connectivity methods instead

### Scanning doesn't work

- **Android**: Ensure location permission is granted
- **iOS**: Not supported, will throw `UnsupportedError`

### Connect/Disconnect doesn't work on Android 10+

- These operations are deprecated on Android 10+
- The plugin opens system Wi-Fi settings instead

## License

[Add your license here]

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

