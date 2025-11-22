import 'package:flutter/material.dart';

import '../utils/network_ui_helpers.dart';

/// Visual indicator for signal strength with progress bar
class SignalStrengthIndicator extends StatelessWidget {
  final int quality;

  const SignalStrengthIndicator({super.key, required this.quality});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Signal Strength', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: quality / 100,
              minHeight: 20,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(NetworkUIHelpers.getSignalColor(quality)),
            ),
            const SizedBox(height: 8),
            Text('$quality%', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
