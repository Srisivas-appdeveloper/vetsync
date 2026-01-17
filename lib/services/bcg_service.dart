// lib/services/bcg_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/algorithms/bcg_algorithm.dart';
import '../data/models/collar_packet_validated.dart';
import '../core/constants/ble_constants.dart';

/// Service layer for BCG (Ballistocardiography) signal processing
/// Handles: packet batching, mode switching, algorithm lifecycle
class BcgService extends ChangeNotifier {
  // BCG algorithm instance (mode-dependent)
  BcgAlgorithm _algorithm = BcgAlgorithm(sampleRate: 100);

  // Packet batching for performance optimization
  final List<int> _pressureBatch = [];
  static const int _batchSize = 50; // ~500ms @ 100Hz, ~390ms @ 128Hz

  // Latest results
  BcgResult? _latestResult;
  int _latestTemperatureRaw = 0;

  // Quality metrics
  int _totalPackets = 0;
  int _processedBatches = 0;
  int _invalidResults = 0;
  DateTime? _lastUpdateTime;

  // Current operating mode
  int _currentMode =
      BlePacketTypes.modeFiltered; // Default to filtered/standard

  // Stream for raw pressure data (waveform visualization)
  final _rawDataController = StreamController<List<int>>.broadcast();
  Stream<List<int>> get rawDataStream => _rawDataController.stream;

  /// Get latest BCG processing result
  BcgResult? get latestResult => _latestResult;

  /// Get latest temperature (raw ADC value)
  int get latestTemperatureRaw => _latestTemperatureRaw;

  /// Get temperature in Celsius (NPM1300 die temperature)
  double get temperatureCelsius {
    // NPM1300 die temperature formula (from datasheet)
    // Typical calibration: 394.67 - raw * 0.5003
    return 394.67 - (_latestTemperatureRaw * 0.5003);
  }

  /// Get current mode
  int get currentMode => _currentMode;

  /// Get quality statistics
  Map<String, dynamic> get statistics => {
    'totalPackets': _totalPackets,
    'processedBatches': _processedBatches,
    'invalidResults': _invalidResults,
    'validResultRate': _processedBatches > 0
        ? (_processedBatches - _invalidResults) / _processedBatches
        : 0.0,
    'lastUpdate': _lastUpdateTime,
    'bufferLength': _algorithm.bufferLengthSeconds,
  };

  // Debug counters for rate tracking
  int _totalSamplesReceived = 0;
  DateTime? _rateCheckStartTime;

  /// Process incoming collar packet
  /// Call this on every BLE packet received
  void onPacketReceived(CollarPacket packet) {
    _totalPackets++;

    // Track sample rate (first 10 seconds)
    final samplesInPacket = packet.pressures.length;
    _totalSamplesReceived += samplesInPacket;

    if (_rateCheckStartTime == null) {
      _rateCheckStartTime = DateTime.now();
    }

    final elapsed = DateTime.now().difference(_rateCheckStartTime!);
    if (elapsed.inSeconds >= 10 && elapsed.inSeconds < 11) {
      final actualSampleRate = _totalSamplesReceived / elapsed.inSeconds;
      debugPrint(
        '[BCG] 📊 Sample Rate Check: '
        '${actualSampleRate.toStringAsFixed(1)} Hz '
        '(${_totalSamplesReceived} samples in ${elapsed.inSeconds}s, '
        '${_totalPackets} packets, '
        '${(samplesInPacket)} samples/packet)',
      );
    }

    // Store temperature (updated on every packet)
    _latestTemperatureRaw = packet.temperatureRaw;

    // Add all aggregated pressures to batch and stream
    for (final pressure in packet.pressures) {
      _pressureBatch.add(pressure);
    }

    // Emit all new samples to raw stream
    if (packet.pressures.isNotEmpty) {
      _rawDataController.add(packet.pressures);
    }

    // Process batch if full
    if (_pressureBatch.length >= _batchSize) {
      _processBatch();
    }
  }

  /// Process accumulated pressure samples through BCG algorithm
  void _processBatch() {
    if (_pressureBatch.isEmpty) return;

    try {
      // Run BCG algorithm on batch
      final result = _algorithm.processSamples(_pressureBatch);
      _processedBatches++;

      // Log first few batches for debugging
      if (_processedBatches <= 3) {
        debugPrint(
          '[BCG] 🎯 Batch #$_processedBatches processed: '
          'HR=${result.heartRateBpm.toStringAsFixed(1)} bpm, '
          'RR=${result.respiratoryRateBpm.toStringAsFixed(1)} brpm, '
          'Quality=${result.signalQuality}%, '
          'Valid=${result.isValid}',
        );
      }

      // Debug logging for signal validation
      if (result.isValid) {
        // debugPrint(
        //   '[BCG] ✅ VALID signal - HR: ${result.heartRateBpm} BPM (conf: ${(result.hrConfidence * 100).toInt()}%), RR: ${result.respiratoryRateBpm} BPM (conf: ${(result.rrConfidence * 100).toInt()}%), Quality: ${result.signalQuality}%',
        // );
      } else {
        // Log why it's invalid
        final reasons = <String>[];
        if (result.hrConfidence <= 0.3)
          reasons.add('HR conf low (${(result.hrConfidence * 100).toInt()}%)');
        if (result.rrConfidence <= 0.3)
          reasons.add('RR conf low (${(result.rrConfidence * 100).toInt()}%)');
        // debugPrint(
        //   '[BCG] ❌ INVALID signal - ${reasons.join(", ")} - Quality: ${result.signalQuality}% (UI shows "Collecting data...")',
        // );
      }

      // Update latest result
      _latestResult = result;
      _lastUpdateTime = DateTime.now();

      // Track quality
      if (!result.isValid) {
        _invalidResults++;
      }

      // Clear batch
      _pressureBatch.clear();

      // Notify listeners (UI updates)
      notifyListeners();
    } catch (e, stack) {
      debugPrint('BCG processing error: $e');
      debugPrint('Stack: $stack');
      _invalidResults++;
      _pressureBatch.clear();
    }
  }

  /// Switch operating mode (STANDARD vs HIGH-RES)
  /// Call this when mode switch command is sent
  void onModeChange(int newMode) {
    if (newMode == _currentMode) return;

    debugPrint(
      'BCG: Mode change: ${_getModeString(_currentMode)} -> ${_getModeString(newMode)}',
    );

    _currentMode = newMode;

    // Instantiate appropriate algorithm variant
    if (newMode == BlePacketTypes.modeFiltered) {
      // Standard
      _algorithm = BcgAlgorithm(sampleRate: 100);
    } else if (newMode == BlePacketTypes.modeRaw) {
      // High-Res
      _algorithm = BcgAlgorithmRaw(); // 128 Hz
    } else {
      debugPrint('BCG: Unknown mode: $newMode, defaulting to STANDARD');
      _algorithm = BcgAlgorithm(sampleRate: 100);
    }

    // Clear buffers on mode change
    _pressureBatch.clear();
    _latestResult = null;
    _lastUpdateTime = null;

    notifyListeners();
  }

  /// Reset all state (call on disconnect)
  void reset() {
    debugPrint('BCG: Service reset');

    _algorithm.reset();
    _pressureBatch.clear();
    _latestResult = null;
    _latestTemperatureRaw = 0;
    _lastUpdateTime = null;
    _totalPackets = 0;
    _processedBatches = 0;
    _invalidResults = 0;

    // Reset rate tracking
    _totalSamplesReceived = 0;
    _rateCheckStartTime = null;

    notifyListeners();
  }

  /// Force process current batch (call before disconnect)
  void flush() {
    if (_pressureBatch.isNotEmpty) {
      debugPrint('BCG: Flushing batch with ${_pressureBatch.length} samples');
      _processBatch();
    }
  }

  /// Get human-readable mode string
  String _getModeString(int mode) {
    switch (mode) {
      case BlePacketTypes.modeFiltered:
        return 'STANDARD (100Hz)';
      case BlePacketTypes.modeRaw:
        return 'HIGH-RES (128Hz)';
      default:
        return 'UNKNOWN';
    }
  }

  @override
  void dispose() {
    flush();
    _rawDataController.close();
    super.dispose();
  }
}

/// Extension for signal quality assessment
extension BcgResultQuality on BcgResult {
  /// Overall quality assessment
  QualityLevel get qualityLevel {
    if (!isValid || signalQuality < 30) return QualityLevel.poor;
    if (signalQuality < 60) return QualityLevel.fair;
    if (signalQuality < 80) return QualityLevel.good;
    return QualityLevel.excellent;
  }

  /// Get user-friendly quality message
  String get qualityMessage {
    switch (qualityLevel) {
      case QualityLevel.poor:
        return 'Poor signal quality. Check collar placement.';
      case QualityLevel.fair:
        return 'Fair signal quality. Values may be inaccurate.';
      case QualityLevel.good:
        return 'Good signal quality.';
      case QualityLevel.excellent:
        return 'Excellent signal quality.';
    }
  }

  /// Check if heart rate is physiologically plausible
  bool get isHeartRatePlausible {
    return heartRateBpm >= 40 && heartRateBpm <= 220 && hrConfidence > 0.3;
  }

  /// Check if respiratory rate is physiologically plausible
  bool get isRespiratoryRatePlausible {
    return respiratoryRateBpm >= 5 &&
        respiratoryRateBpm <= 60 &&
        rrConfidence > 0.3;
  }
}

/// Signal quality levels
enum QualityLevel { poor, fair, good, excellent }
