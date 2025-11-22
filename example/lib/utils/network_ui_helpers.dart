import 'package:flutter/material.dart';

/// Helper functions for network UI
class NetworkUIHelpers {
  /// Returns the appropriate WiFi icon based on signal quality
  static IconData getWifiIcon(int quality) {
    if (quality >= 75) return Icons.wifi;
    if (quality >= 50) return Icons.wifi_2_bar;
    if (quality >= 25) return Icons.wifi_1_bar;
    return Icons.wifi_off;
  }

  /// Returns color based on signal quality
  static Color getSignalColor(int quality) {
    if (quality >= 75) return Colors.green;
    if (quality >= 50) return Colors.orange;
    if (quality >= 25) return Colors.deepOrange;
    return Colors.red;
  }
}
