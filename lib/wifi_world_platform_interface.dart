import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'models/network_info.dart';
import 'models/wifi_info.dart';
import 'models/wifi_network.dart';
import 'wifi_world_method_channel.dart';

abstract class WifiWorldPlatform extends PlatformInterface {
  /// Constructs a WifiWorldPlatform.
  WifiWorldPlatform() : super(token: _token);

  static final Object _token = Object();

  static WifiWorldPlatform _instance = MethodChannelWifiWorld();

  /// The default instance of [WifiWorldPlatform] to use.
  ///
  /// Defaults to [MethodChannelWifiWorld].
  static WifiWorldPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [WifiWorldPlatform] when
  /// they register themselves.
  static set instance(WifiWorldPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  // ==================== Wi-Fi Information ====================

  /// Gets comprehensive Wi-Fi connection information.
  ///
  /// Returns [WifiInfo] containing SSID, BSSID, IP address, signal strength, etc.
  /// Returns null if not connected to Wi-Fi or if permissions are not granted.
  ///
  /// **Platform Notes:**
  /// - **Android**: Requires ACCESS_FINE_LOCATION permission
  /// - **iOS**: May return null on iOS 13+ without proper entitlements
  Future<WifiInfo?> getWifiInfo() {
    throw UnimplementedError('getWifiInfo() has not been implemented.');
  }

  /// Gets the SSID (network name) of the connected Wi-Fi network.
  ///
  /// Returns null if not connected to Wi-Fi or if permissions are not granted.
  Future<String?> getSSID() {
    throw UnimplementedError('getSSID() has not been implemented.');
  }

  /// Gets the BSSID (router MAC address) of the connected Wi-Fi network.
  ///
  /// Returns null if not connected to Wi-Fi or if permissions are not granted.
  Future<String?> getBSSID() {
    throw UnimplementedError('getBSSID() has not been implemented.');
  }

  /// Gets the IP address of the device on the Wi-Fi network.
  ///
  /// Returns null if not connected to Wi-Fi.
  Future<String?> getIPAddress() {
    throw UnimplementedError('getIPAddress() has not been implemented.');
  }

  /// Gets the signal strength in dBm.
  ///
  /// Returns a value typically between -100 (weak) and 0 (strong).
  /// Returns null if not connected to Wi-Fi or if unavailable.
  Future<int?> getSignalStrength() {
    throw UnimplementedError('getSignalStrength() has not been implemented.');
  }

  // ==================== Network Connectivity ====================

  /// Gets comprehensive network connectivity information.
  ///
  /// Returns [NetworkInfo] containing connection type, status, and internet availability.
  Future<NetworkInfo> getNetworkInfo() {
    throw UnimplementedError('getNetworkInfo() has not been implemented.');
  }

  /// Checks if the device is connected to any network.
  Future<bool> isConnected() {
    throw UnimplementedError('isConnected() has not been implemented.');
  }

  /// Checks if internet is available (not just network connection).
  ///
  /// This may perform an actual connectivity check to verify internet access.
  Future<bool> isInternetAvailable() {
    throw UnimplementedError('isInternetAvailable() has not been implemented.');
  }

  // ==================== Wi-Fi Operations ====================

  /// Scans for available Wi-Fi networks.
  ///
  /// Returns a list of [WifiNetwork] objects representing nearby networks.
  ///
  /// **Platform Notes:**
  /// - **Android**: Requires ACCESS_FINE_LOCATION permission
  /// - **iOS**: Not supported, throws [UnimplementedError]
  Future<List<WifiNetwork>> scanNetworks() {
    throw UnimplementedError('scanNetworks() has not been implemented.');
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
  /// - **iOS**: Not supported, throws [UnimplementedError]
  Future<bool> connectToNetwork({required String ssid, String? password, bool isHidden = false}) {
    throw UnimplementedError('connectToNetwork() has not been implemented.');
  }

  /// Disconnects from the current Wi-Fi network.
  ///
  /// Returns true if disconnection was successful.
  ///
  /// **Platform Notes:**
  /// - **Android**: Requires CHANGE_WIFI_STATE permission
  /// - **iOS**: Not supported, throws [UnimplementedError]
  Future<bool> disconnectFromNetwork() {
    throw UnimplementedError('disconnectFromNetwork() has not been implemented.');
  }

  /// Enables Wi-Fi.
  ///
  /// Returns true if Wi-Fi was enabled successfully.
  ///
  /// **Platform Notes:**
  /// - **Android**: Deprecated on Android 10+ (opens Wi-Fi settings instead)
  /// - **iOS**: Not supported, throws [UnimplementedError]
  Future<bool> enableWifi() {
    throw UnimplementedError('enableWifi() has not been implemented.');
  }

  /// Disables Wi-Fi.
  ///
  /// Returns true if Wi-Fi was disabled successfully.
  ///
  /// **Platform Notes:**
  /// - **Android**: Deprecated on Android 10+ (opens Wi-Fi settings instead)
  /// - **iOS**: Not supported, throws [UnimplementedError]
  Future<bool> disableWifi() {
    throw UnimplementedError('disableWifi() has not been implemented.');
  }

  // ==================== Streams ====================

  /// Stream that emits network connectivity changes.
  ///
  /// Emits [NetworkInfo] whenever the network connection type or status changes.
  Stream<NetworkInfo> onConnectivityChanged() {
    throw UnimplementedError('onConnectivityChanged() has not been implemented.');
  }

  /// Stream that emits Wi-Fi connection changes.
  ///
  /// Emits [WifiInfo] whenever Wi-Fi connection details change
  /// (SSID, signal strength, etc.).
  ///
  /// May emit null when disconnected from Wi-Fi.
  Stream<WifiInfo?> onWifiChanged() {
    throw UnimplementedError('onWifiChanged() has not been implemented.');
  }
}
