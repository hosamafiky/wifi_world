import 'package:flutter/material.dart';
import 'package:wifi_world/wifi_world.dart';

/// Dialog for disconnecting from current Wi-Fi network
class DisconnectDialog extends StatefulWidget {
  final String ssid;

  const DisconnectDialog({super.key, required this.ssid});

  @override
  State<DisconnectDialog> createState() => _DisconnectDialogState();
}

class _DisconnectDialogState extends State<DisconnectDialog> {
  bool _isDisconnecting = false;

  Future<void> _disconnect() async {
    setState(() => _isDisconnecting = true);

    try {
      final success = await WifiWorld.instance.disconnectFromNetwork();

      if (mounted) {
        Navigator.of(context).pop(success);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDisconnecting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Disconnect from Wi-Fi'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Are you sure you want to disconnect from "${widget.ssid}"?'),
          const SizedBox(height: 16),
          const Text('You may lose internet connectivity.', style: TextStyle(color: Colors.orange, fontSize: 12)),
        ],
      ),
      actions: [
        TextButton(onPressed: _isDisconnecting ? null : () => Navigator.of(context).pop(false), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _isDisconnecting ? null : _disconnect,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          child: _isDisconnecting
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Disconnect'),
        ),
      ],
    );
  }
}
