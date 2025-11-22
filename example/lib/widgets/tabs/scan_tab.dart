import 'package:flutter/material.dart';
import 'package:wifi_world/wifi_world.dart';

import '../../utils/network_ui_helpers.dart';

/// Tab for scanning and displaying available Wi-Fi networks
class ScanTab extends StatelessWidget {
  final List<WifiNetwork> networks;
  final bool isScanning;
  final VoidCallback onScan;
  final Function(WifiNetwork) onNetworkTap;

  const ScanTab({super.key, required this.networks, required this.isScanning, required this.onScan, required this.onNetworkTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isScanning ? null : onScan,
                  icon: isScanning ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.radar),
                  label: Text(isScanning ? 'Scanning...' : 'Scan Networks'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: networks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_find, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        isScanning ? 'Scanning for networks...' : 'Tap "Scan Networks" to find Wi-Fi networks',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: networks.length,
                  itemBuilder: (context, index) {
                    return _NetworkListItem(network: networks[index], onTap: () => onNetworkTap(networks[index]));
                  },
                ),
        ),
      ],
    );
  }
}

/// List item widget for displaying individual network
class _NetworkListItem extends StatelessWidget {
  final WifiNetwork network;
  final VoidCallback onTap;

  const _NetworkListItem({required this.network, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Icon(NetworkUIHelpers.getWifiIcon(network.signalQuality), color: NetworkUIHelpers.getSignalColor(network.signalQuality)),
        title: Text(network.ssid.isEmpty ? '<Hidden Network>' : network.ssid, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${network.signalStrengthDescription} '
              '(${network.signalQuality}%)',
            ),
            Text(
              '${network.security.displayName} • '
              '${network.frequencyBand ?? "Unknown"}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (network.isSaved) const Icon(Icons.check_circle, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
