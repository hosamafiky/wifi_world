import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:wifi_world/wifi_world.dart';
import 'package:wifi_world/wifi_world_method_channel.dart';
import 'package:wifi_world/wifi_world_platform_interface.dart';

class MockWifiWorldPlatform with MockPlatformInterfaceMixin implements WifiWorldPlatform {
  @override
  Future<WifiInfo?> getWifiInfo() => Future.value(null);

  @override
  Future<String?> getSSID() => Future.value(null);

  @override
  Future<String?> getBSSID() => Future.value(null);

  @override
  Future<String?> getIPAddress() => Future.value(null);

  @override
  Future<int?> getSignalStrength() => Future.value(null);

  @override
  Future<NetworkInfo> getNetworkInfo() =>
      Future.value(const NetworkInfo(networkType: NetworkType.none, connectionStatus: ConnectionStatus.disconnected, isInternetAvailable: false));

  @override
  Future<bool> isConnected() => Future.value(false);

  @override
  Future<bool> isInternetAvailable() => Future.value(false);

  @override
  Future<List<WifiNetwork>> scanNetworks() => Future.value([]);

  @override
  Future<bool> connectToNetwork({required String ssid, String? password, bool isHidden = false}) => Future.value(false);

  @override
  Future<bool> disconnectFromNetwork() => Future.value(false);

  @override
  Future<bool> enableWifi() => Future.value(false);

  @override
  Future<bool> disableWifi() => Future.value(false);

  @override
  Stream<NetworkInfo> onConnectivityChanged() =>
      Stream.value(const NetworkInfo(networkType: NetworkType.none, connectionStatus: ConnectionStatus.disconnected, isInternetAvailable: false));

  @override
  Stream<WifiInfo?> onWifiChanged() => Stream.value(null);
}

void main() {
  final WifiWorldPlatform initialPlatform = WifiWorldPlatform.instance;

  test('$MethodChannelWifiWorld is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelWifiWorld>());
  });

  test('getNetworkInfo returns valid data', () async {
    WifiWorld wifiWorldPlugin = WifiWorld();
    MockWifiWorldPlatform fakePlatform = MockWifiWorldPlatform();
    WifiWorldPlatform.instance = fakePlatform;

    final networkInfo = await wifiWorldPlugin.getNetworkInfo();
    expect(networkInfo.networkType, NetworkType.none);
    expect(networkInfo.connectionStatus, ConnectionStatus.disconnected);
  });
}
