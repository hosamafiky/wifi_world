# Changelog

## 0.0.1

Initial release of wifi_world Flutter plugin.

### Features

#### Wi-Fi Information
- Get SSID (network name)
- Get BSSID (router MAC address)
- Get IP address, gateway, subnet mask, and DNS servers
- Get signal strength (RSSI) with quality percentage calculation
- Get link speed and frequency
- Automatic frequency band detection (2.4GHz/5GHz/6GHz)

#### Network Connectivity
- Detect connection type (Wi-Fi, Mobile, Ethernet, VPN, Bluetooth, None)
- Check connection status
- Verify internet availability
- Identify metered connections

#### Wi-Fi Operations (Android only)
- Scan for available Wi-Fi networks with detailed information
- Connect to Wi-Fi networks (limited on Android 10+)
- Disconnect from networks
- Enable/Disable Wi-Fi (opens settings on Android 10+)

#### Real-time Monitoring
- Stream network connectivity changes
- Stream Wi-Fi connection changes

### Platform Support
- Android: Full feature support (with Android 10+ limitations for some operations)
- iOS: Wi-Fi info, network connectivity, and streams (with iOS 13+ limitations)

### Known Limitations
- **iOS**: Wi-Fi SSID/BSSID may return null on iOS 13+ without special entitlements
- **iOS**: Wi-Fi operations (scan, connect, enable/disable) not supported due to platform restrictions
- **Android 10+**: Wi-Fi connect/disconnect operations deprecated, opens system settings instead
- **Android 10+**: Enable/disable Wi-Fi opens system settings instead of programmatic control

