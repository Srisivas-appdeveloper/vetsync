// lib/data/models/collar_packet_validated.dart
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../../utils/crc_utils.dart';

/// Enhanced collar packet with CRC validation and mode-aware parsing
///
/// Improvements over original:
/// - CRC validation on construction
/// - Mode-aware quality/statusFlags handling
/// - Timestamp validation
/// - Physiological range checking
/// - Detailed error messages
///
/// IMPORTANT: The timestamp field is in MICROSECONDS, not milliseconds!
/// The firmware uses microseconds for higher precision timing.
class CollarPacket {
  // Header
  final int packetType;
  final int timestampUs; // ⚠️ Microseconds, not milliseconds!

  // Pressure data
  // Pressure data
  // final int pressure; (Deprecated, use pressures.first)
  final List<int> pressures; // 🔥 Changed to list for aggregation

  // Mode-specific byte 7
  final int _byte7;

  // IMU data
  final int accelX, accelY, accelZ;
  final int gyroX, gyroY, gyroZ;

  // Environmental
  final int temperatureRaw;

  // Battery
  final int batteryMv;
  final int batteryPercent;

  // Checksum
  final int crc16;

  // Validation state
  final bool crcValid;
  final DateTime receivedAt;

  CollarPacket._({
    required this.packetType,
    required this.timestampUs,
    required this.pressures,
    required int byte7,
    required this.accelX,
    required this.accelY,
    required this.accelZ,
    required this.gyroX,
    required this.gyroY,
    required this.gyroZ,
    required this.temperatureRaw,
    required this.batteryMv,
    required this.batteryPercent,
    required this.crc16,
    required this.crcValid,
    required this.receivedAt,
  }) : _byte7 = byte7;

  // Backward compatibility
  int get pressure => pressures.isNotEmpty ? pressures.first : 0;

  // Mode detection
  bool get isStandardMode => packetType == 0xF1;
  bool get isHighResMode => packetType == 0xF2;
  bool get isBatteryPacket => packetType == 0xB1;

  // Mode-aware byte 7 interpretation
  int get quality => isStandardMode ? _byte7 : 0;
  int get statusFlags => isHighResMode ? _byte7 : 0;

  // Status flag parsing (HIGH-RES mode only)
  bool get isCharging => (statusFlags & 0x01) != 0;
  bool get isLowBattery => (statusFlags & 0x02) != 0;
  bool get hasSensorError => (statusFlags & 0x04) != 0;
  bool get hasMotionDetected => (statusFlags & 0x08) != 0;
  bool get isHighResActive => (statusFlags & 0x10) != 0;

  // Computed values
  /// Convert NPM1300 die temperature using datasheet formula
  /// Formula: T(°C) = RAW * 0.25
  /// Valid range: -40°C to +85°C (NPM1300 operating range)
  double get temperatureCelsius {
    final tempC = temperatureRaw * 0.25;

    // Log extremely invalid values for debugging
    if (tempC < -100 || tempC > 150) {
      // debugPrint('[TEMP] ⚠️ Extremely invalid temperature detected: ${tempC.toStringAsFixed(1)}°C (raw: $temperatureRaw)');
    }

    // Return NaN for out-of-range values
    if (tempC < -40.0 || tempC > 85.0) {
      return double.nan;
    }

    return tempC;
  }

  double get batteryVoltage => batteryMv / 1000.0;

  // Validation
  bool get isPressureValid =>
      pressures.isNotEmpty &&
      pressures.first >= 1000 &&
      pressures.first <= 60000;
  bool get isBatteryValid => batteryMv >= 3000 && batteryMv <= 4500;

  /// Temperature is valid if within NPM1300 operating range (-40°C to +85°C)
  /// Raw range: -160 to +340 (since T = RAW * 0.25)
  bool get isTemperatureValid {
    final tempC = temperatureRaw * 0.25;
    return tempC >= -40.0 && tempC <= 85.0;
  }

  bool get isValid =>
      crcValid && isPressureValid && isBatteryValid && isTemperatureValid;

  /// Parse packet from raw bytes with validation
  ///
  /// Throws:
  /// - `PacketTooShortException` if < 27 bytes
  /// - `CrcMismatchException` if CRC validation fails (when throwOnCrcError = true)
  /// - `InvalidPacketTypeException` if packet type unknown
  factory CollarPacket.fromBytes(
    List<int> bytes, {
    bool throwOnCrcError = false,
    DateTime? receivedAt,
  }) {
    // Validate length
    if (bytes.length < 27) {
      throw PacketTooShortException(bytes.length, 27);
    }

    // Validate CRC
    final crcValid = CrcUtils.validatePacketCrc(bytes);
    if (!crcValid && throwOnCrcError) {
      throw CrcMismatchException(
        expected: CrcUtils.crc16Ccitt(bytes.sublist(0, 25)),
        actual: bytes[25] | (bytes[26] << 8),
        packet: bytes,
      );
    }

    // Parse packet
    final buf = ByteData.view(Uint8List.fromList(bytes).buffer);
    final packetType = bytes[0];

    // Validate packet type
    if (packetType != 0xF1 && packetType != 0xF2 && packetType != 0xB1) {
      throw InvalidPacketTypeException(packetType);
    }

    // Parse first pressure
    final firstPressure = buf.getInt16(5, Endian.little);
    final List<int> pressures = [firstPressure];

    // 🔥 Check for aggregated samples
    // Standard packet is 27 bytes. If larger, extra bytes are aggregated samples.
    // Each sample is 2 bytes (Int16)
    if (bytes.length > 27) {
      int offset = 27; // Start after standard packet (including CRC)
      // Note: In some protocols, CRC is at the end. Here CRC is at 25.
      // If data is appended *after* CRC (which seems to be the case based on typical BLE structure usage here),
      // or if the packet structure absorbs them.
      // Let's assume they are appended at the end of the standard 27 bytes.

      while (offset + 2 <= bytes.length) {
        pressures.add(buf.getInt16(offset, Endian.little));
        offset += 2;
      }
    }

    return CollarPacket._(
      packetType: packetType,
      timestampUs: buf.getUint32(1, Endian.little),
      pressures: pressures,
      byte7: bytes[7],
      accelX: buf.getInt16(8, Endian.little),
      accelY: buf.getInt16(10, Endian.little),
      accelZ: buf.getInt16(12, Endian.little),
      gyroX: buf.getInt16(14, Endian.little),
      gyroY: buf.getInt16(16, Endian.little),
      gyroZ: buf.getInt16(18, Endian.little),
      temperatureRaw: buf.getInt16(20, Endian.little),
      batteryMv: buf.getUint16(22, Endian.little),
      batteryPercent: bytes[24],
      crc16: buf.getUint16(25, Endian.little),
      crcValid: crcValid,
      receivedAt: receivedAt ?? DateTime.now(),
    );
  }

  /// Create test packet for unit testing
  factory CollarPacket.mock({
    int packetType = 0xF1,
    int timestampUs = 10000000, // 10 seconds in microseconds
    int pressure = 26000,
    int quality = 100,
    int accelX = 0,
    int accelY = 0,
    int accelZ = 16384, // 1g on Z axis
    int temperatureRaw = 500,
    int batteryMv = 3700,
    int batteryPercent = 75,
  }) {
    final bytes = ByteData(27);
    bytes.setUint8(0, packetType);
    bytes.setUint32(1, timestampUs, Endian.little);
    bytes.setInt16(5, pressure, Endian.little);
    bytes.setUint8(7, quality);
    bytes.setInt16(8, accelX, Endian.little);
    bytes.setInt16(10, accelY, Endian.little);
    bytes.setInt16(12, accelZ, Endian.little);
    bytes.setInt16(14, 0, Endian.little);
    bytes.setInt16(16, 0, Endian.little);
    bytes.setInt16(18, 0, Endian.little);
    bytes.setInt16(20, temperatureRaw, Endian.little);
    bytes.setUint16(22, batteryMv, Endian.little);
    bytes.setUint8(24, batteryPercent);

    // Calculate and set CRC
    final crc = CrcUtils.crc16Ccitt(bytes.buffer.asUint8List().sublist(0, 25));
    bytes.setUint16(25, crc, Endian.little);

    return CollarPacket.fromBytes(bytes.buffer.asUint8List());
  }

  @override
  String toString() {
    final mode = isStandardMode
        ? 'STD'
        : isHighResMode
        ? 'HR'
        : 'BAT';
    return 'CollarPacket($mode, ts=$timestampUs us, Samples=${pressures.length}, P=$pressure, T=${temperatureCelsius.toStringAsFixed(1)}°C, '
        'Batt=$batteryPercent%, CRC=${crcValid ? '✓' : '✗'})';
  }

  /// Convert to JSON for logging/debugging
  Map<String, dynamic> toJson() => {
    'packet_type': '0x${packetType.toRadixString(16).toUpperCase()}',
    'mode': isStandardMode
        ? 'STANDARD'
        : isHighResMode
        ? 'HIGH-RES'
        : 'BATTERY',
    'timestamp_us': timestampUs,
    'timestamp_ms': timestampUs ~/ 1000, // For backward compatibility
    'pressures': pressures,
    'pressure_first': pressure,
    'quality': quality,
    'status_flags': '0x${statusFlags.toRadixString(16).padLeft(2, '0')}',
    'accel': {'x': accelX, 'y': accelY, 'z': accelZ},
    'gyro': {'x': gyroX, 'y': gyroY, 'z': gyroZ},
    'temperature_raw': temperatureRaw,
    'temperature_celsius': temperatureCelsius,
    'battery_mv': batteryMv,
    'battery_percent': batteryPercent,
    'crc16': '0x${crc16.toRadixString(16).padLeft(4, '0')}',
    'crc_valid': crcValid,
    'received_at': receivedAt.toIso8601String(),
    'is_valid': isValid,
  };
}

/// Exception: Packet too short
class PacketTooShortException implements Exception {
  final int actual;
  final int expected;

  PacketTooShortException(this.actual, this.expected);

  @override
  String toString() => 'Packet too short: $actual bytes (expected $expected)';
}

/// Exception: Invalid packet type
class InvalidPacketTypeException implements Exception {
  final int packetType;

  InvalidPacketTypeException(this.packetType);

  @override
  String toString() =>
      'Invalid packet type: 0x${packetType.toRadixString(16).toUpperCase()} '
      '(expected 0xF1, 0xF2, or 0xB1)';
}

/// Timestamp validator for detecting packet loss
class TimestampValidator {
  int? _lastTimestamp;
  int _packetLossCount = 0;
  int _totalPackets = 0;

  /// Validate timestamp and detect packet loss
  ///
  /// Returns:
  /// - Number of packets lost (0 = no loss, >0 = packets lost)
  int validate(int timestamp, {required int expectedDeltaMs}) {
    _totalPackets++;

    if (_lastTimestamp == null) {
      _lastTimestamp = timestamp;
      return 0;
    }

    final actualDelta = timestamp - _lastTimestamp!;
    _lastTimestamp = timestamp;

    // Check for timestamp rollover (every ~49 days)
    if (actualDelta < 0) {
      // Rollover detected, can't detect loss
      return 0;
    }

    // Allow ±20% jitter
    final minDelta = (expectedDeltaMs * 0.8).round();
    final maxDelta = (expectedDeltaMs * 1.2).round();

    if (actualDelta < minDelta || actualDelta > maxDelta) {
      // Estimate packet loss
      final packetsLost = (actualDelta / expectedDeltaMs).round() - 1;
      if (packetsLost > 0) {
        _packetLossCount += packetsLost;
        return packetsLost;
      }
    }

    return 0;
  }

  /// Get packet loss statistics
  Map<String, dynamic> get statistics => {
    'total_packets': _totalPackets,
    'packets_lost': _packetLossCount,
    'loss_rate': _totalPackets > 0 ? _packetLossCount / _totalPackets : 0.0,
  };

  void reset() {
    _lastTimestamp = null;
    _packetLossCount = 0;
    _totalPackets = 0;
  }
}
