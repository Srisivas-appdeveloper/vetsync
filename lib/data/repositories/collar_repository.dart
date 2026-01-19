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
    try {
      print('[CollarRepo] 📡 Getting all collars for clinic');
      final response = await _api.get(ApiEndpoints.collars);

      final collars = (response.data['collars'] as List)
          .map((json) => Collar.fromJson(json as Map<String, dynamic>))
          .toList();

      print('[CollarRepo] ✅ Retrieved ${collars.length} collars');
      return collars;
    } catch (e, stackTrace) {
      print('[CollarRepo] ❌ ERROR getting collars: $e');
      print('[CollarRepo] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get available collars (not in use)
  Future<List<Collar>> getAvailableCollars() async {
    try {
      print('[CollarRepo] 📡 Getting available collars');
      final response = await _api.get(
        ApiEndpoints.collars,
        queryParameters: {'status': 'available'},
      );

      final collars = (response.data['collars'] as List)
          .map((json) => Collar.fromJson(json as Map<String, dynamic>))
          .toList();

      print('[CollarRepo] ✅ Retrieved ${collars.length} available collars');
      return collars;
    } catch (e, stackTrace) {
      print('[CollarRepo] ❌ ERROR getting available collars: $e');
      print('[CollarRepo] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get collar by ID
  Future<Collar> getCollar(String id) async {
    try {
      print('[CollarRepo] 📡 Getting collar: $id');
      final response = await _api.get(ApiEndpoints.collar(id));

      // Extract collar data from nested 'data' field if present
      final collarData = response.data is Map<String, dynamic> && response.data.containsKey('data')
          ? response.data['data'] as Map<String, dynamic>
          : response.data as Map<String, dynamic>;

      final collar = Collar.fromJson(collarData);
      print('[CollarRepo] ✅ Retrieved collar: ${collar.serialNumber} (ID: ${collar.id})');
      return collar;
    } catch (e, stackTrace) {
      print('[CollarRepo] ❌ ERROR getting collar $id: $e');
      print('[CollarRepo] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get collar status
  Future<Map<String, dynamic>> getCollarStatus(String id) async {
    try {
      print('[CollarRepo] 📡 Getting collar status: $id');
      final response = await _api.get(ApiEndpoints.collarStatus(id));

      final status = response.data as Map<String, dynamic>;
      print('[CollarRepo] ✅ Retrieved collar status: $status');
      return status;
    } catch (e, stackTrace) {
      print('[CollarRepo] ❌ ERROR getting collar status $id: $e');
      print('[CollarRepo] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Register collar usage for session
  Future<void> registerCollarForSession({
    required String collarId,
    required String sessionId,
  }) async {
    try {
      print('[CollarRepo] 📡 Registering collar for session');
      print('[CollarRepo] Collar ID: $collarId');
      print('[CollarRepo] Session ID: $sessionId');

      await _api.post(
        ApiEndpoints.collar(collarId),
        data: {'current_session_id': sessionId, 'status': 'in_use'},
      );

      print('[CollarRepo] ✅ Collar registered for session');
    } catch (e, stackTrace) {
      print('[CollarRepo] ❌ ERROR registering collar: $e');
      print('[CollarRepo] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Release collar from session
  Future<void> releaseCollar(String collarId) async {
    try {
      print('[CollarRepo] 📡 Releasing collar: $collarId');

      await _api.patch(
        ApiEndpoints.collar(collarId),
        data: {
          'current_session_id': null,
          'status': 'available',
          'last_seen_at': DateTime.now().toIso8601String(),
        },
      );

      print('[CollarRepo] ✅ Collar released');
    } catch (e, stackTrace) {
      print('[CollarRepo] ❌ ERROR releasing collar $collarId: $e');
      print('[CollarRepo] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Update collar battery level
  Future<void> updateBatteryLevel(String collarId, int batteryPercent) async {
    try {
      print(
        '[CollarRepo] 📡 Updating collar battery: $collarId -> $batteryPercent%',
      );

      await _api.patch(
        ApiEndpoints.collar(collarId),
        data: {
          'battery_percent': batteryPercent,
          'last_seen_at': DateTime.now().toIso8601String(),
        },
      );

      print('[CollarRepo] ✅ Battery level updated');
    } catch (e, stackTrace) {
      print('[CollarRepo] ❌ ERROR updating battery for collar $collarId: $e');
      print('[CollarRepo] Stack trace: $stackTrace');
      rethrow;
    }
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
  bool get isConnected => _ble.isConnected.value;

  /// Get remaining reconnect attempts
  int get remainingReconnectAttempts => _ble.remainingReconnectAttempts;

  /// Cancel reconnection
  void cancelReconnect() => _ble.cancelReconnect();
}
