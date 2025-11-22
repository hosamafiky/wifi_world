import Flutter
import UIKit
import Network
import SystemConfiguration.CaptiveNetwork
import NetworkExtension

public class WifiWorldPlugin: NSObject, FlutterPlugin {
    private var pathMonitor: NWPathMonitor?
    private var monitorQueue: DispatchQueue?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "wifi_world", binaryMessenger: registrar.messenger())
        let instance = WifiWorldPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        // Setup event channels for streams
        let connectivityEventChannel = FlutterEventChannel(name: "wifi_world/connectivity", binaryMessenger: registrar.messenger())
        connectivityEventChannel.setStreamHandler(ConnectivityStreamHandler())
        
        let wifiEventChannel = FlutterEventChannel(name: "wifi_world/wifi", binaryMessenger: registrar.messenger())
        wifiEventChannel.setStreamHandler(WifiStreamHandler())
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getWifiInfo":
            getWifiInfo(result: result)
            
        case "getSSID":
            getSSID(result: result)
            
        case "getBSSID":
            getBSSID(result: result)
            
        case "getIPAddress":
            getIPAddress(result: result)
            
        case "getSignalStrength":
            // Signal strength is not available on iOS
            result(nil)
            
        case "getNetworkInfo":
            getNetworkInfo(result: result)
            
        case "isConnected":
            isConnected(result: result)
            
        case "isInternetAvailable":
            isInternetAvailable(result: result)
            
        case "scanNetworks":
            scanNetworks(result: result)
            
        case "connectToNetwork":
            connectToNetwork(call: call, result: result)
            
        case "disconnectFromNetwork":
            disconnectFromNetwork(result: result)
            
        case "enableWifi":
            // Opening Settings app - user must enable manually
            if let url = URL(string: "App-Prefs:root=WIFI") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                result(true)
            } else {
                result(false)
            }
            
        case "disableWifi":
            // Opening Settings app - user must disable manually
            if let url = URL(string: "App-Prefs:root=WIFI") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                result(true)
            } else {
                result(false)
            }
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - Wi-Fi Information
    
    private func getWifiInfo(result: @escaping FlutterResult) {
        guard let ssid = getCurrentSSID() else {
            result(nil)
            return
        }
        
        let bssid = getCurrentBSSID()
        let ipAddress = getIPAddress()
        
        let wifiInfo: [String: Any?] = [
            "ssid": ssid,
            "bssid": bssid,
            "ipAddress": ipAddress,
            "gateway": nil,
            "subnetMask": nil,
            "dnsServers": nil,
            "signalStrength": nil,
            "linkSpeed": nil,
            "frequency": nil,
            "networkId": nil,
            "isHidden": nil
        ]
        
        result(wifiInfo)
    }
    
    private func getSSID(result: @escaping FlutterResult) {
        result(getCurrentSSID())
    }
    
    private func getBSSID(result: @escaping FlutterResult) {
        result(getCurrentBSSID())
    }
    
    private func getIPAddress(result: @escaping FlutterResult) {
        result(getIPAddress())
    }
    
    // MARK: - Network Connectivity
    
    private func getNetworkInfo(result: @escaping FlutterResult) {
        if #available(iOS 12.0, *) {
            let monitor = NWPathMonitor()
            let queue = DispatchQueue(label: "NetworkMonitor")
            
            monitor.pathUpdateHandler = { path in
                let networkType = self.getNetworkType(from: path)
                let isConnected = path.status == .satisfied
                let hasInternet = path.status == .satisfied
                
                let networkInfo: [String: Any] = [
                    "networkType": networkType,
                    "connectionStatus": isConnected ? "connected" : "disconnected",
                    "isInternetAvailable": hasInternet,
                    "isMetered": path.isExpensive
                ]
                
                result(networkInfo)
                monitor.cancel()
            }
            
            monitor.start(queue: queue)
        } else {
            // Fallback for iOS < 12
            let isConnected = self.isDeviceConnected()
            let networkInfo: [String: Any] = [
                "networkType": isConnected ? "wifi" : "none",
                "connectionStatus": isConnected ? "connected" : "disconnected",
                "isInternetAvailable": isConnected,
                "isMetered": false
            ]
            result(networkInfo)
        }
    }
    
    private func isConnected(result: @escaping FlutterResult) {
        if #available(iOS 12.0, *) {
            let monitor = NWPathMonitor()
            let queue = DispatchQueue(label: "NetworkMonitor")
            
            monitor.pathUpdateHandler = { path in
                result(path.status == .satisfied)
                monitor.cancel()
            }
            
            monitor.start(queue: queue)
        } else {
            result(isDeviceConnected())
        }
    }
    
    private func isInternetAvailable(result: @escaping FlutterResult) {
        if #available(iOS 12.0, *) {
            let monitor = NWPathMonitor()
            let queue = DispatchQueue(label: "NetworkMonitor")
            
            monitor.pathUpdateHandler = { path in
                result(path.status == .satisfied)
                monitor.cancel()
            }
            
            monitor.start(queue: queue)
        } else {
            result(isDeviceConnected())
        }
    }
    
    // MARK: - Helper Methods
    
    private func getCurrentSSID() -> String? {
        if #available(iOS 14, *) {
            // On iOS 14+, this requires the Access WiFi Information entitlement
            // and specific app capabilities
            guard let interfaces = CNCopySupportedInterfaces() as? [String] else {
                return nil
            }
            
            for interface in interfaces {
                guard let info = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: Any],
                      let ssid = info[kCNNetworkInfoKeySSID as String] as? String else {
                    continue
                }
                return ssid
            }
            return nil
        } else {
            guard let interfaces = CNCopySupportedInterfaces() as? [String] else {
                return nil
            }
            
            for interface in interfaces {
                guard let info = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: Any],
                      let ssid = info[kCNNetworkInfoKeySSID as String] as? String else {
                    continue
                }
                return ssid
            }
            return nil
        }
    }
    
    private func getCurrentBSSID() -> String? {
        guard let interfaces = CNCopySupportedInterfaces() as? [String] else {
            return nil
        }
        
        for interface in interfaces {
            guard let info = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: Any],
                  let bssid = info[kCNNetworkInfoKeyBSSID as String] as? String else {
                continue
            }
            return bssid
        }
        return nil
    }
    
    private func getIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                
                let interface = ptr?.pointee
                let addrFamily = interface?.ifa_addr.pointee.sa_family
                
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    let name = String(cString: (interface?.ifa_name)!)
                    
                    if name == "en0" {  // Wi-Fi interface
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface?.ifa_addr, socklen_t((interface?.ifa_addr.pointee.sa_len)!),
                                  &hostname, socklen_t(hostname.count),
                                  nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        return address
    }
    
    @available(iOS 12.0, *)
    private func getNetworkType(from path: Network.NWPath) -> String {
        if path.usesInterfaceType(NWInterface.InterfaceType.wifi) {
            return "wifi"
        } else if path.usesInterfaceType(NWInterface.InterfaceType.cellular) {
            return "mobile"
        } else if path.usesInterfaceType(NWInterface.InterfaceType.wiredEthernet) {
            return "ethernet"
        } else if path.usesInterfaceType(NWInterface.InterfaceType.other) {
            return "other"
        } else {
            return "none"
        }
    }
    
    private func isDeviceConnected() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return isReachable && !needsConnection
    }
    
    // MARK: - Wi-Fi Operations
    
    @available(iOS 11.0, *)
    private func scanNetworks(result: @escaping FlutterResult) {
        // On iOS, we use NEHotspotHelper to scan for networks
        // This requires the "Hotspot Configuration" entitlement from Apple
        
        if #available(iOS 14.0, *) {
            NEHotspotNetwork.fetchCurrent { network in
                guard let network = network else {
                    result([])
                    return
                }
                
                // Build network info
                let networkDict: [String: Any] = [
                    "ssid": network.ssid,
                    "bssid": network.bssid,
                    "signalStrength": network.signalStrength,
                    "frequency": NSNull(),
                    "security": self.getSecurityType(from: network),
                    "isSaved": false
                ]
                
                result([networkDict])
            }
        } else {
            // For iOS < 14, we can only return the current network
            if let ssid = getCurrentSSID(), let bssid = getCurrentBSSID() {
                let networkDict: [String: Any] = [
                    "ssid": ssid,
                    "bssid": bssid,
                    "signalStrength": NSNull(),
                    "frequency": NSNull(),
                    "security": "unknown",
                    "isSaved": false
                ]
                result([networkDict])
            } else {
                result([])
            }
        }
    }
    
    @available(iOS 11.0, *)
    private func connectToNetwork(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let ssid = args["ssid"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT",
                              message: "SSID is required",
                              details: nil))
            return
        }
        
        let password = args["password"] as? String
        let isOpen = password == nil || password?.isEmpty == true
        
        let configuration: NEHotspotConfiguration
        
        if isOpen {
            configuration = NEHotspotConfiguration(ssid: ssid)
        } else {
            configuration = NEHotspotConfiguration(ssid: ssid, passphrase: password!, isWEP: false)
        }
        
        configuration.joinOnce = false
        
        NEHotspotConfigurationManager.shared.apply(configuration) { error in
            if let error = error {
                if (error as NSError).code == 13 {
                    // User cancelled
                    result(false)
                } else {
                    result(FlutterError(code: "CONNECTION_FAILED",
                                      message: error.localizedDescription,
                                      details: nil))
                }
            } else {
                result(true)
            }
        }
    }
    
    @available(iOS 11.0, *)
    private func disconnectFromNetwork(result: @escaping FlutterResult) {
        guard let ssid = getCurrentSSID() else {
            result(false)
            return
        }
        
        NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: ssid)
        result(true)
    }
    
    @available(iOS 14.0, *)
    private func getSecurityType(from network: NEHotspotNetwork) -> String {
        // NEHotspotNetwork doesn't expose security type directly
        // We return "unknown" as a safe default
        return "unknown"
    }
}


// MARK: - Event Stream Handlers

@available(iOS 12.0, *)
class ConnectivityStreamHandler: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var pathMonitor: NWPathMonitor?
    private var monitorQueue: DispatchQueue?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        
        pathMonitor = NWPathMonitor()
        monitorQueue = DispatchQueue(label: "ConnectivityMonitor")
        
        pathMonitor?.pathUpdateHandler = { [weak self] path in
            self?.sendConnectivityUpdate(path: path)
        }
        
        pathMonitor?.start(queue: monitorQueue!)
        
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        pathMonitor?.cancel()
        pathMonitor = nil
        monitorQueue = nil
        eventSink = nil
        return nil
    }
    
    private func sendConnectivityUpdate(path: Network.NWPath) {
        let networkType: String
        if path.usesInterfaceType(NWInterface.InterfaceType.wifi) {
            networkType = "wifi"
        } else if path.usesInterfaceType(NWInterface.InterfaceType.cellular) {
            networkType = "mobile"
        } else if path.usesInterfaceType(NWInterface.InterfaceType.wiredEthernet) {
            networkType = "ethernet"
        } else {
            networkType = "none"
        }
        
        let isConnected = path.status == .satisfied
        
        let networkInfo: [String: Any] = [
            "networkType": networkType,
            "connectionStatus": isConnected ? "connected" : "disconnected",
            "isInternetAvailable": isConnected,
            "isMetered": path.isExpensive
        ]
        
        eventSink?(networkInfo)
    }
}

@available(iOS 12.0, *)
class WifiStreamHandler: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var pathMonitor: NWPathMonitor?
    private var monitorQueue: DispatchQueue?
    private var timer: Timer?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        
        // Monitor Wi-Fi changes
        pathMonitor = NWPathMonitor(requiredInterfaceType: .wifi)
        monitorQueue = DispatchQueue(label: "WifiMonitor")
        
        pathMonitor?.pathUpdateHandler = { [weak self] path in
            if path.status == .satisfied {
                self?.sendWifiUpdate()
            } else {
                self?.eventSink?(nil)
            }
        }
        
        pathMonitor?.start(queue: monitorQueue!)
        
        // Also poll for Wi-Fi info changes every 5 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.sendWifiUpdate()
        }
        
        // Send initial state
        sendWifiUpdate()
        
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        timer?.invalidate()
        timer = nil
        pathMonitor?.cancel()
        pathMonitor = nil
        monitorQueue = nil
        eventSink = nil
        return nil
    }
    
    private func sendWifiUpdate() {
        guard let ssid = getCurrentSSID() else {
            eventSink?(nil)
            return
        }
        
        let bssid = getCurrentBSSID()
        let ipAddress = getIPAddress()
        
        let wifiInfo: [String: Any?] = [
            "ssid": ssid,
            "bssid": bssid,
            "ipAddress": ipAddress,
            "signalStrength": nil, // Not available on iOS
            "linkSpeed": nil,  // Not available on iOS
            "frequency": nil,  // Not available on iOS
            "networkId": nil,
            "isHidden": nil
        ]
        
        eventSink?(wifiInfo)
    }
    
    private func getCurrentSSID() -> String? {
        guard let interfaces = CNCopySupportedInterfaces() as? [String] else {
            return nil
        }
        
        for interface in interfaces {
            guard let info = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: Any],
                  let ssid = info[kCNNetworkInfoKeySSID as String] as? String else {
                continue
            }
            return ssid
        }
        return nil
    }
    
    private func getCurrentBSSID() -> String? {
        guard let interfaces = CNCopySupportedInterfaces() as? [String] else {
            return nil
        }
        
        for interface in interfaces {
            guard let info = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: Any],
                  let bssid = info[kCNNetworkInfoKeyBSSID as String] as? String else {
                continue
            }
            return bssid
        }
        return nil
    }
    
    private func getIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                
                let interface = ptr?.pointee
                let addrFamily = interface?.ifa_addr.pointee.sa_family
                
                if addrFamily == UInt8(AF_INET) {
                    let name = String(cString: (interface?.ifa_name)!)
                    
                    if name == "en0" {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface?.ifa_addr, socklen_t((interface?.ifa_addr.pointee.sa_len)!),
                                  &hostname, socklen_t(hostname.count),
                                  nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        return address
    }
}

