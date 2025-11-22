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

  static NetworkType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'wifi':
        return NetworkType.wifi;
      case 'mobile':
      case 'cellular':
        return NetworkType.mobile;
      case 'ethernet':
        return NetworkType.ethernet;
      case 'vpn':
        return NetworkType.vpn;
      case 'bluetooth':
        return NetworkType.bluetooth;
      case 'none':
        return NetworkType.none;
      default:
        return NetworkType.unknown;
    }
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
    switch (value.toLowerCase()) {
      case 'connected':
        return ConnectionStatus.connected;
      case 'disconnected':
        return ConnectionStatus.disconnected;
      case 'connecting':
        return ConnectionStatus.connecting;
      default:
        return ConnectionStatus.disconnected;
    }
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
    if (lower.contains('wpa3')) {
      if (lower.contains('wpa2')) {
        return WifiSecurity.wpa2Wpa3;
      }
      return WifiSecurity.wpa3;
    } else if (lower.contains('wpa2')) {
      return WifiSecurity.wpa2;
    } else if (lower.contains('wpa')) {
      return WifiSecurity.wpa;
    } else if (lower.contains('wep')) {
      return WifiSecurity.wep;
    } else if (lower.contains('open') || lower.contains('none')) {
      return WifiSecurity.open;
    }
    return WifiSecurity.unknown;
  }

  /// Returns a user-friendly display name
  String get displayName {
    switch (this) {
      case WifiSecurity.open:
        return 'Open';
      case WifiSecurity.wep:
        return 'WEP';
      case WifiSecurity.wpa:
        return 'WPA';
      case WifiSecurity.wpa2:
        return 'WPA2';
      case WifiSecurity.wpa3:
        return 'WPA3';
      case WifiSecurity.wpa2Wpa3:
        return 'WPA2/WPA3';
      case WifiSecurity.unknown:
        return 'Unknown';
    }
  }
}
