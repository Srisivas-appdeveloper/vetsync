import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

/// Service to monitor network connectivity
class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();

  /// Current connectivity status
  final Rx<ConnectivityResult> connectivityResult = ConnectivityResult.none.obs;

  /// Whether the device is online
  final RxBool isOnline = false.obs;

  /// Stream subscription
  StreamSubscription<ConnectivityResult>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    // Get initial status
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);

    // Listen for changes - onConnectivityChanged returns Stream<ConnectivityResult>
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(ConnectivityResult result) {
    connectivityResult.value = result;

    // Update online status
    isOnline.value = result != ConnectivityResult.none;
  }

  /// Check if connected via WiFi
  bool get isWifi => connectivityResult.value == ConnectivityResult.wifi;

  /// Check if connected via mobile data
  bool get isMobile => connectivityResult.value == ConnectivityResult.mobile;

  /// Check if connected via ethernet
  bool get isEthernet =>
      connectivityResult.value == ConnectivityResult.ethernet;

  /// Force check connectivity
  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);
    return isOnline.value;
  }

  /// Get connectivity status string
  String get statusString {
    switch (connectivityResult.value) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.other:
        return 'Other';
      case ConnectivityResult.none:
        return 'Offline';
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
