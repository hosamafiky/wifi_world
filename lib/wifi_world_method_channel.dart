import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'models/network_enums.dart';
import 'models/network_info.dart';
import 'models/wifi_info.dart';
import 'models/wifi_network.dart';
import 'wifi_world_platform_interface.dart';

/// An implementation of [WifiWorldPlatform] that uses method channels.
class MethodChannelWifiWorld extends WifiWorldPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('wifi_world');

  /// Event channel for connectivity changes
  @visibleForTesting
  final connectivityEventChannel = const EventChannel('wifi_world/connectivity');

  /// Event channel for Wi-Fi changes
  @visibleForTesting
  final wifiEventChannel = const EventChannel('wifi_world/wifi');

  // ==================== Wi-Fi Information ====================

  @override
  Future<WifiInfo?> getWifiInfo() async {
    try {
      final result = await methodChannel.invokeMethod<Map>('getWifiInfo');
      if (result == null) return null;
      return WifiInfo.fromMap(result);
    } on PlatformException catch (e) {
      debugPrint('Error getting Wi-Fi info: ${e.message}');
      return null;
    }
  }

  @override
  Future<String?> getSSID() async {
    try {
      return await methodChannel.invokeMethod<String>('getSSID');
    } on PlatformException catch (e) {
      debugPrint('Error getting SSID: ${e.message}');
      return null;
    }
  }

  @override
  Future<String?> getBSSID() async {
    try {
      return await methodChannel.invokeMethod<String>('getBSSID');
    } on PlatformException catch (e) {
      debugPrint('Error getting BSSID: ${e.message}');
      return null;
    }
  }

  @override
  Future<String?> getIPAddress() async {
    try {
      return await methodChannel.invokeMethod<String>('getIPAddress');
    } on PlatformException catch (e) {
      debugPrint('Error getting IP address: ${e.message}');
      return null;
    }
  }

  @override
  Future<int?> getSignalStrength() async {
    try {
      return await methodChannel.invokeMethod<int>('getSignalStrength');
    } on PlatformException catch (e) {
      debugPrint('Error getting signal strength: ${e.message}');
      return null;
    }
  }

  // ==================== Network Connectivity ====================

  @override
  Future<NetworkInfo> getNetworkInfo() async {
    try {
      final result = await methodChannel.invokeMethod<Map>('getNetworkInfo');
      if (result == null) {
        return const NetworkInfo(networkType: NetworkType.none, connectionStatus: ConnectionStatus.disconnected, isInternetAvailable: false);
      }
      return NetworkInfo.fromMap(result);
    } on PlatformException catch (e) {
      debugPrint('Error getting network info: ${e.message}');
      return const NetworkInfo(networkType: NetworkType.none, connectionStatus: ConnectionStatus.disconnected, isInternetAvailable: false);
    }
  }

  @override
  Future<bool> isConnected() async {
    try {
      final result = await methodChannel.invokeMethod<bool>('isConnected');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error checking connection: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> isInternetAvailable() async {
    try {
      final result = await methodChannel.invokeMethod<bool>('isInternetAvailable');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error checking internet availability: ${e.message}');
      return false;
    }
  }

  // ==================== Wi-Fi Operations ====================

  @override
  Future<List<WifiNetwork>> scanNetworks() async {
    try {
      final result = await methodChannel.invokeMethod<List>('scanNetworks');
      if (result == null) return [];

      return result.map((e) => WifiNetwork.fromMap(e as Map)).toList()..sort((a, b) => b.signalStrength.compareTo(a.signalStrength));
    } on PlatformException catch (e) {
      debugPrint('Error scanning networks: ${e.message}');
      if (e.code == 'UNSUPPORTED') {
        throw UnsupportedError('Network scanning is not supported on this platform');
      }
      return [];
    }
  }

  @override
  Future<bool> connectToNetwork({required String ssid, String? password, bool isHidden = false}) async {
    try {
      final result = await methodChannel.invokeMethod<bool>('connectToNetwork', {'ssid': ssid, 'password': password, 'isHidden': isHidden});
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error connecting to network: ${e.message}');
      if (e.code == 'UNSUPPORTED') {
        throw UnsupportedError('Connecting to networks is not supported on this platform');
      }
      return false;
    }
  }

  @override
  Future<bool> disconnectFromNetwork() async {
    try {
      final result = await methodChannel.invokeMethod<bool>('disconnectFromNetwork');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error disconnecting from network: ${e.message}');
      if (e.code == 'UNSUPPORTED') {
        throw UnsupportedError('Disconnecting from networks is not supported on this platform');
      }
      return false;
    }
  }

  @override
  Future<bool> enableWifi() async {
    try {
      final result = await methodChannel.invokeMethod<bool>('enableWifi');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error enabling Wi-Fi: ${e.message}');
      if (e.code == 'UNSUPPORTED') {
        throw UnsupportedError('Enabling Wi-Fi is not supported on this platform');
      }
      return false;
    }
  }

  @override
  Future<bool> disableWifi() async {
    try {
      final result = await methodChannel.invokeMethod<bool>('disableWifi');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error disabling Wi-Fi: ${e.message}');
      if (e.code == 'UNSUPPORTED') {
        throw UnsupportedError('Disabling Wi-Fi is not supported on this platform');
      }
      return false;
    }
  }

  // ==================== Streams ====================

  @override
  Stream<NetworkInfo> onConnectivityChanged() {
    return connectivityEventChannel.receiveBroadcastStream().map((event) {
      if (event is Map) {
        return NetworkInfo.fromMap(event);
      }
      return const NetworkInfo(networkType: NetworkType.none, connectionStatus: ConnectionStatus.disconnected, isInternetAvailable: false);
    });
  }

  @override
  Stream<WifiInfo?> onWifiChanged() {
    return wifiEventChannel.receiveBroadcastStream().map((event) {
      if (event == null) return null;
      if (event is Map) {
        return WifiInfo.fromMap(event);
      }
      return null;
    });
  }
}
