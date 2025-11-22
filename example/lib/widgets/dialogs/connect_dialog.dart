import 'package:flutter/material.dart';
import 'package:wifi_world/wifi_world.dart';

/// Dialog for connecting to a Wi-Fi network
class ConnectDialog extends StatefulWidget {
  final WifiNetwork network;

  const ConnectDialog({super.key, required this.network});

  @override
  State<ConnectDialog> createState() => _ConnectDialogState();
}

class _ConnectDialogState extends State<ConnectDialog> {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isConnecting = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isConnecting = true);

    try {
      final success = await WifiWorld.instance.connectToNetwork(
        ssid: widget.network.ssid,
        password: widget.network.security == WifiSecurity.open ? null : _passwordController.text,
        isHidden: false,
      );

      if (mounted) {
        Navigator.of(context).pop(success);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isConnecting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSecured = widget.network.security != WifiSecurity.open;

    return AlertDialog(
      title: Text('Connect to ${widget.network.ssid}'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Network info
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.wifi, color: _getSignalColor(widget.network.signalQuality)),
              title: Text(widget.network.security.displayName),
              subtitle: Text(
                '${widget.network.signalStrengthDescription} • '
                '${widget.network.frequencyBand ?? "Unknown"}',
              ),
            ),
            const SizedBox(height: 16),

            // Password field (only for secured networks)
            if (isSecured) ...[
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
                enabled: !_isConnecting,
              ),
            ] else ...[
              const Text('This is an open network. No password required.', style: TextStyle(color: Colors.grey)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _isConnecting ? null : () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _isConnecting ? null : _connect,
          child: _isConnecting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Connect'),
        ),
      ],
    );
  }

  Color _getSignalColor(int quality) {
    if (quality >= 75) return Colors.green;
    if (quality >= 50) return Colors.orange;
    if (quality >= 25) return Colors.deepOrange;
    return Colors.red;
  }
}
