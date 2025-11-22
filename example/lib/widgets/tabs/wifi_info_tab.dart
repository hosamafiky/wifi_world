import 'package:flutter/material.dart';
import 'package:wifi_world/wifi_world.dart';

import '../../models/info_row.dart';
import '../../widgets/connection_card.dart';
import '../../widgets/info_card.dart';
import '../../widgets/signal_strength_indicator.dart';

/// Tab displaying comprehensive Wi-Fi connection information
class WifiInfoTab extends StatelessWidget {
  final WifiInfo? wifiInfo;
  final NetworkInfo? networkInfo;
  final VoidCallback onRefresh;
  final VoidCallback? onDisconnect;

  const WifiInfoTab({super.key, required this.wifiInfo, required this.networkInfo, required this.onRefresh, this.onDisconnect});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ConnectionCard(networkInfo: networkInfo, wifiInfo: wifiInfo),
          const SizedBox(height: 16),
          if (wifiInfo != null) ...[
            // Disconnect button
            if (onDisconnect != null)
              ElevatedButton.icon(
                onPressed: onDisconnect,
                icon: const Icon(Icons.wifi_off),
                label: const Text('Disconnect from Network'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48)),
              ),
            const SizedBox(height: 16),
            InfoCard(
              title: 'Network Details',
              rows: [
                InfoRow('SSID', wifiInfo?.ssid ?? 'N/A'),
                InfoRow('BSSID', wifiInfo?.bssid ?? 'N/A'),
                InfoRow('IP Address', wifiInfo?.ipAddress ?? 'N/A'),
                InfoRow('Gateway', wifiInfo?.gateway ?? 'N/A'),
                InfoRow('Subnet Mask', wifiInfo?.subnetMask ?? 'N/A'),
                InfoRow('DNS Servers', wifiInfo?.dnsServers?.join(', ') ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 16),
            InfoCard(
              title: 'Signal Information',
              rows: [
                InfoRow('Signal Strength', wifiInfo?.signalStrength != null ? '${wifiInfo!.signalStrength} dBm' : 'N/A'),
                InfoRow('Signal Quality', wifiInfo?.signalQuality != null ? '${wifiInfo!.signalQuality}%' : 'N/A'),
                InfoRow('Link Speed', wifiInfo?.linkSpeed != null ? '${wifiInfo!.linkSpeed} Mbps' : 'N/A'),
                InfoRow('Frequency', wifiInfo?.frequency != null ? '${wifiInfo!.frequency} MHz' : 'N/A'),
                InfoRow('Frequency Band', wifiInfo?.frequencyBand ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 16),
            if (wifiInfo?.signalQuality != null) SignalStrengthIndicator(quality: wifiInfo!.signalQuality!),
          ] else
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Not connected to Wi-Fi', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
              ),
            ),
        ],
      ),
    );
  }
}
