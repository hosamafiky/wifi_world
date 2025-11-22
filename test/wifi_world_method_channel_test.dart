import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_world/wifi_world_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelWifiWorld platform = MethodChannelWifiWorld();
  const MethodChannel channel = MethodChannel('wifi_world');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getNetworkInfo') {
        return {'networkType': 'wifi', 'connectionStatus': 'connected', 'isInternetAvailable': true, 'isMetered': false};
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getNetworkInfo', () async {
    final networkInfo = await platform.getNetworkInfo();
    expect(networkInfo.networkType.name, 'wifi');
    expect(networkInfo.isConnected, true);
  });
}
