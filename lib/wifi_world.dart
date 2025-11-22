import 'models/models.dart';
import 'wifi_world_platform_interface.dart';

export 'models/models.dart';

/// Main class for accessing Wi-Fi and network information.
///
/// This class provides methods to:
/// - Get Wi-Fi connection information (SSID, BSSID, signal strength, etc.)
/// - Monitor network connectivity
/// - Scan for available Wi-Fi networks (Android only)
/// - Connect/disconnect from Wi-Fi networks (Android only, limited on Android 10+)
/// - Enable/disable Wi-Fi (Android only, deprecated on Android 10+)
/// - Stream real-time network and Wi-Fi changes
class WifiWorld {
  WifiWorld._();

  /// Singleton instance
  static final WifiWorld instance = WifiWorld._();

  /// Factory constructor that returns the singleton instance
  factory WifiWorld() => instance;

  // ==================== Wi-Fi Information ====================

  /// Gets comprehensive Wi-Fi connection information.
  ///
  /// Returns [WifiInfo] containing SSID, BSSID, IP address, signal strength, etc.
  /// Returns null if not connected to Wi-Fi or if permissions are not granted.
  ///
  /// **Platform Notes:**
  /// - **Android**: Requires ACCESS_FINE_LOCATION permission
  /// - **iOS**: May return null on iOS 13+ without proper entitlements
  ///
  /// Example:
  /// ```dart
  /// final wifiInfo = await WifiWorld.instance.getWifiInfo();
  /// if (wifiInfo != null) {
  ///   print('Connected to: ${wifiInfo.ssid}');
  ///   print('Signal: ${wifiInfo.signalQuality}%');
  /// }
  /// ```
  Future<WifiInfo?> getWifiInfo() {
    return WifiWorldPlatform.instance.getWifiInfo();
  }

  /// Gets the SSID (network name) of the connected Wi-Fi network.
  ///
  /// Returns null if not connected to Wi-Fi or if permissions are not granted.
  Future<String?> getSSID() {
    return WifiWorldPlatform.instance.getSSID();
  }

  /// Gets the BSSID (router MAC address) of the connected Wi-Fi network.
  ///
  /// Returns null if not connected to Wi-Fi or if permissions are not granted.
  Future<String?> getBSSID() {
    return WifiWorldPlatform.instance.getBSSID();
  }

  /// Gets the IP address of the device on the Wi-Fi network.
  ///
  /// Returns null if not connected to Wi-Fi.
  Future<String?> getIPAddress() {
    return WifiWorldPlatform.instance.getIPAddress();
  }

  /// Gets the signal strength in dBm.
  ///
  /// Returns a value typically between -100 (weak) and 0 (strong).
  /// Returns null if not connected to Wi-Fi or if unavailable.
  Future<int?> getSignalStrength() {
    return WifiWorldPlatform.instance.getSignalStrength();
  }

  // ==================== Network Connectivity ====================

  /// Gets comprehensive network connectivity information.
  ///
  /// Returns [NetworkInfo] containing connection type, status, and internet availability.
  ///
  /// Example:
  /// ```dart
  /// final networkInfo = await WifiWorld.instance.getNetworkInfo();
  /// print('Connected: ${networkInfo.isConnected}');
  /// print('Type: ${networkInfo.networkType.name}');
  /// print('Internet available: ${networkInfo.isInternetAvailable}');
  /// ```
  Future<NetworkInfo> getNetworkInfo() {
    return WifiWorldPlatform.instance.getNetworkInfo();
  }

  /// Checks if the device is connected to any network.
  Future<bool> isConnected() {
    return WifiWorldPlatform.instance.isConnected();
  }

  /// Checks if internet is available (not just network connection).
  ///
  /// This may perform an actual connectivity check to verify internet access.
  Future<bool> isInternetAvailable() {
    return WifiWorldPlatform.instance.isInternetAvailable();
  }

  // ==================== Wi-Fi Operations ====================

  /// Scans for available Wi-Fi networks.
  ///
  /// Returns a list of [WifiNetwork] objects representing nearby networks,
  /// sorted by signal strength (strongest first).
  ///
  /// **Platform Notes:**
  /// - **Android**: Requires ACCESS_FINE_LOCATION permission
  /// - **iOS**: Not supported, throws [UnsupportedError]
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final networks = await WifiWorld.instance.scanNetworks();
  ///   for (var network in networks) {
  ///     print('${network.ssid}: ${network.signalStrengthDescription}');
  ///   }
  /// } on UnsupportedError {
  ///   print('Scanning not supported on this platform');
  /// }
  /// ```
  Future<List<WifiNetwork>> scanNetworks() {
    return WifiWorldPlatform.instance.scanNetworks();
  }

  /// Connects to a Wi-Fi network.
  ///
  /// [ssid] - Network name to connect to
  /// [password] - Network password (null for open networks)
  /// [isHidden] - Whether the network is hidden (default: false)
  ///
  /// Returns true if connection was initiated successfully.
  ///
  /// **Platform Notes:**
  /// - **Android**: Requires CHANGE_WIFI_STATE permission (limited on Android 10+)
  /// - **iOS**: Not supported, throws [UnsupportedError]
  Future<bool> connectToNetwork({required String ssid, String? password, bool isHidden = false}) {
    return WifiWorldPlatform.instance.connectToNetwork(ssid: ssid, password: password, isHidden: isHidden);
  }

  /// Disconnects from the current Wi-Fi network.
  ///
  /// Returns true if disconnection was successful.
  ///
  /// **Platform Notes:**
  /// - **Android**: Requires CHANGE_WIFI_STATE permission
  /// - **iOS**: Not supported, throws [UnsupportedError]
  Future<bool> disconnectFromNetwork() {
    return WifiWorldPlatform.instance.disconnectFromNetwork();
  }

  /// Enables Wi-Fi.
  ///
  /// Returns true if Wi-Fi was enabled successfully.
  ///
  /// **Platform Notes:**
  /// - **Android**: Deprecated on Android 10+ (opens Wi-Fi settings instead)
  /// - **iOS**: Not supported, throws [UnsupportedError]
  Future<bool> enableWifi() {
    return WifiWorldPlatform.instance.enableWifi();
  }

  /// Disables Wi-Fi.
  ///
  /// Returns true if Wi-Fi was disabled successfully.
  ///
  /// **Platform Notes:**
  /// - **Android**: Deprecated on Android 10+ (opens Wi-Fi settings instead)
  /// - **iOS**: Not supported, throws [UnsupportedError]
  Future<bool> disableWifi() {
    return WifiWorldPlatform.instance.disableWifi();
  }

  // ==================== Streams ====================

  /// Stream that emits network connectivity changes.
  ///
  /// Emits [NetworkInfo] whenever the network connection type or status changes.
  ///
  /// Example:
  /// ```dart
  /// WifiWorld.instance.onConnectivityChanged().listen((networkInfo) {
  ///   print('Network changed: ${networkInfo.networkType.name}');
  ///   print('Connected: ${networkInfo.isConnected}');
  /// });
  /// ```
  Stream<NetworkInfo> onConnectivityChanged() {
    return WifiWorldPlatform.instance.onConnectivityChanged();
  }

  /// Stream that emits Wi-Fi connection changes.
  ///
  /// Emits [WifiInfo] whenever Wi-Fi connection details change
  /// (SSID, signal strength, etc.).
  ///
  /// Emits null when disconnected from Wi-Fi.
  ///
  /// Example:
  /// ```dart
  /// WifiWorld.instance.onWifiChanged().listen((wifiInfo) {
  ///   if (wifiInfo != null) {
  ///     print('Wi-Fi: ${wifiInfo.ssid}, Signal: ${wifiInfo.signalQuality}%');
  ///   } else {
  ///     print('Disconnected from Wi-Fi');
  ///   }
  /// });
  /// ```
  Stream<WifiInfo?> onWifiChanged() {
    return WifiWorldPlatform.instance.onWifiChanged();
  }
}
