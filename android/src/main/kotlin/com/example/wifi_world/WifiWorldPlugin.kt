package com.example.wifi_world

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.net.wifi.ScanResult
import android.net.wifi.WifiConfiguration
import android.net.wifi.WifiInfo
import android.net.wifi.WifiManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.net.Inet4Address
import java.net.NetworkInterface

/** WifiWorldPlugin */
class WifiWorldPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var connectivityEventChannel: EventChannel
    private lateinit var wifiEventChannel: EventChannel

    private var context: Context? = null
    private var wifiManager: WifiManager? = null
    private var connectivityManager: ConnectivityManager? = null

    private var connectivityStreamHandler: ConnectivityStreamHandler? = null
    private var wifiStreamHandler: WifiStreamHandler? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        wifiManager = context?.getSystemService(Context.WIFI_SERVICE) as? WifiManager
        connectivityManager =
            context?.getSystemService(Context.CONNECTIVITY_SERVICE) as? ConnectivityManager

        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "wifi_world")
        channel.setMethodCallHandler(this)

        // Setup event channels for streams
        connectivityEventChannel =
            EventChannel(flutterPluginBinding.binaryMessenger, "wifi_world/connectivity")
        connectivityStreamHandler = ConnectivityStreamHandler(context)
        connectivityEventChannel.setStreamHandler(connectivityStreamHandler)

        wifiEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "wifi_world/wifi")
        wifiStreamHandler = WifiStreamHandler(context)
        wifiEventChannel.setStreamHandler(wifiStreamHandler)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        when (call.method) {
            "getWifiInfo" -> {
                getWifiInfo(result)
            }

            "getSSID" -> {
                getSSID(result)
            }

            "getBSSID" -> {
                getBSSID(result)
            }

            "getIPAddress" -> {
                getIPAddress(result)
            }

            "getSignalStrength" -> {
                getSignalStrength(result)
            }

            "getNetworkInfo" -> {
                getNetworkInfo(result)
            }

            "isConnected" -> {
                isConnected(result)
            }

            "isInternetAvailable" -> {
                isInternetAvailable(result)
            }

            "scanNetworks" -> {
                scanNetworks(result)
            }

            "connectToNetwork" -> {
                val ssid = call.argument<String>("ssid")
                val password = call.argument<String?>("password")
                val isHidden = call.argument<Boolean>("isHidden") ?: false
                connectToNetwork(ssid, password, isHidden, result)
            }

            "disconnectFromNetwork" -> {
                disconnectFromNetwork(result)
            }

            "enableWifi" -> {
                enableWifi(result)
            }

            "disableWifi" -> {
                disableWifi(result)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    // ==================== Wi-Fi Information ====================

    private fun getWifiInfo(result: Result) {
        if (!hasLocationPermission()) {
            result.error(
                "PERMISSION_DENIED",
                "Location permission is required to access Wi-Fi information",
                null
            )
            return
        }

        @Suppress("DEPRECATION")
        val wifiInfo = wifiManager?.connectionInfo
        if (wifiInfo == null) {
            result.success(null)
            return
        }

        val data =
            mapOf(
                "ssid" to wifiInfo.ssid?.replace("\"", ""),
                "bssid" to wifiInfo.bssid,
                "ipAddress" to formatIpAddress(wifiInfo.ipAddress),
                "gateway" to getGatewayAddress(),
                "subnetMask" to getSubnetMask(),
                "dnsServers" to getDnsServers(),
                "signalStrength" to wifiInfo.rssi,
                "linkSpeed" to wifiInfo.linkSpeed,
                "frequency" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    wifiInfo.frequency
                } else {
                    null
                },
                "networkId" to wifiInfo.networkId,
                "isHidden" to wifiInfo.hiddenSSID
            )

        result.success(data)
    }

    private fun getSSID(result: Result) {
        if (!hasLocationPermission()) {
            result.error(
                "PERMISSION_DENIED",
                "Location permission is required to access SSID",
                null
            )
            return
        }

        @Suppress("DEPRECATION")
        val ssid = wifiManager?.connectionInfo?.ssid?.replace("\"", "")
        result.success(if (ssid == "<unknown ssid>") null else ssid)
    }

    private fun getBSSID(result: Result) {
        if (!hasLocationPermission()) {
            result.error(
                "PERMISSION_DENIED",
                "Location permission is required to access BSSID",
                null
            )
            return
        }

        @Suppress("DEPRECATION")
        result.success(wifiManager?.connectionInfo?.bssid)
    }

    private fun getIPAddress(result: Result) {
        @Suppress("DEPRECATION")
        val ipAddress = wifiManager?.connectionInfo?.ipAddress
        result.success(ipAddress?.let { formatIpAddress(it) })
    }

    private fun getSignalStrength(result: Result) {
        if (!hasLocationPermission()) {
            result.error(
                "PERMISSION_DENIED",
                "Location permission is required to access signal strength",
                null
            )
            return
        }

        @Suppress("DEPRECATION")
        result.success(wifiManager?.connectionInfo?.rssi)
    }

    // ==================== Network Connectivity ====================

    private fun getNetworkInfo(result: Result) {
        val connectivityManager = this.connectivityManager
        if (connectivityManager == null) {
            result.success(
                mapOf(
                    "networkType" to "none",
                    "connectionStatus" to "disconnected",
                    "isInternetAvailable" to false,
                    "isMetered" to false
                )
            )
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val network = connectivityManager.activeNetwork
            val capabilities = connectivityManager.getNetworkCapabilities(network)

            val networkType = when {
                capabilities?.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) == true -> "wifi"
                capabilities?.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) == true -> "mobile"
                capabilities?.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET) == true -> "ethernet"
                capabilities?.hasTransport(NetworkCapabilities.TRANSPORT_VPN) == true -> "vpn"
                capabilities?.hasTransport(NetworkCapabilities.TRANSPORT_BLUETOOTH) == true -> "bluetooth"
                else -> "none"
            }

            val isConnected = network != null && capabilities != null
            val hasInternet =
                capabilities?.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) == true &&
                    capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED) == true
            val isMetered = !(capabilities?.hasCapability(NetworkCapabilities.NET_CAPABILITY_NOT_METERED) ?: false)

            result.success(
                mapOf(
                    "networkType" to networkType,
                    "connectionStatus" to if (isConnected) "connected" else "disconnected",
                    "isInternetAvailable" to hasInternet,
                    "isMetered" to isMetered
                )
            )
        } else {
            @Suppress("DEPRECATION")
            val activeNetwork = connectivityManager.activeNetworkInfo

            val networkType = when (activeNetwork?.type) {
                ConnectivityManager.TYPE_WIFI -> "wifi"
                ConnectivityManager.TYPE_MOBILE -> "mobile"
                ConnectivityManager.TYPE_ETHERNET -> "ethernet"
                ConnectivityManager.TYPE_VPN -> "vpn"
                ConnectivityManager.TYPE_BLUETOOTH -> "bluetooth"
                else -> "none"
            }

            val isConnected = activeNetwork?.isConnected == true
            result.success(
                mapOf(
                    "networkType" to networkType,
                    "connectionStatus" to if (isConnected) "connected" else "disconnected",
                    "isInternetAvailable" to isConnected,
                    "isMetered" to connectivityManager.isActiveNetworkMetered
                )
            )
        }
    }

    private fun isConnected(result: Result) {
        val connectivityManager = this.connectivityManager
        if (connectivityManager == null) {
            result.success(false)
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val network = connectivityManager.activeNetwork
            val capabilities = connectivityManager.getNetworkCapabilities(network)
            result.success(network != null && capabilities != null)
        } else {
            @Suppress("DEPRECATION")
            result.success(connectivityManager.activeNetworkInfo?.isConnected == true)
        }
    }

    private fun isInternetAvailable(result: Result) {
        val connectivityManager = this.connectivityManager
        if (connectivityManager == null) {
            result.success(false)
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val network = connectivityManager.activeNetwork
            val capabilities = connectivityManager.getNetworkCapabilities(network)
            val hasInternet =
                capabilities?.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) == true &&
                    capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED) == true
            result.success(hasInternet)
        } else {
            @Suppress("DEPRECATION")
            result.success(connectivityManager.activeNetworkInfo?.isConnected == true)
        }
    }

    // ==================== Wi-Fi Operations ====================

    private fun scanNetworks(result: Result) {
        if (!hasLocationPermission()) {
            result.error(
                "PERMISSION_DENIED",
                "Location permission is required to scan networks",
                null
            )
            return
        }

        @Suppress("DEPRECATION")
        val scanResults = wifiManager?.scanResults
        if (scanResults == null) {
            result.success(emptyList<Map<String, Any>>())
            return
        }

        val networks = scanResults.map { scanResult ->
            mapOf(
                "ssid" to scanResult.SSID,
                "bssid" to scanResult.BSSID,
                "signalStrength" to scanResult.level,
                "frequency" to scanResult.frequency,
                "security" to getSecurityType(scanResult),
                "channel" to frequencyToChannel(scanResult.frequency)
            )
        }

        result.success(networks)
    }

    private fun connectToNetwork(
        ssid: String?,
        password: String?,
        isHidden: Boolean,
        result: Result
    ) {
        if (ssid == null) {
            result.error("INVALID_ARGUMENT", "SSID is required", null)
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // On Android 10+, we can't programmatically connect
            // Open Wi-Fi settings instead
            result.error(
                "UNSUPPORTED",
                "Programmatic Wi-Fi connection is not supported on Android 10+. " +
                    "Please use system Wi-Fi settings.",
                null
            )
            return
        }

        @Suppress("DEPRECATION")
        val wifiConfig = WifiConfiguration().apply {
            SSID = "\"$ssid\""
            hiddenSSID = isHidden

            if (password.isNullOrEmpty()) {
                // Open network
                allowedKeyManagement.set(WifiConfiguration.KeyMgmt.NONE)
            } else {
                // WPA/WPA2 network
                preSharedKey = "\"$password\""
            }
        }

        @Suppress("DEPRECATION")
        val networkId = wifiManager?.addNetwork(wifiConfig)
        if (networkId == null || networkId == -1) {
            result.success(false)
            return
        }

        @Suppress("DEPRECATION")
        wifiManager?.disconnect()
        @Suppress("DEPRECATION")
        val success = wifiManager?.enableNetwork(networkId, true) == true
        @Suppress("DEPRECATION")
        wifiManager?.reconnect()

        result.success(success)
    }

    private fun disconnectFromNetwork(result: Result) {
        @Suppress("DEPRECATION")
        val success = wifiManager?.disconnect() == true
        result.success(success)
    }

    private fun enableWifi(result: Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // On Android 10+, opening Wi-Fi settings
            try {
                val intent = Intent(Settings.Panel.ACTION_WIFI)
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                context?.startActivity(intent)
                result.success(true)
            } catch (e: Exception) {
                result.error("ERROR", e.message, null)
            }
            return
        }

        @Suppress("DEPRECATION")
        val success = wifiManager?.setWifiEnabled(true) == true
        result.success(success)
    }

    private fun disableWifi(result: Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // On Android 10+, opening Wi-Fi settings
            try {
                val intent = Intent(Settings.Panel.ACTION_WIFI)
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                context?.startActivity(intent)
                result.success(true)
            } catch (e: Exception) {
                result.error("ERROR", e.message, null)
            }
            return
        }

        @Suppress("DEPRECATION")
        val success = wifiManager?.setWifiEnabled(false) == true
        result.success(success)
    }

    // ==================== Helper Methods ====================

    private fun hasLocationPermission(): Boolean {
        return context?.let {
            ContextCompat.checkSelfPermission(
                it,
                Manifest.permission.ACCESS_FINE_LOCATION
            ) == PackageManager.PERMISSION_GRANTED
        } ?: false
    }

    private fun formatIpAddress(ip: Int): String {
        return String.format(
            "%d.%d.%d.%d",
            ip and 0xff,
            ip shr 8 and 0xff,
            ip shr 16 and 0xff,
            ip shr 24 and 0xff
        )
    }

    private fun getGatewayAddress(): String? {
        @Suppress("DEPRECATION")
        val dhcpInfo = wifiManager?.dhcpInfo ?: return null
        return formatIpAddress(dhcpInfo.gateway)
    }

    private fun getSubnetMask(): String? {
        @Suppress("DEPRECATION")
        val dhcpInfo = wifiManager?.dhcpInfo ?: return null
        return formatIpAddress(dhcpInfo.netmask)
    }

    private fun getDnsServers(): List<String> {
        @Suppress("DEPRECATION")
        val dhcpInfo = wifiManager?.dhcpInfo ?: return emptyList()
        val dnsServers = mutableListOf<String>()

        if (dhcpInfo.dns1 != 0) {
            dnsServers.add(formatIpAddress(dhcpInfo.dns1))
        }
        if (dhcpInfo.dns2 != 0) {
            dnsServers.add(formatIpAddress(dhcpInfo.dns2))
        }

        return dnsServers
    }

    private fun getSecurityType(scanResult: ScanResult): String {
        val capabilities = scanResult.capabilities
        return when {
            capabilities.contains("WPA3") -> "wpa3"
            capabilities.contains("WPA2") -> "wpa2"
            capabilities.contains("WPA") -> "wpa"
            capabilities.contains("WEP") -> "wep"
            else -> "open"
        }
    }

    private fun frequencyToChannel(frequency: Int): Int {
        return when {
            frequency in 2412..2484 -> (frequency - 2412) / 5 + 1
            frequency in 5170..5825 -> (frequency - 5170) / 5 + 34
            else -> -1
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        connectivityEventChannel.setStreamHandler(null)
        wifiEventChannel.setStreamHandler(null)
        connectivityStreamHandler?.cleanup()
        wifiStreamHandler?.cleanup()
    }

    // ==================== Event Stream Handlers ====================

    class ConnectivityStreamHandler(private val context: Context?) : EventChannel.StreamHandler {
        private var eventSink: EventChannel.EventSink? = null
        private var connectivityManager: ConnectivityManager? = null
        private var networkCallback: ConnectivityManager.NetworkCallback? = null
        private var broadcastReceiver: BroadcastReceiver? = null
        private val mainHandler = Handler(Looper.getMainLooper())

        override fun onListen(
            arguments: Any?,
            events: EventChannel.EventSink?
        ) {
            eventSink = events
            connectivityManager =
                context?.getSystemService(Context.CONNECTIVITY_SERVICE) as? ConnectivityManager

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                // Use NetworkCallback for Android 7.0+
                networkCallback =
                    object : ConnectivityManager.NetworkCallback() {
                        override fun onAvailable(network: Network) {
                            sendConnectivityUpdate()
                        }

                        override fun onLost(network: Network) {
                            sendConnectivityUpdate()
                        }

                        override fun onCapabilitiesChanged(
                            network: Network,
                            networkCapabilities: NetworkCapabilities
                        ) {
                            sendConnectivityUpdate()
                        }
                    }

                connectivityManager?.registerDefaultNetworkCallback(
                    networkCallback as ConnectivityManager.NetworkCallback
                )
            } else {
                // Use BroadcastReceiver for older versions
                broadcastReceiver =
                    object : BroadcastReceiver() {
                        override fun onReceive(
                            context: Context?,
                            intent: Intent?
                        ) {
                            sendConnectivityUpdate()
                        }
                    }

                val filter = IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION)
                context?.registerReceiver(broadcastReceiver, filter)
            }

            // Send initial state
            sendConnectivityUpdate()
        }

        private fun sendConnectivityUpdate() {
            val connectivityManager = this.connectivityManager ?: return

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val network = connectivityManager.activeNetwork
                val capabilities = connectivityManager.getNetworkCapabilities(network)

                val networkType = when {
                    capabilities?.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) == true -> "wifi"
                    capabilities?.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) == true -> "mobile"
                    capabilities?.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET) == true -> "ethernet"
                    capabilities?.hasTransport(NetworkCapabilities.TRANSPORT_VPN) == true -> "vpn"
                    capabilities?.hasTransport(NetworkCapabilities.TRANSPORT_BLUETOOTH) == true -> "bluetooth"
                    else -> "none"
                }

                val isConnected = network != null && capabilities != null
                val hasInternet =
                    capabilities?.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) == true &&
                        capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED) == true
                val isMetered =
                    !(capabilities?.hasCapability(NetworkCapabilities.NET_CAPABILITY_NOT_METERED) ?: false)

                mainHandler.post {
                    eventSink?.success(
                        mapOf(
                            "networkType" to networkType,
                            "connectionStatus" to if (isConnected) "connected" else "disconnected",
                            "isInternetAvailable" to hasInternet,
                            "isMetered" to isMetered
                        )
                    )
                }
            } else {
                @Suppress("DEPRECATION")
                val activeNetwork = connectivityManager.activeNetworkInfo

                val networkType = when (activeNetwork?.type) {
                    ConnectivityManager.TYPE_WIFI -> "wifi"
                    ConnectivityManager.TYPE_MOBILE -> "mobile"
                    ConnectivityManager.TYPE_ETHERNET -> "ethernet"
                    ConnectivityManager.TYPE_VPN -> "vpn"
                    ConnectivityManager.TYPE_BLUETOOTH -> "bluetooth"
                    else -> "none"
                }

                val isConnected = activeNetwork?.isConnected == true
                mainHandler.post {
                    eventSink?.success(
                        mapOf(
                            "networkType" to networkType,
                            "connectionStatus" to if (isConnected) "connected" else "disconnected",
                            "isInternetAvailable" to isConnected,
                            "isMetered" to connectivityManager.isActiveNetworkMetered
                        )
                    )
                }
            }
        }

        override fun onCancel(arguments: Any?) {
            cleanup()
        }

        fun cleanup() {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                networkCallback?.let { connectivityManager?.unregisterNetworkCallback(it) }
            } else {
                broadcastReceiver?.let { context?.unregisterReceiver(it) }
            }
            eventSink = null
        }
    }

    class WifiStreamHandler(private val context: Context?) : EventChannel.StreamHandler {
        private var eventSink: EventChannel.EventSink? = null
        private var wifiManager: WifiManager? = null
        private var broadcastReceiver: BroadcastReceiver? = null
        private val mainHandler = Handler(Looper.getMainLooper())

        override fun onListen(
            arguments: Any?,
            events: EventChannel.EventSink?
        ) {
            eventSink = events
            wifiManager = context?.getSystemService(Context.WIFI_SERVICE) as? WifiManager

            broadcastReceiver =
                object : BroadcastReceiver() {
                    override fun onReceive(
                        context: Context?,
                        intent: Intent?
                    ) {
                        sendWifiUpdate()
                    }
                }

            val filter =
                IntentFilter().apply {
                    addAction(WifiManager.NETWORK_STATE_CHANGED_ACTION)
                    addAction(WifiManager.RSSI_CHANGED_ACTION)
                    addAction(WifiManager.WIFI_STATE_CHANGED_ACTION)
                }

            context?.registerReceiver(broadcastReceiver, filter)

            // Send initial state
            sendWifiUpdate()
        }

        private fun sendWifiUpdate() {
            @Suppress("DEPRECATION")
            val wifiInfo = wifiManager?.connectionInfo

            if (wifiInfo == null || wifiInfo.networkId == -1) {
                mainHandler.post {
                    eventSink?.success(null)
                }
                return
            }

            mainHandler.post {
                eventSink?.success(
                    mapOf(
                        "ssid" to wifiInfo.ssid?.replace("\"", ""),
                        "bssid" to wifiInfo.bssid,
                        "ipAddress" to formatIpAddress(wifiInfo.ipAddress),
                        "signalStrength" to wifiInfo.rssi,
                        "linkSpeed" to wifiInfo.linkSpeed,
                        "frequency" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                            wifiInfo.frequency
                        } else {
                            null
                        },
                        "networkId" to wifiInfo.networkId,
                        "isHidden" to wifiInfo.hiddenSSID
                    )
                )
            }
        }

        private fun formatIpAddress(ip: Int): String {
            return String.format(
                "%d.%d.%d.%d",
                ip and 0xff,
                ip shr 8 and 0xff,
                ip shr 16 and 0xff,
                ip shr 24 and 0xff
            )
        }

        override fun onCancel(arguments: Any?) {
            cleanup()
        }

        fun cleanup() {
            broadcastReceiver?.let { context?.unregisterReceiver(it) }
            eventSink = null
        }
    }
}
