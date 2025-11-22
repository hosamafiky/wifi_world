import 'network_enums.dart';

/// Represents detailed information about the current Wi-Fi connection.
class WifiInfo {
  /// Network name (SSID)
  final String? ssid;

  /// Router MAC address (BSSID)
  final String? bssid;

  /// Device's IP address on the network
  final String? ipAddress;

  /// Gateway/Router IP address
  final String? gateway;

  /// Subnet mask
  final String? subnetMask;

  /// List of DNS server addresses
  final List<String>? dnsServers;

  /// Signal strength in dBm (typically -100 to 0, where 0 is strongest)
  final int? signalStrength;

  /// Link speed in Mbps
  final int? linkSpeed;

  /// Frequency in MHz (e.g., 2412 for channel 1 on 2.4GHz, 5180 for channel 36 on 5GHz)
  final int? frequency;

  /// Network ID (Android specific)
  final int? networkId;

  /// Security type of the network
  final WifiSecurity? security;

  /// Whether this is a hidden network
  final bool? isHidden;

  const WifiInfo({
    this.ssid,
    this.bssid,
    this.ipAddress,
    this.gateway,
    this.subnetMask,
    this.dnsServers,
    this.signalStrength,
    this.linkSpeed,
    this.frequency,
    this.networkId,
    this.security,
    this.isHidden,
  });

  /// Creates a WifiInfo from a map (typically from platform channel)
  factory WifiInfo.fromMap(Map<dynamic, dynamic> map) {
    return WifiInfo(
      ssid: map['ssid']?.toString(),
      bssid: map['bssid']?.toString(),
      ipAddress: map['ipAddress']?.toString(),
      gateway: map['gateway']?.toString(),
      subnetMask: map['subnetMask']?.toString(),
      dnsServers: (map['dnsServers'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      signalStrength: map['signalStrength'] as int?,
      linkSpeed: map['linkSpeed'] as int?,
      frequency: map['frequency'] as int?,
      networkId: map['networkId'] as int?,
      security: map['security'] != null ? WifiSecurity.fromString(map['security'].toString()) : null,
      isHidden: map['isHidden'] as bool?,
    );
  }

  /// Converts this WifiInfo to a map
  Map<String, dynamic> toMap() {
    return {
      'ssid': ssid,
      'bssid': bssid,
      'ipAddress': ipAddress,
      'gateway': gateway,
      'subnetMask': subnetMask,
      'dnsServers': dnsServers,
      'signalStrength': signalStrength,
      'linkSpeed': linkSpeed,
      'frequency': frequency,
      'networkId': networkId,
      'security': security?.name,
      'isHidden': isHidden,
    };
  }

  /// Returns the frequency band (e.g., "2.4 GHz" or "5 GHz")
  String? get frequencyBand {
    if (frequency == null) return null;
    if (frequency! < 3000) {
      return '2.4 GHz';
    } else if (frequency! < 6000) {
      return '5 GHz';
    } else {
      return '6 GHz';
    }
  }

  /// Returns signal quality as a percentage (0-100)
  int? get signalQuality {
    if (signalStrength == null) return null;
    // Convert dBm to percentage (approximate)
    // -30 dBm = 100%, -90 dBm = 0%
    final quality = ((signalStrength! + 90) * 100 / 60).clamp(0, 100);
    return quality.round();
  }

  @override
  String toString() {
    return 'WifiInfo(ssid: $ssid, bssid: $bssid, ipAddress: $ipAddress, '
        'signalStrength: $signalStrength dBm, linkSpeed: $linkSpeed Mbps, '
        'frequency: $frequency MHz, security: ${security?.displayName})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WifiInfo && other.ssid == ssid && other.bssid == bssid && other.ipAddress == ipAddress;
  }

  @override
  int get hashCode => Object.hash(ssid, bssid, ipAddress);

  /// Creates a copy of this WifiInfo with optional field replacements
  WifiInfo copyWith({
    String? ssid,
    String? bssid,
    String? ipAddress,
    String? gateway,
    String? subnetMask,
    List<String>? dnsServers,
    int? signalStrength,
    int? linkSpeed,
    int? frequency,
    int? networkId,
    WifiSecurity? security,
    bool? isHidden,
  }) {
    return WifiInfo(
      ssid: ssid ?? this.ssid,
      bssid: bssid ?? this.bssid,
      ipAddress: ipAddress ?? this.ipAddress,
      gateway: gateway ?? this.gateway,
      subnetMask: subnetMask ?? this.subnetMask,
      dnsServers: dnsServers ?? this.dnsServers,
      signalStrength: signalStrength ?? this.signalStrength,
      linkSpeed: linkSpeed ?? this.linkSpeed,
      frequency: frequency ?? this.frequency,
      networkId: networkId ?? this.networkId,
      security: security ?? this.security,
      isHidden: isHidden ?? this.isHidden,
    );
  }
}
