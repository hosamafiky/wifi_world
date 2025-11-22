import 'package:flutter/material.dart';
import 'package:wifi_world/wifi_world.dart';

import '../../models/info_row.dart';
import '../../widgets/info_card.dart';
import '../../widgets/status_chip.dart';

/// Tab displaying network connectivity information
class NetworkInfoTab extends StatelessWidget {
  final NetworkInfo? networkInfo;
  final VoidCallback onRefresh;

  const NetworkInfoTab({super.key, required this.networkInfo, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          InfoCard(
            title: 'Network Status',
            rows: [
              InfoRow('Connection Type', networkInfo?.networkType.name.toUpperCase() ?? 'Unknown'),
              InfoRow('Status', networkInfo?.connectionStatus.name.toUpperCase() ?? 'Unknown'),
              InfoRow('Internet Available', networkInfo?.isInternetAvailable == true ? 'Yes' : 'No'),
              InfoRow('Metered Connection', networkInfo?.isMetered == true ? 'Yes' : 'No'),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Quick Checks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  StatusChip(label: 'Connected', isActive: networkInfo?.isConnected ?? false),
                  const SizedBox(height: 8),
                  StatusChip(label: 'Wi-Fi', isActive: networkInfo?.isWifi ?? false),
                  const SizedBox(height: 8),
                  StatusChip(label: 'Mobile Data', isActive: networkInfo?.isMobile ?? false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
