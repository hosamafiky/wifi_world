import 'network_enums.dart';

/// Represents a Wi-Fi network discovered during scanning.
class WifiNetwork {
  /// Network name (SSID)
  final String ssid;

  /// Router MAC address (BSSID)
  final String bssid;

  /// Signal strength in dBm (typically -100 to 0, where 0 is strongest)
  final int signalStrength;

  /// Frequency in MHz
  final int? frequency;

  /// Security type of the network
  final WifiSecurity security;

  /// Whether this network is saved on the device
  final bool isSaved;

  /// Whether this is a hidden network
  final bool isHidden;

  /// Channel number
  final int? channel;

  const WifiNetwork({
    required this.ssid,
    required this.bssid,
    required this.signalStrength,
    this.frequency,
    this.security = WifiSecurity.unknown,
    this.isSaved = false,
    this.isHidden = false,
    this.channel,
  });

  /// Creates a WifiNetwork from a map (typically from platform channel)
  factory WifiNetwork.fromMap(Map<dynamic, dynamic> map) {
    return WifiNetwork(
      ssid: map['ssid']?.toString() ?? '',
      bssid: map['bssid']?.toString() ?? '',
      signalStrength: map['signalStrength'] as int? ?? -100,
      frequency: map['frequency'] as int?,
      security: WifiSecurity.fromString(map['security']?.toString() ?? 'unknown'),
      isSaved: map['isSaved'] as bool? ?? false,
      isHidden: map['isHidden'] as bool? ?? false,
      channel: map['channel'] as int?,
    );
  }

  /// Converts this WifiNetwork to a map
  Map<String, dynamic> toMap() {
    return {
      'ssid': ssid,
      'bssid': bssid,
      'signalStrength': signalStrength,
      'frequency': frequency,
      'security': security.name,
      'isSaved': isSaved,
      'isHidden': isHidden,
      'channel': channel,
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
  int get signalQuality {
    // Convert dBm to percentage (approximate)
    // -30 dBm = 100%, -90 dBm = 0%
    final quality = ((signalStrength + 90) * 100 / 60).clamp(0, 100);
    return quality.round();
  }

  /// Returns a user-friendly signal strength description
  String get signalStrengthDescription {
    if (signalStrength >= -50) {
      return 'Excellent';
    } else if (signalStrength >= -60) {
      return 'Very Good';
    } else if (signalStrength >= -70) {
      return 'Good';
    } else if (signalStrength >= -80) {
      return 'Fair';
    } else {
      return 'Weak';
    }
  }

  @override
  String toString() {
    return 'WifiNetwork(ssid: $ssid, bssid: $bssid, '
        'signalStrength: $signalStrength dBm ($signalStrengthDescription), '
        'security: ${security.displayName}, frequency: $frequency MHz)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WifiNetwork && other.ssid == ssid && other.bssid == bssid;
  }

  @override
  int get hashCode => Object.hash(ssid, bssid);

  /// Creates a copy of this WifiNetwork with optional field replacements
  WifiNetwork copyWith({
    String? ssid,
    String? bssid,
    int? signalStrength,
    int? frequency,
    WifiSecurity? security,
    bool? isSaved,
    bool? isHidden,
    int? channel,
  }) {
    return WifiNetwork(
      ssid: ssid ?? this.ssid,
      bssid: bssid ?? this.bssid,
      signalStrength: signalStrength ?? this.signalStrength,
      frequency: frequency ?? this.frequency,
      security: security ?? this.security,
      isSaved: isSaved ?? this.isSaved,
      isHidden: isHidden ?? this.isHidden,
      channel: channel ?? this.channel,
    );
  }
}
