import 'dart:typed_data';
import 'enums.dart';

/// Real-time vitals data
class Vitals {
  final int heartRateBpm;
  final int respiratoryRateBpm;
  final double temperatureC;
  final int signalQuality;
  final DateTime timestamp;

  // Confidence scores for gating display
  final double? hrConfidence;
  final double? rrConfidence;

  // Breed-specific range context (optional, for enhanced gating)
  final int? minHR;
  final int? maxHR;
  final int? minRR;
  final int? maxRR;

  Vitals({
    required this.heartRateBpm,
    required this.respiratoryRateBpm,
    required this.temperatureC,
    required this.signalQuality,
    required this.timestamp,
    this.hrConfidence,
    this.rrConfidence,
    this.minHR,
    this.maxHR,
    this.minRR,
    this.maxRR,
  }) {
    // =========================================================================
    // FIX-005: INVARIANT ENFORCEMENT (Authoritative Spec)
    // =========================================================================
    // If HR exists, confidence MUST exist
    if (heartRateBpm > 0) {
      assert(
        hrConfidence != null,
        'INVARIANT VIOLATION (FIX-005): heartRateBpm is set but hrConfidence is null. '
        'This indicates a BCG processor bug.',
      );
    }

    // If RR exists, confidence MUST exist
    if (respiratoryRateBpm > 0) {
      assert(
        rrConfidence != null,
        'INVARIANT VIOLATION (FIX-005): respiratoryRateBpm is set but rrConfidence is null. '
        'This indicates a BCG processor bug.',
      );
    }

    // Confidence must be in valid range [0, 1]
    if (hrConfidence != null) {
      assert(
        hrConfidence! >= 0.0 && hrConfidence! <= 1.0,
        'INVARIANT VIOLATION (FIX-005): hrConfidence out of range [0, 1]: $hrConfidence',
      );
    }
    if (rrConfidence != null) {
      assert(
        rrConfidence! >= 0.0 && rrConfidence! <= 1.0,
        'INVARIANT VIOLATION (FIX-005): rrConfidence out of range [0, 1]: $rrConfidence',
      );
    }
  }

  /// Check if vitals are valid
  bool get isValid {
    return heartRateBpm > 0 &&
        heartRateBpm < 300 &&
        respiratoryRateBpm > 0 &&
        respiratoryRateBpm < 80 &&
        temperatureC > 35 &&
        temperatureC < 42;
  }

  // Confidence-based display gating thresholds
  // Note: These match the BCG algorithm's validation thresholds for real-world reliability
  static const double _hrConfidenceThreshold = 0.3; // 30% (matches BCG algorithm)
  static const double _rrConfidenceThreshold = 0.3; // 30% (matches BCG algorithm)
  static const int _signalStabilityThreshold = 30; // 30% (minimum usable signal)

  /// Display HR only when confidence is high enough
  /// Returns null if confidence too low or value out of breed range
  int? get displayHR {
    // Check confidence threshold
    if (hrConfidence != null && hrConfidence! < _hrConfidenceThreshold) {
      return null; // Confidence too low
    }

    // Check signal stability
    if (signalQuality < _signalStabilityThreshold) {
      return null; // Signal unstable
    }

    // Check if value is reasonable (basic plausibility)
    if (heartRateBpm <= 0 || heartRateBpm > 300) {
      return null; // Invalid value
    }

    // Check breed-specific range if provided
    if (minHR != null && maxHR != null) {
      // Allow slight tolerance (+/- 20%) outside breed range
      final toleranceMargin = ((maxHR! - minHR!) * 0.2).round();
      final lowerBound = minHR! - toleranceMargin;
      final upperBound = maxHR! + toleranceMargin;

      if (heartRateBpm < lowerBound || heartRateBpm > upperBound) {
        return null; // Outside plausible range for breed
      }
    }

    return heartRateBpm;
  }

  /// Display RR only when confidence is high enough
  /// Returns null if confidence too low or value out of breed range
  int? get displayRR {
    // Check confidence threshold
    if (rrConfidence != null && rrConfidence! < _rrConfidenceThreshold) {
      return null; // Confidence too low
    }

    // Check signal stability
    if (signalQuality < _signalStabilityThreshold) {
      return null; // Signal unstable
    }

    // Check if value is reasonable (basic plausibility)
    if (respiratoryRateBpm <= 0 || respiratoryRateBpm > 80) {
      return null; // Invalid value
    }

    // Check breed-specific range if provided
    if (minRR != null && maxRR != null) {
      // Allow slight tolerance (+/- 30%) outside breed range
      final toleranceMargin = ((maxRR! - minRR!) * 0.3).round();
      final lowerBound = minRR! - toleranceMargin;
      final upperBound = maxRR! + toleranceMargin;

      if (respiratoryRateBpm < lowerBound || respiratoryRateBpm > upperBound) {
        return null; // Outside plausible range for breed
      }
    }

    return respiratoryRateBpm;
  }

  /// Display temperature only when valid
  /// Returns null for invalid temperature readings
  /// Note: This is NPM1300 die temperature (chip temp), not animal body temp
  double? get displayTemperature {
    // Check for NaN
    if (temperatureC.isNaN) {
      return null;
    }

    // Check NPM1300 operating range (-40 to +85°C)
    // Typical die temperature during operation: 20-80°C
    if (temperatureC < -40.0 || temperatureC > 85.0) {
      return null;
    }

    return temperatureC;
  }

  /// Get temperature in Fahrenheit
  double get temperatureF => (temperatureC * 9 / 5) + 32;

  factory Vitals.fromJson(Map<String, dynamic> json) {
    return Vitals(
      heartRateBpm: json['heart_rate_bpm'] as int,
      respiratoryRateBpm: json['respiratory_rate_bpm'] as int,
      temperatureC: (json['temperature_c'] as num).toDouble(),
      signalQuality: json['signal_quality'] as int? ?? 100,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    // =========================================================================
    // FIX-005: Include confidence fields when vitals present (Authoritative Spec)
    // =========================================================================
    final json = <String, dynamic>{
      'timestamp': timestamp.toIso8601String(),
      'signal_quality': signalQuality,
      'temperature_c': temperatureC,
    };

    // Heart rate: include BOTH bpm and confidence, or NEITHER
    if (heartRateBpm > 0) {
      json['heart_rate_bpm'] = heartRateBpm;
      json['heart_rate_confidence'] = hrConfidence; // Guaranteed non-null by invariant
    }

    // Respiratory rate: include BOTH bpm and confidence, or NEITHER
    if (respiratoryRateBpm > 0) {
      json['respiratory_rate_bpm'] = respiratoryRateBpm;
      json['respiratory_rate_confidence'] = rrConfidence; // Guaranteed non-null by invariant
    }

    return json;
  }

  @override
  String toString() =>
      'Vitals(HR: $heartRateBpm, RR: $respiratoryRateBpm, T: ${temperatureC.toStringAsFixed(1)}°C)';
}

/// Collar data packet received from BLE
class CollarDataPacket {
  final int packetType; // 0xF1 = filtered, 0xF2 = raw
  final int sequenceNumber;
  final int timestampMs;
  final int heartRateBpm;
  final int respiratoryRateBpm;
  final double temperatureC;
  final int batteryPercent;
  final int signalQuality;

  // Sensor values
  final int pressureFiltered;
  final int? pressureRaw;
  final List<int>? imuAccel; // [x, y, z]
  final List<int>? imuGyro; // [x, y, z]

  final DateTime receivedAt;

  CollarDataPacket({
    required this.packetType,
    required this.sequenceNumber,
    required this.timestampMs,
    required this.heartRateBpm,
    required this.respiratoryRateBpm,
    required this.temperatureC,
    required this.batteryPercent,
    required this.signalQuality,
    required this.pressureFiltered,
    this.pressureRaw,
    this.imuAccel,
    this.imuGyro,
    DateTime? receivedAt,
  }) : receivedAt = receivedAt ?? DateTime.now();

  /// Check if this is a filtered mode packet
  bool get isFiltered => packetType == 0xF1;

  /// Check if this is a raw mode packet
  bool get isRaw => packetType == 0xF2;

  /// Get firmware mode
  FirmwareMode get mode => isRaw ? FirmwareMode.raw : FirmwareMode.filtered;

  /// Convert to Vitals
  Vitals toVitals() {
    return Vitals(
      heartRateBpm: heartRateBpm,
      respiratoryRateBpm: respiratoryRateBpm,
      temperatureC: temperatureC,
      signalQuality: signalQuality,
      timestamp: receivedAt,
    );
  }

  /// Parse packet from raw bytes
  /// Filtered packet (0xF1): 34 bytes
  /// Raw packet (0xF2): 27 bytes
  factory CollarDataPacket.fromBytes(Uint8List data) {
    if (data.isEmpty) {
      throw FormatException('Empty packet data');
    }

    final packetType = data[0];

    if (packetType == 0xF1) {
      return _parseFilteredPacket(data);
    } else if (packetType == 0xF2) {
      return _parseRawPacket(data);
    } else {
      throw FormatException(
        'Unknown packet type: 0x${packetType.toRadixString(16)}',
      );
    }
  }

  /// Parse filtered mode packet (0xF1) - 34 bytes
  static CollarDataPacket _parseFilteredPacket(Uint8List data) {
    if (data.length < 34) {
      throw FormatException('Filtered packet too short: ${data.length} bytes');
    }

    final buffer = ByteData.view(data.buffer);

    return CollarDataPacket(
      packetType: data[0],
      sequenceNumber: buffer.getUint16(1, Endian.little),
      timestampMs: buffer.getUint32(3, Endian.little),
      pressureFiltered: buffer.getInt16(7, Endian.little),
      heartRateBpm: data[9],
      respiratoryRateBpm: data[10],
      temperatureC: buffer.getInt16(11, Endian.little) / 100.0,
      batteryPercent: data[13],
      signalQuality: data[14],
      imuAccel: [
        buffer.getInt16(15, Endian.little),
        buffer.getInt16(17, Endian.little),
        buffer.getInt16(19, Endian.little),
      ],
      imuGyro: [
        buffer.getInt16(21, Endian.little),
        buffer.getInt16(23, Endian.little),
        buffer.getInt16(25, Endian.little),
      ],
      // Bytes 27-32: Reserved
      // Byte 33: Checksum
    );
  }

  /// Parse raw mode packet (0xF2) - 27 bytes
  static CollarDataPacket _parseRawPacket(Uint8List data) {
    if (data.length < 27) {
      throw FormatException('Raw packet too short: ${data.length} bytes');
    }

    final buffer = ByteData.view(data.buffer);

    return CollarDataPacket(
      packetType: data[0],
      sequenceNumber: buffer.getUint16(1, Endian.little),
      timestampMs: buffer.getUint32(3, Endian.little),
      pressureFiltered: 0, // No filtered value in raw mode
      pressureRaw: buffer.getInt16(7, Endian.little),
      heartRateBpm: 0, // Not calculated in raw mode
      respiratoryRateBpm: 0, // Not calculated in raw mode
      temperatureC: buffer.getInt16(9, Endian.little) / 100.0,
      batteryPercent: data[11],
      signalQuality: data[12],
      imuAccel: [
        buffer.getInt16(13, Endian.little),
        buffer.getInt16(15, Endian.little),
        buffer.getInt16(17, Endian.little),
      ],
      imuGyro: [
        buffer.getInt16(19, Endian.little),
        buffer.getInt16(21, Endian.little),
        buffer.getInt16(23, Endian.little),
      ],
      // Bytes 25-26: Reserved/Checksum
    );
  }

  /// Serialize packet to bytes (for storage)
  Uint8List toBytes() {
    if (isFiltered) {
      final data = Uint8List(34);
      final buffer = ByteData.view(data.buffer);

      data[0] = packetType;
      buffer.setUint16(1, sequenceNumber, Endian.little);
      buffer.setUint32(3, timestampMs, Endian.little);
      buffer.setInt16(7, pressureFiltered, Endian.little);
      data[9] = heartRateBpm;
      data[10] = respiratoryRateBpm;
      buffer.setInt16(11, (temperatureC * 100).round(), Endian.little);
      data[13] = batteryPercent;
      data[14] = signalQuality;

      if (imuAccel != null) {
        buffer.setInt16(15, imuAccel![0], Endian.little);
        buffer.setInt16(17, imuAccel![1], Endian.little);
        buffer.setInt16(19, imuAccel![2], Endian.little);
      }
      if (imuGyro != null) {
        buffer.setInt16(21, imuGyro![0], Endian.little);
        buffer.setInt16(23, imuGyro![1], Endian.little);
        buffer.setInt16(25, imuGyro![2], Endian.little);
      }

      return data;
    } else {
      final data = Uint8List(27);
      final buffer = ByteData.view(data.buffer);

      data[0] = packetType;
      buffer.setUint16(1, sequenceNumber, Endian.little);
      buffer.setUint32(3, timestampMs, Endian.little);
      buffer.setInt16(7, pressureRaw ?? 0, Endian.little);
      buffer.setInt16(9, (temperatureC * 100).round(), Endian.little);
      data[11] = batteryPercent;
      data[12] = signalQuality;

      if (imuAccel != null) {
        buffer.setInt16(13, imuAccel![0], Endian.little);
        buffer.setInt16(15, imuAccel![1], Endian.little);
        buffer.setInt16(17, imuAccel![2], Endian.little);
      }
      if (imuGyro != null) {
        buffer.setInt16(19, imuGyro![0], Endian.little);
        buffer.setInt16(21, imuGyro![1], Endian.little);
        buffer.setInt16(23, imuGyro![2], Endian.little);
      }

      return data;
    }
  }

  @override
  String toString() =>
      'CollarDataPacket(type: 0x${packetType.toRadixString(16)}, seq: $sequenceNumber)';
}

typedef VitalSigns = Vitals;
