import 'package:equatable/equatable.dart';

import 'network_enums.dart';

/// Represents general network connectivity information.
class NetworkInfo extends Equatable {
  /// The type of network connection
  final NetworkType networkType;

  /// The connection status
  final ConnectionStatus connectionStatus;

  /// Whether internet is available (not just connected to network)
  final bool isInternetAvailable;

  /// Whether the connection is metered (may incur data charges)
  final bool isMetered;

  /// The name of the network interface (e.g., "wlan0", "eth0")
  final String? interfaceName;

  const NetworkInfo({required this.networkType, required this.connectionStatus, required this.isInternetAvailable, this.isMetered = false, this.interfaceName});

  /// Creates a NetworkInfo from a map (typically from platform channel)
  factory NetworkInfo.fromMap(Map<dynamic, dynamic> map) {
    return NetworkInfo(
      networkType: NetworkType.fromString(map['networkType']?.toString() ?? 'unknown'),
      connectionStatus: ConnectionStatus.fromString(map['connectionStatus']?.toString() ?? 'disconnected'),
      isInternetAvailable: map['isInternetAvailable'] as bool? ?? false,
      isMetered: map['isMetered'] as bool? ?? false,
      interfaceName: map['interfaceName']?.toString(),
    );
  }

  /// Converts this NetworkInfo to a map
  Map<String, dynamic> toMap() {
    return {
      'networkType': networkType.name,
      'connectionStatus': connectionStatus.name,
      'isInternetAvailable': isInternetAvailable,
      'isMetered': isMetered,
      'interfaceName': interfaceName,
    };
  }

  /// Whether the device is connected to any network
  bool get isConnected => connectionStatus == ConnectionStatus.connected;

  /// Whether the device is connected via Wi-Fi
  bool get isWifi => networkType == NetworkType.wifi && isConnected;

  /// Whether the device is connected via mobile data
  bool get isMobile => networkType == NetworkType.mobile && isConnected;

  @override
  String toString() {
    return 'NetworkInfo(type: ${networkType.name}, status: ${connectionStatus.name}, '
        'internet: $isInternetAvailable, metered: $isMetered)';
  }

  @override
  List<Object?> get props => [networkType, connectionStatus, isInternetAvailable, isMetered];

  /// Creates a copy of this NetworkInfo with optional field replacements
  NetworkInfo copyWith({NetworkType? networkType, ConnectionStatus? connectionStatus, bool? isInternetAvailable, bool? isMetered, String? interfaceName}) {
    return NetworkInfo(
      networkType: networkType ?? this.networkType,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      isInternetAvailable: isInternetAvailable ?? this.isInternetAvailable,
      isMetered: isMetered ?? this.isMetered,
      interfaceName: interfaceName ?? this.interfaceName,
    );
  }
}
