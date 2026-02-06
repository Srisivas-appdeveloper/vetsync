import '../data/models/models.dart';
import '../data/models/collar_packet_validated.dart';

/// Wear state enum - maps to backend WearState
enum WearState {
  worn,
  notWorn,
  uncertain,
}

/// Validation result with pass/fail and reasons
class ValidationResult {
  final bool isValid;
  final List<String> reasons;

  ValidationResult.pass()
      : isValid = true,
        reasons = [];

  ValidationResult.fail(this.reasons) : isValid = false;

  @override
  String toString() => isValid ? 'PASS' : 'FAIL: ${reasons.join(", ")}';
}

/// Validation statistics tracker
class ValidationStatistics {
  // Rejection counters
  int totalPacketsValidated = 0;
  int packetsRejected = 0;
  int vitalsRejected = 0;

  // Rejection reasons breakdown
  final Map<String, int> rejectionReasons = {};

  // Specific error counters
  int crcErrors = 0;
  int timestampErrors = 0;
  int wearStateRejections = 0;
  int calibrationRejections = 0;
  int sequenceGaps = 0;
  int qualityRejections = 0;
  int physiologicalRangeRejections = 0;
  int confidenceRejections = 0;

  /// Get rejection rate as a percentage
  double get rejectionRate =>
      totalPacketsValidated > 0 ? packetsRejected / totalPacketsValidated : 0.0;

  /// Track a rejection with reasons
  void trackRejection(List<String> reasons) {
    packetsRejected++;
    for (final reason in reasons) {
      rejectionReasons[reason] = (rejectionReasons[reason] ?? 0) + 1;

      // Update specific counters
      if (reason.contains('crc')) crcErrors++;
      if (reason.contains('timestamp')) timestampErrors++;
      if (reason.contains('wear_state')) wearStateRejections++;
      if (reason.contains('calibration')) calibrationRejections++;
      if (reason.contains('sequence')) sequenceGaps++;
      if (reason.contains('quality') || reason.contains('signal')) {
        qualityRejections++;
      }
      if (reason.contains('range') || reason.contains('physiological')) {
        physiologicalRangeRejections++;
      }
      if (reason.contains('confidence')) confidenceRejections++;
    }
  }

  /// Convert to JSON for reporting
  Map<String, dynamic> toJson() => {
        'total_packets_validated': totalPacketsValidated,
        'packets_rejected': packetsRejected,
        'vitals_rejected': vitalsRejected,
        'rejection_rate': '${(rejectionRate * 100).toStringAsFixed(2)}%',
        'rejection_reasons': rejectionReasons,
        'error_breakdown': {
          'crc_errors': crcErrors,
          'timestamp_errors': timestampErrors,
          'wear_state_rejections': wearStateRejections,
          'calibration_rejections': calibrationRejections,
          'sequence_gaps': sequenceGaps,
          'quality_rejections': qualityRejections,
          'physiological_range_rejections': physiologicalRangeRejections,
          'confidence_rejections': confidenceRejections,
        },
      };

  /// Reset all statistics
  void reset() {
    totalPacketsValidated = 0;
    packetsRejected = 0;
    vitalsRejected = 0;
    rejectionReasons.clear();
    crcErrors = 0;
    timestampErrors = 0;
    wearStateRejections = 0;
    calibrationRejections = 0;
    sequenceGaps = 0;
    qualityRejections = 0;
    physiologicalRangeRejections = 0;
    confidenceRejections = 0;
  }
}

/// Phase-specific validation configuration
class ValidationConfig {
  // Timestamp validation
  final int maxTimestampGapMs;
  final int expectedTimestampDeltaMs;
  final double timestampJitterTolerance;
  final bool enforceMonotonicity;

  // Quality thresholds
  final int minSignalQuality;
  final double minConfidence;

  // Wear state detection
  final bool checkWearState;
  final int wearStateWindowSize;
  final int motionThreshold;
  final int pressureVarianceThreshold;

  // Calibration requirements
  final bool requireCalibration;
  final double minCalibrationQuality;
  final Duration maxCalibrationAge;

  // Data sufficiency
  final int minBatchSize;
  final double minBatchQualityAverage;
  final double maxPacketLossRate;

  // Sequence validation
  final int maxSequenceGap;

  ValidationConfig({
    this.maxTimestampGapMs = 1000,
    this.expectedTimestampDeltaMs = 10,
    this.timestampJitterTolerance = 0.2,
    this.enforceMonotonicity = true,
    required this.minSignalQuality,
    required this.minConfidence,
    this.checkWearState = true,
    this.wearStateWindowSize = 30,
    this.motionThreshold = 100,
    this.pressureVarianceThreshold = 50,
    this.requireCalibration = false,
    this.minCalibrationQuality = 0.6,
    this.maxCalibrationAge = const Duration(hours: 24),
    this.minBatchSize = 50,
    required this.minBatchQualityAverage,
    this.maxPacketLossRate = 0.5,
    this.maxSequenceGap = 10,
  });

  /// Create configuration for specific phase
  static ValidationConfig forPhase(String phase) {
    switch (phase) {
      case 'baseline':
        return ValidationConfig(
          minSignalQuality: 20,
          minConfidence: 0.2,
          enforceMonotonicity: false,
          checkWearState: false,
          requireCalibration: false,
          minBatchQualityAverage: 0.25,
        );
      case 'pre_surgery':
        return ValidationConfig(
          minSignalQuality: 30,
          minConfidence: 0.3,
          enforceMonotonicity: true,
          checkWearState: true,
          requireCalibration: false, // Warn only
          minBatchQualityAverage: 0.30,
        );
      case 'surgery':
        return ValidationConfig(
          minSignalQuality: 40,
          minConfidence: 0.3,
          enforceMonotonicity: true,
          checkWearState: true,
          requireCalibration: true, // HARD requirement
          minBatchQualityAverage: 0.35,
        );
      case 'recovery':
        return ValidationConfig(
          minSignalQuality: 30,
          minConfidence: 0.3,
          enforceMonotonicity: true,
          checkWearState: true,
          requireCalibration: false,
          minBatchQualityAverage: 0.30,
        );
      default:
        return ValidationConfig.normal();
    }
  }

  /// Normal (default) configuration
  static ValidationConfig normal() {
    return ValidationConfig(
      minSignalQuality: 30,
      minConfidence: 0.3,
      minBatchQualityAverage: 0.30,
    );
  }

  /// Strict configuration for critical phases
  static ValidationConfig strict() {
    return ValidationConfig(
      minSignalQuality: 40,
      minConfidence: 0.5,
      enforceMonotonicity: true,
      checkWearState: true,
      requireCalibration: true,
      minBatchQualityAverage: 0.40,
    );
  }

  /// Lenient configuration for testing/debugging
  static ValidationConfig lenient() {
    return ValidationConfig(
      minSignalQuality: 10,
      minConfidence: 0.1,
      enforceMonotonicity: false,
      checkWearState: false,
      requireCalibration: false,
      minBatchQualityAverage: 0.15,
    );
  }
}

/// Data quality validator service
/// Maps to backend validation.py module
class DataQualityValidator {
  final ValidationConfig config;
  final ValidationStatistics statistics = ValidationStatistics();

  // Timestamp monotonicity tracking
  int? _lastRawDataTimestamp;
  int? _lastVitalsTimestamp;

  // Sequence tracking
  int? _lastSequenceNumber;

  // Wear state detection (sliding window)
  final List<bool> _recentMotionIndicators = [];
  final List<int> _recentSignalQuality = [];
  WearState _currentWearState = WearState.uncertain;

  // Calibration service reference (injected)
  dynamic calibrationService;

  DataQualityValidator({required this.config});

  /// Reset all state (called on session start/end)
  void reset() {
    _lastRawDataTimestamp = null;
    _lastVitalsTimestamp = null;
    _lastSequenceNumber = null;
    _recentMotionIndicators.clear();
    _recentSignalQuality.clear();
    _currentWearState = WearState.uncertain;
    statistics.reset();
  }

  // =========================================================================
  // VALIDATION METHOD 1: validateRawDataPacket
  // Maps to backend: validate_bcg_packet
  // =========================================================================

  /// Validate individual raw data packet before buffering
  ValidationResult validateRawDataPacket(CollarPacket packet) {
    statistics.totalPacketsValidated++;

    final reasons = <String>[];

    // 1. CRC validation - Already validated in CollarPacket.fromBytes()
    if (!packet.crcValid) {
      reasons.add('crc_validation_failed');
    }

    // 2. Timestamp monotonicity check
    final timestampMs = packet.timestampUs ~/ 1000; // Convert microseconds to milliseconds
    if (config.enforceMonotonicity && _lastRawDataTimestamp != null) {
      if (timestampMs <= _lastRawDataTimestamp!) {
        reasons.add('timestamp_non_monotonic');
      }
    }

    // 3. Timestamp gap check (detect large gaps indicating lost connection)
    if (_lastRawDataTimestamp != null) {
      final gap = timestampMs - _lastRawDataTimestamp!;
      if (gap > config.maxTimestampGapMs) {
        reasons.add('timestamp_gap_too_large');
      }
    }

    // 4. Signal quality threshold (mode-aware: quality for 0xF1, 0 for 0xF2)
    if (packet.quality < config.minSignalQuality) {
      reasons.add('signal_quality_too_low');
    }

    // 5. Physiological range validation
    // Pressure: Valid range for BCG sensor
    if (!packet.isPressureValid) {
      reasons.add('pressure_out_of_range');
    }

    // Temperature: -40 to 85°C (NPM1300 sensor range)
    if (!packet.isTemperatureValid) {
      reasons.add('temperature_out_of_range');
    }

    // Battery: 3000-4500 mV
    if (!packet.isBatteryValid) {
      reasons.add('battery_out_of_range');
    }

    // 6. Sensor error detection (HIGH-RES mode only)
    if (packet.isHighResMode && packet.hasSensorError) {
      reasons.add('sensor_error_detected');
    }

    // Note: Heart rate and respiratory rate are not available in raw CollarPacket
    // They are computed later by BCG service and validated in validateVitals()

    // Update last timestamp if validation passed
    if (reasons.isEmpty) {
      _lastRawDataTimestamp = timestampMs;
    }

    return reasons.isEmpty
        ? ValidationResult.pass()
        : ValidationResult.fail(reasons);
  }

  // =========================================================================
  // VALIDATION METHOD 2: validateBatchTimestamps
  // Maps to backend: validate_bcg_batch_timestamps
  // =========================================================================

  /// Validate timestamp monotonicity across a batch
  ValidationResult validateBatchTimestamps(List<Map<String, dynamic>> batch) {
    if (batch.isEmpty) {
      return ValidationResult.fail(['batch_empty']);
    }

    final reasons = <String>[];

    // Extract timestamps
    final timestamps = <int>[];
    for (final packet in batch) {
      final ts = packet['timestamp_ms'] as int?;
      if (ts == null) {
        reasons.add('timestamp_missing');
        continue;
      }
      timestamps.add(ts);
    }

    if (timestamps.isEmpty) {
      return ValidationResult.fail(['no_valid_timestamps']);
    }

    // Check monotonicity
    for (int i = 1; i < timestamps.length; i++) {
      if (timestamps[i] <= timestamps[i - 1]) {
        reasons.add('batch_timestamps_non_monotonic');
        break;
      }
    }

    // Check for large gaps (> 1 second at 100Hz = > 100 missing packets)
    for (int i = 1; i < timestamps.length; i++) {
      final gap = timestamps[i] - timestamps[i - 1];
      if (gap > config.maxTimestampGapMs) {
        reasons.add('batch_timestamp_gap_detected');
        break;
      }
    }

    // Check timestamp deltas are reasonable (for 100Hz, expect ~10ms ± 20%)
    if (config.enforceMonotonicity) {
      final expectedDelta = config.expectedTimestampDeltaMs;
      final tolerance = expectedDelta * config.timestampJitterTolerance;
      final minDelta = expectedDelta - tolerance;
      final maxDelta = expectedDelta + tolerance;

      int outlierCount = 0;
      for (int i = 1; i < timestamps.length; i++) {
        final delta = timestamps[i] - timestamps[i - 1];
        if (delta < minDelta || delta > maxDelta) {
          outlierCount++;
        }
      }

      // Allow some jitter, but if > 30% of deltas are outliers, flag it
      final outlierRate = outlierCount / (timestamps.length - 1);
      if (outlierRate > 0.3) {
        reasons.add('batch_timestamp_jitter_excessive');
      }
    }

    return reasons.isEmpty
        ? ValidationResult.pass()
        : ValidationResult.fail(reasons);
  }

  // =========================================================================
  // VALIDATION METHOD 3: checkDataSufficiency
  // Maps to backend: InsufficientData error prevention
  // =========================================================================

  /// Check if batch has sufficient quality data for upload
  ValidationResult checkDataSufficiency(List<Map<String, dynamic>> batch) {
    if (batch.isEmpty) {
      return ValidationResult.fail(['batch_empty']);
    }

    final reasons = <String>[];

    // 1. Minimum batch size (at least 50 packets = 0.5s at 100Hz)
    if (batch.length < config.minBatchSize) {
      reasons.add('batch_too_small');
    }

    // 2. Quality score average > threshold
    final qualityScores = <int>[];
    for (final packet in batch) {
      final quality = packet['signal_quality'] as int?;
      if (quality != null) {
        qualityScores.add(quality);
      }
    }

    if (qualityScores.isNotEmpty) {
      final avgQuality =
          qualityScores.reduce((a, b) => a + b) / qualityScores.length;
      if (avgQuality < config.minBatchQualityAverage * 100) {
        reasons.add('batch_quality_too_low');
      }
    } else {
      reasons.add('batch_no_quality_data');
    }

    // 3. Check packet loss rate (if sequence numbers available)
    final sequences = <int>[];
    for (final packet in batch) {
      final seq = packet['sequence'] as int?;
      if (seq != null) {
        sequences.add(seq);
      }
    }

    if (sequences.length >= 2) {
      sequences.sort();
      final expectedCount = sequences.last - sequences.first + 1;
      final actualCount = sequences.length;
      final lossRate = 1.0 - (actualCount / expectedCount);

      if (lossRate > config.maxPacketLossRate) {
        reasons.add('batch_packet_loss_too_high');
      }
    }

    // 4. At least 70% of packets should have valid sensor readings
    int validReadingCount = 0;
    for (final packet in batch) {
      final pressureRaw = packet['pressure_raw'];
      final signalQuality = packet['signal_quality'];
      if (pressureRaw != null && signalQuality != null) {
        validReadingCount++;
      }
    }

    final validRate = validReadingCount / batch.length;
    if (validRate < 0.7) {
      reasons.add('batch_insufficient_valid_readings');
    }

    return reasons.isEmpty
        ? ValidationResult.pass()
        : ValidationResult.fail(reasons);
  }

  // =========================================================================
  // VALIDATION METHOD 4: validateVitals
  // Enhanced validation beyond Vitals.isValid
  // =========================================================================

  /// Validate vitals record before buffering
  ValidationResult validateVitals(
    Vitals vitals, {
    required bool requireHighConfidence,
  }) {
    statistics.totalPacketsValidated++;

    final reasons = <String>[];

    // 1. Use existing Vitals validation
    // (Vitals class already checks physiological ranges)

    // 2. Timestamp monotonicity
    if (config.enforceMonotonicity && _lastVitalsTimestamp != null) {
      final currentTimestamp = vitals.timestamp.millisecondsSinceEpoch;
      if (currentTimestamp <= _lastVitalsTimestamp!) {
        reasons.add('vitals_timestamp_non_monotonic');
      } else {
        _lastVitalsTimestamp = currentTimestamp;
      }
    } else if (_lastVitalsTimestamp == null) {
      _lastVitalsTimestamp = vitals.timestamp.millisecondsSinceEpoch;
    }

    // 3. Confidence threshold enforcement
    final confidenceThreshold =
        requireHighConfidence ? 0.6 : config.minConfidence;

    if (vitals.heartRateBpm > 0 && vitals.hrConfidence != null) {
      if (vitals.hrConfidence! < confidenceThreshold) {
        reasons.add('vitals_hr_confidence_too_low');
      }
    }

    if (vitals.respiratoryRateBpm > 0 && vitals.rrConfidence != null) {
      if (vitals.rrConfidence! < confidenceThreshold) {
        reasons.add('vitals_rr_confidence_too_low');
      }
    }

    // 4. Signal quality check
    if (vitals.signalQuality < config.minSignalQuality) {
      reasons.add('vitals_signal_quality_too_low');
    }

    // 5. Check display methods return non-null (indicates valid data)
    // displayHR and displayRR return null if confidence/quality too low
    if (vitals.displayHR == null && vitals.heartRateBpm > 0) {
      reasons.add('vitals_hr_not_displayable');
    }
    if (vitals.displayRR == null && vitals.respiratoryRateBpm > 0) {
      reasons.add('vitals_rr_not_displayable');
    }

    if (reasons.isNotEmpty) {
      statistics.vitalsRejected++;
    }

    return reasons.isEmpty
        ? ValidationResult.pass()
        : ValidationResult.fail(reasons);
  }

  // =========================================================================
  // VALIDATION METHOD 5: inferWearState
  // Maps to backend: infer_wear_state
  // =========================================================================

  /// Infer if collar is being worn based on signal characteristics
  WearState inferWearState(CollarPacket packet) {
    // Track motion indicators (sliding window)
    // Motion detected = likely worn
    // No motion + low pressure variance = likely not worn

    // Add signal quality to sliding window (mode-aware)
    _recentSignalQuality.add(packet.quality);
    if (_recentSignalQuality.length > config.wearStateWindowSize) {
      _recentSignalQuality.removeAt(0);
    }

    // Check for motion using multiple indicators:
    // 1. Signal quality > 20 (basic threshold)
    // 2. Motion detected flag (HIGH-RES mode only)
    // 3. IMU activity (acceleration magnitude)
    final hasMotion = packet.quality > 20 ||
                      (packet.isHighResMode && packet.hasMotionDetected);

    _recentMotionIndicators.add(hasMotion);
    if (_recentMotionIndicators.length > config.wearStateWindowSize) {
      _recentMotionIndicators.removeAt(0);
    }

    // Don't make a decision until we have enough data
    if (_recentMotionIndicators.length < config.wearStateWindowSize) {
      return WearState.uncertain;
    }

    // Calculate motion rate
    final motionCount =
        _recentMotionIndicators.where((m) => m).length;
    final motionRate = motionCount / _recentMotionIndicators.length;

    // Calculate average signal quality
    final avgQuality =
        _recentSignalQuality.reduce((a, b) => a + b) / _recentSignalQuality.length;

    // Decision logic:
    // - If > 70% motion indicators AND avg quality > 25 = WORN
    // - If < 30% motion indicators AND avg quality < 15 = NOT WORN
    // - Otherwise = UNCERTAIN

    if (motionRate > 0.7 && avgQuality > 25) {
      _currentWearState = WearState.worn;
    } else if (motionRate < 0.3 && avgQuality < 15) {
      _currentWearState = WearState.notWorn;
    } else {
      _currentWearState = WearState.uncertain;
    }

    return _currentWearState;
  }

  // =========================================================================
  // VALIDATION METHOD 6: validateCalibrationState
  // Maps to backend: run_calibration_gates
  // =========================================================================

  /// Validate calibration state for current phase
  ValidationResult validateCalibrationState(String phase) {
    // Check if calibration is required for this phase
    if (!config.requireCalibration) {
      return ValidationResult.pass(); // Not required, skip
    }

    final reasons = <String>[];

    // Check if calibration service is available
    if (calibrationService == null) {
      reasons.add('calibration_service_unavailable');
      return ValidationResult.fail(reasons);
    }

    // Check if calibration exists
    final hasCalibration = calibrationService.hasCustomCalibration as bool?;
    if (hasCalibration == null || !hasCalibration) {
      reasons.add('calibration_missing');
      return ValidationResult.fail(reasons);
    }

    // Check calibration quality
    final quality = calibrationService.calibrationQuality as double?;
    if (quality == null || quality < config.minCalibrationQuality) {
      reasons.add('calibration_quality_insufficient');
      return ValidationResult.fail(reasons);
    }

    // Check calibration age (if available)
    // Note: CalibrationService needs to expose timestamp for this check

    return ValidationResult.pass();
  }

  // =========================================================================
  // SEQUENCE GAP DETECTION
  // =========================================================================

  /// Detect sequence gaps (packet loss)
  /// Returns number of packets lost
  int detectSequenceGap(int currentSequence) {
    if (_lastSequenceNumber == null) {
      _lastSequenceNumber = currentSequence;
      return 0; // First packet, no gap
    }

    final expectedSequence = (_lastSequenceNumber! + 1) & 0xFFFF; // Handle rollover
    final gap = (currentSequence - expectedSequence) & 0xFFFF;

    _lastSequenceNumber = currentSequence;

    if (gap > 0 && gap < config.maxSequenceGap) {
      statistics.sequenceGaps++;
      return gap;
    } else if (gap >= config.maxSequenceGap) {
      statistics.sequenceGaps++;
      return gap; // Large gap detected
    }

    return 0; // No gap
  }
}
