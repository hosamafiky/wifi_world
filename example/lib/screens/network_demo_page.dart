import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_world/wifi_world.dart';

import '../widgets/dialogs/connect_dialog.dart';
import '../widgets/dialogs/disconnect_dialog.dart';
import '../widgets/tabs/network_info_tab.dart';
import '../widgets/tabs/scan_tab.dart';
import '../widgets/tabs/wifi_info_tab.dart';

/// Main demo page with tabbed interface for Wi-Fi and network features
class NetworkDemoPage extends StatefulWidget {
  const NetworkDemoPage({super.key});

  @override
  State<NetworkDemoPage> createState() => _NetworkDemoPageState();
}

class _NetworkDemoPageState extends State<NetworkDemoPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _wifiWorld = WifiWorld.instance;

  // State
  WifiInfo? _wifiInfo;
  NetworkInfo? _networkInfo;
  List<WifiNetwork> _networks = [];
  bool _isScanning = false;

  // Streams
  StreamSubscription<NetworkInfo>? _connectivitySubscription;
  StreamSubscription<WifiInfo?>? _wifiSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initData();
    _setupStreams();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _wifiSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    if (await _ensurePermission()) {
      await Future.wait([_refreshWifiInfo(), _refreshNetworkInfo()]);
    }
  }

  Future<bool> _ensurePermission() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      status = await Permission.location.request();
    }
    if (status.isPermanentlyDenied) {
      _showError('Location permission is permanently denied. Please enable it in settings.');
      await openAppSettings();
      return false;
    }
    return status.isGranted;
  }

  void _setupStreams() {
    _connectivitySubscription = _wifiWorld.onConnectivityChanged().listen((networkInfo) {
      if (mounted) {
        setState(() => _networkInfo = networkInfo);
      }
    });

    _wifiSubscription = _wifiWorld.onWifiChanged().listen((wifiInfo) {
      if (mounted) {
        setState(() => _wifiInfo = wifiInfo);
      }
    });
  }

  Future<void> _refreshWifiInfo() async {
    try {
      final info = await _wifiWorld.getWifiInfo();
      if (mounted) {
        setState(() => _wifiInfo = info);
      }
    } catch (e) {
      _showError('Error getting Wi-Fi info: $e');
    }
  }

  Future<void> _refreshNetworkInfo() async {
    try {
      final info = await _wifiWorld.getNetworkInfo();
      if (mounted) {
        setState(() => _networkInfo = info);
      }
    } catch (e) {
      _showError('Error getting network info: $e');
    }
  }

  Future<void> _scanNetworks() async {
    if (!await _ensurePermission()) {
      _showError('Location permission is required to scan networks');
      return;
    }

    setState(() => _isScanning = true);

    try {
      final networks = await _wifiWorld.scanNetworks();
      if (mounted) {
        setState(() {
          _networks = networks;
          _isScanning = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isScanning = false);
      }
      _showError('Error scanning networks: $e');
    }
  }

  Future<void> _handleNetworkTap(WifiNetwork network) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConnectDialog(network: network),
    );

    if (result == true && mounted) {
      _showSuccess('Successfully connected to ${network.ssid}');
      // Refresh data after connecting
      await Future.delayed(const Duration(seconds: 2));
      _refreshWifiInfo();
      _refreshNetworkInfo();
    } else if (result == false && mounted) {
      _showError('Failed to connect to ${network.ssid}');
    }
  }

  Future<void> _handleDisconnect() async {
    if (_wifiInfo?.ssid == null) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => DisconnectDialog(ssid: _wifiInfo!.ssid!),
    );

    if (result == true && mounted) {
      _showSuccess('Disconnected from Wi-Fi');
      // Refresh data after disconnecting
      await Future.delayed(const Duration(seconds: 1));
      _refreshWifiInfo();
      _refreshNetworkInfo();
    } else if (result == false && mounted) {
      _showError('Failed to disconnect');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WiFi World Demo'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.wifi), text: 'Wi-Fi Info'),
            Tab(icon: Icon(Icons.network_check), text: 'Network'),
            Tab(icon: Icon(Icons.radar), text: 'Scan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          WifiInfoTab(wifiInfo: _wifiInfo, networkInfo: _networkInfo, onRefresh: _refreshWifiInfo, onDisconnect: _wifiInfo != null ? _handleDisconnect : null),
          NetworkInfoTab(networkInfo: _networkInfo, onRefresh: _refreshNetworkInfo),
          ScanTab(networks: _networks, isScanning: _isScanning, onScan: _scanNetworks, onNetworkTap: _handleNetworkTap),
        ],
      ),
    );
  }
}
