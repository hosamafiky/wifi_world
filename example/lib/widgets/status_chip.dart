import 'package:flutter/material.dart';

/// Status chip widget showing active/inactive state
class StatusChip extends StatelessWidget {
  final String label;
  final bool isActive;

  const StatusChip({super.key, required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.green[50] : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isActive ? Colors.green : Colors.grey, width: 2),
      ),
      child: Row(
        children: [
          Icon(isActive ? Icons.check_circle : Icons.circle_outlined, color: isActive ? Colors.green : Colors.grey, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(fontSize: 16, color: isActive ? Colors.green[900] : Colors.grey[700], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
