import 'package:flutter/material.dart';
import 'package:wifi_world/wifi_world.dart';

/// Card displaying current connection status with color indicators
class ConnectionCard extends StatelessWidget {
  final NetworkInfo? networkInfo;
  final WifiInfo? wifiInfo;

  const ConnectionCard({super.key, required this.networkInfo, required this.wifiInfo});

  @override
  Widget build(BuildContext context) {
    final isConnected = networkInfo?.isConnected ?? false;
    final hasInternet = networkInfo?.isInternetAvailable ?? false;

    return Card(
      color: isConnected ? (hasInternet ? Colors.green[50] : Colors.orange[50]) : Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isConnected ? (hasInternet ? Icons.wifi : Icons.wifi_off) : Icons.signal_wifi_off,
              size: 48,
              color: isConnected ? (hasInternet ? Colors.green : Colors.orange) : Colors.red,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isConnected ? (wifiInfo?.ssid ?? 'Connected') : 'Not Connected', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    hasInternet ? 'Internet Available' : (isConnected ? 'No Internet' : 'No Network Connection'),
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
