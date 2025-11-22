// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wifi_world/wifi_world.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('getNetworkInfo test', (WidgetTester tester) async {
    final WifiWorld plugin = WifiWorld.instance;
    final networkInfo = await plugin.getNetworkInfo();

    // NetworkInfo should always return a valid object
    expect(networkInfo, isNotNull);
    expect(networkInfo.networkType, isNotNull);
    expect(networkInfo.connectionStatus, isNotNull);
  });

  testWidgets('isConnected test', (WidgetTester tester) async {
    final WifiWorld plugin = WifiWorld.instance;
    final isConnected = await plugin.isConnected();

    // Should return a boolean value
    expect(isConnected, isA<bool>());
  });
}
