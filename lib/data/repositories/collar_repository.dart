import 'package:get/get.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import '../services/ble_service.dart';
import '../../core/constants/app_config.dart';

/// Collar repository
class CollarRepository {
  final ApiService _api = Get.find<ApiService>();
  final BleService _ble = Get.find<BleService>();

  /// Get all collars for clinic
  Future<List<Collar>> getCollars() async {
    final response = await _api.get(ApiEndpoints.collars);
    return (response.data['collars'] as List)
        .map((json) => Collar.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get available collars (not in use)
  Future<List<Collar>> getAvailableCollars() async {
    final response = await _api.get(
      ApiEndpoints.collars,
      queryParameters: {'status': 'available'},
    );
    return (response.data['collars'] as List)
        .map((json) => Collar.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get collar by ID
  Future<Collar> getCollar(String id) async {
    final response = await _api.get(ApiEndpoints.collar(id));
    return Collar.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get collar status
  Future<Map<String, dynamic>> getCollarStatus(String id) async {
    final response = await _api.get(ApiEndpoints.collarStatus(id));
    return response.data as Map<String, dynamic>;
  }

  /// Register collar usage for session
  Future<void> registerCollarForSession({
    required String collarId,
    required String sessionId,
  }) async {
    await _api.post(
      ApiEndpoints.collar(collarId),
      data: {'current_session_id': sessionId, 'status': 'in_use'},
    );
  }

  /// Release collar from session
  Future<void> releaseCollar(String collarId) async {
    await _api.patch(
      ApiEndpoints.collar(collarId),
      data: {
        'current_session_id': null,
        'status': 'available',
        'last_seen_at': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Update collar battery level
  Future<void> updateBatteryLevel(String collarId, int batteryPercent) async {
    await _api.patch(
      ApiEndpoints.collar(collarId),
      data: {
        'battery_percent': batteryPercent,
        'last_seen_at': DateTime.now().toIso8601String(),
      },
    );
  }

  // ============================================================
  // BLE Operations (delegated to BLE service)
  // ============================================================

  /// Start BLE scan for collars
  Future<void> startScan() async {
    await _ble.startScan();
  }

  /// Stop BLE scan
  Future<void> stopScan() async {
    await _ble.stopScan();
  }

  /// Get discovered collars
  List<DiscoveredCollar> get discoveredCollars => _ble.discoveredCollars;

  /// Connect to collar
  Future<void> connect(DiscoveredCollar collar) async {
    await _ble.connect(collar);
  }

  /// Disconnect from collar
  Future<void> disconnect() async {
    await _ble.disconnect();
  }

  /// Get BLE connection state
  BleConnectionState get connectionState => _ble.connectionState.value;

  /// Get connected collar
  DiscoveredCollar? get connectedCollar => _ble.connectedCollar.value;

  /// Get connected collar ID
  String? get connectedCollarId => _ble.connectedCollarId;

  /// Get current battery percent
  int get batteryPercent => _ble.batteryPercent.value;

  /// Get current signal quality
  int get signalQuality => _ble.signalQuality.value;

  /// Get current firmware mode
  FirmwareMode get currentMode => _ble.currentMode.value;

  /// Switch firmware mode
  Future<void> switchMode(FirmwareMode mode, {int sessionId = 0}) async {
    await _ble.switchMode(mode, sessionId: sessionId);
  }

  /// Get data stream
  Stream<CollarDataPacket> get dataStream => _ble.dataStream;

  /// Check if connected
  bool get isConnected => _ble.isConnected;

  /// Get remaining reconnect attempts
  int get remainingReconnectAttempts => _ble.remainingReconnectAttempts;

  /// Cancel reconnection
  void cancelReconnect() => _ble.cancelReconnect();
}
