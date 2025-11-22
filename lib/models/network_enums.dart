/// Represents the type of network connection.
enum NetworkType {
  /// Wi-Fi connection
  wifi,

  /// Mobile/Cellular connection
  mobile,

  /// Ethernet connection
  ethernet,

  /// VPN connection
  vpn,

  /// Bluetooth connection
  bluetooth,

  /// No connection
  none,

  /// Unknown connection type
  unknown;

  static final Map<String, NetworkType> _stringToNetworkTypeMap = {
    'wifi': NetworkType.wifi,
    'mobile': NetworkType.mobile,
    'cellular': NetworkType.mobile,
    'ethernet': NetworkType.ethernet,
    'vpn': NetworkType.vpn,
    'bluetooth': NetworkType.bluetooth,
    'none': NetworkType.none,
  };

  static NetworkType fromString(String value) {
    return _stringToNetworkTypeMap[value.toLowerCase()] ?? NetworkType.unknown;
  }
}

/// Represents the status of a network connection.
enum ConnectionStatus {
  /// Device is connected to a network
  connected,

  /// Device is disconnected from networks
  disconnected,

  /// Device is in the process of connecting
  connecting;

  static ConnectionStatus fromString(String value) {
    return ConnectionStatus.values.firstWhere((e) => e.name.toLowerCase() == value.toLowerCase(), orElse: () => ConnectionStatus.disconnected);
  }
}

/// Represents the security type of a Wi-Fi network.
enum WifiSecurity {
  /// Open network (no security)
  open,

  /// WEP security
  wep,

  /// WPA security
  wpa,

  /// WPA2 security
  wpa2,

  /// WPA3 security
  wpa3,

  /// WPA2/WPA3 mixed mode
  wpa2Wpa3,

  /// Unknown security type
  unknown;

  static WifiSecurity fromString(String value) {
    final lower = value.toLowerCase();
    if (lower.contains('wpa3')) return lower.contains('wpa2') ? WifiSecurity.wpa2Wpa3 : WifiSecurity.wpa3;
    if (lower.contains('wpa2')) return WifiSecurity.wpa2;
    if (lower.contains('wpa')) return WifiSecurity.wpa;
    if (lower.contains('wep')) return WifiSecurity.wep;
    if (lower.contains('open') || lower.contains('none')) return WifiSecurity.open;
    return WifiSecurity.unknown;
  }

  /// Returns a user-friendly display name
  String get displayName {
    if (this != WifiSecurity.unknown && this != WifiSecurity.open) {
      return name.toUpperCase();
    } else {
      if (this == WifiSecurity.open) {
        return 'Open';
      } else {
        return 'Unknown';
      }
    }
  }
}
