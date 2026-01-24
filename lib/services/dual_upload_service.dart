import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:msgpack_dart/msgpack_dart.dart';

import '../data/models/models.dart';
import '../data/services/api_service.dart';
import '../database/sqlite_service.dart';

/// Dual Upload Service
/// Handles two parallel upload streams:
/// 1. Batch Vitals Upload → PostgreSQL (derived HR, RR, Temp, Quality)
/// 2. Raw Collar Data Upload → S3 (MessagePack: pressure_raw, IMU, timestamps)
class DualUploadService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  final SQLiteService _db = Get.find<SQLiteService>();

  // Session state
  String? _sessionId;
  String _currentPhase = 'monitoring'; // baseline, pre_surgery, surgery, recovery, monitoring
  String _currentMode = 'raw'; // filtered, raw

  // Raw data buffers (MessagePack)
  final List<Map<String, dynamic>> _rawDataBuffer = [];
  static const int _rawDataBatchSize = 100; // 100 packets per batch (~1 second at 100Hz)
  static const int _rawDataMaxBufferSize = 1000; // Max 10 seconds of data

  // Vitals buffers (JSON)
  final List<Vitals> _vitalsBuffer = [];
  static const int _vitalsBatchSize = 10; // 10 vitals records per batch
  static const int _vitalsMaxBufferSize = 100;

  // Upload timers
  Timer? _rawDataUploadTimer;
  Timer? _vitalsUploadTimer;

  // Statistics
  final RxInt rawPacketsSent = 0.obs;
  final RxInt vitalsBatchesSent = 0.obs;
  final RxInt uploadErrors = 0.obs;
  final RxBool isUploading = false.obs;

  @override
  void onClose() {
    stopSession();
    super.onClose();
  }

  /// Start a new session with dual upload
  Future<void> startSession(
    String sessionId,
    String phase,
    String mode,
  ) async {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('[DualUpload] 🚀 STARTING DUAL UPLOAD SERVICE');
    print('[DualUpload] Session ID: $sessionId');
    print('[DualUpload] Phase: $phase');
    print('[DualUpload] Mode: $mode');
    print('═══════════════════════════════════════════════════════════');
    print('');

    _sessionId = sessionId;
    _currentPhase = phase;
    _currentMode = mode;

    // Clear buffers
    _rawDataBuffer.clear();
    _vitalsBuffer.clear();

    // Reset statistics
    rawPacketsSent.value = 0;
    vitalsBatchesSent.value = 0;
    uploadErrors.value = 0;

    // Start periodic upload timers
    _startUploadTimers();

    print('[DualUpload] ✅ Upload timers started:');
    print('[DualUpload]    - Raw data: Every 1 second');
    print('[DualUpload]    - Vitals: Every 5 seconds');
    print('[DualUpload] ✅ Service ready - waiting for data...');
    print('');
  }

  /// Stop the current session and flush remaining data
  Future<void> stopSession() async {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('[DualUpload] 🛑 STOPPING DUAL UPLOAD SERVICE');
    print('[DualUpload] Raw packets sent: ${rawPacketsSent.value}');
    print('[DualUpload] Vitals batches sent: ${vitalsBatchesSent.value}');
    print('[DualUpload] Upload errors: ${uploadErrors.value}');
    print('═══════════════════════════════════════════════════════════');

    // Cancel timers
    _rawDataUploadTimer?.cancel();
    _vitalsUploadTimer?.cancel();
    print('[DualUpload] ⏹️ Upload timers cancelled');

    // Flush any remaining data
    print('[DualUpload] 🔄 Flushing remaining buffers...');
    await flushBuffers();

    // Clear state
    _sessionId = null;
    _rawDataBuffer.clear();
    _vitalsBuffer.clear();

    print('[DualUpload] ✅ Service stopped - all data uploaded');
    print('');
  }

  /// Add collar data packet to raw data buffer
  void addCollarData(CollarDataPacket packet) {
    if (_sessionId == null) {
      // Silently ignore data when no session is active (normal during baseline)
      return;
    }

    // Add to raw data buffer (for MessagePack upload to S3)
    // Clean numeric values - convert NaN/Infinity to null
    double? cleanDouble(double value) {
      if (value.isNaN || value.isInfinite) return null;
      return value;
    }

    final rawDataPoint = {
      'timestamp_ms': packet.timestampMs,
      'timestamp': packet.receivedAt.toIso8601String(),
      'sequence': packet.sequenceNumber,
      'packet_type': packet.packetType,
      'pressure_raw': packet.pressureRaw,
      'pressure_filtered': packet.pressureFiltered,
      'imu_accel': packet.imuAccel,
      'imu_gyro': packet.imuGyro,
      'temperature_c': cleanDouble(packet.temperatureC),
      'battery_percent': packet.batteryPercent,
      'signal_quality': packet.signalQuality,
      'heart_rate_bpm': cleanDouble(packet.heartRateBpm.toDouble()),
      'respiratory_rate_bpm': cleanDouble(packet.respiratoryRateBpm.toDouble()),
    };

    _rawDataBuffer.add(rawDataPoint);

    // Log every 50th packet to show buffering activity
    if (_rawDataBuffer.length % 50 == 0) {
      print('[DualUpload] 📦 Raw data buffer: ${_rawDataBuffer.length}/$_rawDataBatchSize packets');
    }

    // If buffer is full, upload immediately
    if (_rawDataBuffer.length >= _rawDataBatchSize) {
      print('[DualUpload] 🚨 Buffer full (${_rawDataBuffer.length} packets) - triggering immediate upload');
      _uploadRawDataBatch();
    }

    // Safety check: prevent buffer overflow
    if (_rawDataBuffer.length > _rawDataMaxBufferSize) {
      print('[DualUpload] ⚠️ Raw data buffer overflow, forcing upload');
      _uploadRawDataBatch();
    }
  }

  /// Add vitals data to vitals buffer
  void addVitals(Vitals vitals) {
    if (_sessionId == null) {
      // Silently ignore vitals when no session is active (normal during baseline)
      return;
    }

    _vitalsBuffer.add(vitals);

    print('[DualUpload] 📊 Vitals buffered: ${_vitalsBuffer.length}/$_vitalsBatchSize records');

    // If buffer is full, upload immediately
    if (_vitalsBuffer.length >= _vitalsBatchSize) {
      print('[DualUpload] 🚨 Vitals buffer full - triggering immediate upload');
      _uploadVitalsBatch();
    }

    // Safety check: prevent buffer overflow
    if (_vitalsBuffer.length > _vitalsMaxBufferSize) {
      print('[DualUpload] ⚠️ Vitals buffer overflow, forcing upload');
      _uploadVitalsBatch();
    }
  }

  /// Flush all buffers (called when stopping session or on demand)
  Future<void> flushBuffers() async {
    print('[DualUpload] 🔄 Flushing buffers...');

    final futures = <Future>[];

    if (_rawDataBuffer.isNotEmpty) {
      futures.add(_uploadRawDataBatch());
    }

    if (_vitalsBuffer.isNotEmpty) {
      futures.add(_uploadVitalsBatch());
    }

    await Future.wait(futures);

    print('[DualUpload] ✅ Buffers flushed');
  }

  /// Start periodic upload timers
  void _startUploadTimers() {
    // Upload raw data every 1 second
    _rawDataUploadTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_rawDataBuffer.isNotEmpty) {
        _uploadRawDataBatch();
      }
    });

    // Upload vitals every 5 seconds
    _vitalsUploadTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_vitalsBuffer.isNotEmpty) {
        _uploadVitalsBatch();
      }
    });
  }

  /// Upload raw data batch (MessagePack to S3)
  Future<void> _uploadRawDataBatch() async {
    if (_rawDataBuffer.isEmpty || _sessionId == null) return;

    // Take batch from buffer
    final batchSize = _rawDataBuffer.length < _rawDataBatchSize
        ? _rawDataBuffer.length
        : _rawDataBatchSize;
    final batch = _rawDataBuffer.sublist(0, batchSize);
    _rawDataBuffer.removeRange(0, batchSize);

    print('');
    print('[DualUpload] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('[DualUpload] 📤 UPLOADING RAW DATA BATCH');
    print('[DualUpload] Batch size: ${batch.length} packets');
    print('[DualUpload] Endpoint: POST /sessions/$_sessionId/raw-collar-data/upload');
    print('[DualUpload] Phase: $_currentPhase | Mode: $_currentMode');
    print('[DualUpload] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    try {
      isUploading.value = true;

      // Calculate timestamps from batch - find actual min/max (packets may be out of order)
      final timestamps = batch.map((p) => p['timestamp_ms'] as int).toList();
      final timestampStart = timestamps.reduce((a, b) => a < b ? a : b);  // MIN
      var timestampEnd = timestamps.reduce((a, b) => a > b ? a : b);      // MAX

      // Ensure end > start (backend constraint requires strictly greater)
      if (timestampEnd <= timestampStart) {
        timestampEnd = timestampStart + 1;  // Add 1ms if equal
      }

      // Sample rate: 100Hz for raw mode, 1Hz for filtered mode
      final sampleRateHz = _currentMode == 'raw' ? 100 : 1;

      // Convert to MessagePack
      final messagePackData = serialize({
        'session_id': _sessionId,
        'phase': _currentPhase,
        'mode': _currentMode,
        'timestamp': DateTime.now().toIso8601String(),
        'data': batch,
      });

      print('[DualUpload] 🔄 Serialized to MessagePack: ${messagePackData.length} bytes');
      print('[DualUpload] 📊 Timestamps: $timestampStart → $timestampEnd (${timestampEnd - timestampStart}ms)');
      print('[DualUpload] 🔢 Sample rate: $sampleRateHz Hz');

      // Upload to backend with all required headers
      await _apiService.uploadRawCollarData(
        sessionId: _sessionId!,
        headers: {
          'X-Data-Phase': _currentPhase,
          'X-Data-Mode': _currentMode,
          'X-Sample-Rate-Hz': sampleRateHz.toString(),
          'X-Batch-Size': batch.length.toString(),
          'X-Timestamp-Start': timestampStart.toString(),
          'X-Timestamp-End': timestampEnd.toString(),
        },
        data: Uint8List.fromList(messagePackData),
      );

      rawPacketsSent.value += batch.length;

      print('[DualUpload] ✅ SUCCESS - Raw data uploaded');
      print('[DualUpload] Total packets sent: ${rawPacketsSent.value}');
      print('[DualUpload] Remaining in buffer: ${_rawDataBuffer.length}');
      print('');
    } catch (e) {
      print('[DualUpload] ❌ Failed to upload raw data batch: $e');
      uploadErrors.value++;

      // Queue for offline retry - insert directly into sync queue
      try {
        // Calculate timestamps from batch - find actual min/max
        final timestamps = batch.map((p) => p['timestamp_ms'] as int).toList();
        final timestampStart = timestamps.reduce((a, b) => a < b ? a : b);  // MIN
        final timestampEnd = timestamps.reduce((a, b) => a > b ? a : b);    // MAX
        final sampleRateHz = _currentMode == 'raw' ? 100 : 1;

        final messagePackData = serialize({
          'session_id': _sessionId,
          'phase': _currentPhase,
          'mode': _currentMode,
          'timestamp': DateTime.now().toIso8601String(),
          'data': batch,
        });

        final db = await _db.database;
        await db.insert('raw_data_sync_queue', {
          'session_id': _sessionId!,
          'chunk_data': Uint8List.fromList(messagePackData),
          'headers_json': jsonEncode({
            'X-Data-Phase': _currentPhase,
            'X-Data-Mode': _currentMode,
            'X-Sample-Rate-Hz': sampleRateHz.toString(),
            'X-Batch-Size': batch.length.toString(),
            'X-Timestamp-Start': timestampStart.toString(),
            'X-Timestamp-End': timestampEnd.toString(),
          }),
          'created_at': DateTime.now().toIso8601String(),
          'uploaded': 0,
          'retry_count': 0,
        });

        print('[DualUpload] 💾 Queued raw data batch for offline retry');
      } catch (queueError) {
        print('[DualUpload] ❌ Failed to queue raw data: $queueError');
      }
    } finally {
      isUploading.value = false;
    }
  }

  /// Upload vitals batch (JSON to PostgreSQL)
  Future<void> _uploadVitalsBatch() async {
    if (_vitalsBuffer.isEmpty || _sessionId == null) return;

    // Take batch from buffer
    final batchSize = _vitalsBuffer.length < _vitalsBatchSize
        ? _vitalsBuffer.length
        : _vitalsBatchSize;
    final batch = _vitalsBuffer.sublist(0, batchSize);
    _vitalsBuffer.removeRange(0, batchSize);

    print('');
    print('[DualUpload] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('[DualUpload] 📊 UPLOADING VITALS BATCH');
    print('[DualUpload] Batch size: ${batch.length} records');
    print('[DualUpload] Endpoint: POST /sessions/$_sessionId/vitals/batch');
    print('[DualUpload] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    try {
      isUploading.value = true;

      // Upload to backend
      await _apiService.uploadVitalsBatch(_sessionId!, batch);

      vitalsBatchesSent.value++;

      print('[DualUpload] ✅ SUCCESS - Vitals uploaded');
      print('[DualUpload] Total batches sent: ${vitalsBatchesSent.value}');
      print('[DualUpload] Remaining in buffer: ${_vitalsBuffer.length}');
      print('');
    } catch (e) {
      print('[DualUpload] ❌ Failed to upload vitals batch: $e');
      uploadErrors.value++;

      // Queue for offline retry - insert directly into sync queue
      try {
        final db = await _db.database;
        await db.insert('vitals_sync_queue', {
          'session_id': _sessionId!,
          'vitals_json': jsonEncode(batch.map((v) => v.toJson()).toList()),
          'created_at': DateTime.now().toIso8601String(),
          'uploaded': 0,
          'retry_count': 0,
        });

        print('[DualUpload] 💾 Queued vitals batch for offline retry');
      } catch (queueError) {
        print('[DualUpload] ❌ Failed to queue vitals: $queueError');
      }
    } finally {
      isUploading.value = false;
    }
  }

  /// Update phase (baseline, pre_surgery, surgery, recovery)
  void updatePhase(String phase) {
    _currentPhase = phase;
    print('[DualUpload] 🔄 Phase updated to: $phase');
  }

  /// Update mode (filtered, raw)
  void updateMode(String mode) {
    _currentMode = mode;
    print('[DualUpload] 🔄 Mode updated to: $mode');
  }
}
