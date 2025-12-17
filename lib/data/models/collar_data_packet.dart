import 'dart:typed_data';
import 'package:vetsync/core/constants/ble_constants.dart';

class CollarDataPacket {
  final int packetType; // 0xF1 = filtered, 0xF2 = raw
  final int timestampMs; // uint32

  // Vitals / Calculated
  final int heartRateBpm; // Not in packet (App calculated)
  final int respiratoryRateBpm; // Not in packet (App calculated)
  final double temperatureC;

  // Device Status
  final int batteryPercent;
  final int batteryMv;
  final int
  signalQuality; // Mapped from pressureQuality (Filtered) or Algo (Raw)
  final int statusFlags; // Only in Raw mode

  // Sensor values
  final int pressureFiltered;
  final int? pressureRaw;
  final List<int>? imuAccel; // [x, y, z]
  final List<int>? imuGyro; // [x, y, z]

  final DateTime receivedAt;
  final int crc16;

  CollarDataPacket({
    required this.packetType,
    required this.timestampMs,
    required this.heartRateBpm,
    required this.respiratoryRateBpm,
    required this.temperatureC,
    required this.batteryPercent,
    required this.batteryMv,
    required this.signalQuality,
    required this.pressureFiltered,
    this.statusFlags = 0,
    required this.crc16,
    this.pressureRaw,
    this.imuAccel,
    this.imuGyro,
    DateTime? receivedAt,
  }) : receivedAt = receivedAt ?? DateTime.now();

  bool get isFiltered => packetType == 0xF1;
  bool get isRaw => packetType == 0xF2;

  // Status Flag Helpers (Spec Section 6.4)
  bool get isCharging => (statusFlags & 0x01) != 0; // Bit 0
  bool get isLowBattery => (statusFlags & 0x02) != 0; // Bit 1
  bool get hasSensorError => (statusFlags & 0x04) != 0; // Bit 2
  bool get isMotionDetected => (statusFlags & 0x08) != 0; // Bit 3

  factory CollarDataPacket.fromBytes(Uint8List data) {
    if (data.isEmpty) {
      throw FormatException('Empty packet data');
    }

    final packetType = data[0];

    // Both packets are 27 bytes per Spec Section 6.1 & 6.2
    if (data.length < 27) {
      throw FormatException(
        'Packet too short: ${data.length} bytes (Expected 27)',
      );
    }

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

  /// Parse STANDARD Mode Packet (0xF1) - Spec Section 6.1
  static CollarDataPacket _parseFilteredPacket(Uint8List data) {
    final buffer = ByteData.view(data.buffer);

    // Byte 0: Packet Type
    // Byte 1-4: Timestamp (uint32)
    final timestampMs = buffer.getUint32(1, Endian.little);

    // Byte 5-7: Pressure (int16 + uint8)
    final pressureFiltered = buffer.getInt16(5, Endian.little);
    final pressureQuality = data[7]; // 0-100

    // Byte 8-19: IMU (6 x int16)
    final accelX = buffer.getInt16(8, Endian.little);
    final accelY = buffer.getInt16(10, Endian.little);
    final accelZ = buffer.getInt16(12, Endian.little);
    final gyroX = buffer.getInt16(14, Endian.little);
    final gyroY = buffer.getInt16(16, Endian.little);
    final gyroZ = buffer.getInt16(18, Endian.little);

    // Byte 20-21: Environmental (int16)
    // Spec doesn't define scaling, assuming 100 like previous code or raw
    // Usually PMIC temp is raw. Assuming /100.0 based on typical implementation
    final tempRaw = buffer.getInt16(20, Endian.little);

    // Byte 22-24: Device Status (uint16 + uint8)
    final batteryMv = buffer.getUint16(22, Endian.little);
    final batteryPercent = data[24];

    // Byte 25-26: Checksum
    final crc = buffer.getUint16(25, Endian.little);

    return CollarDataPacket(
      packetType: data[0],
      timestampMs: timestampMs,
      pressureFiltered: pressureFiltered,
      pressureRaw: null,
      // Standard packet does NOT contain HR/RR in this Spec (Source 122-143)
      // It only has pressure_filtered. The App must still calculate HR/RR
      // or the Firmware spec needs to change to include them.
      // Setting to 0 as placeholders.
      heartRateBpm: 0,
      respiratoryRateBpm: 0,
      temperatureC: tempRaw / 100.0,
      batteryPercent: batteryPercent,
      batteryMv: batteryMv,
      signalQuality: pressureQuality,
      statusFlags: 0, // Not in Standard Packet
      crc16: crc,
      imuAccel: [accelX, accelY, accelZ],
      imuGyro: [gyroX, gyroY, gyroZ],
    );
  }

  /// Parse HIGH-RES Mode Packet (0xF2) - Spec Section 6.2
  static CollarDataPacket _parseRawPacket(Uint8List data) {
    final buffer = ByteData.view(data.buffer);

    // Byte 0: Packet Type
    // Byte 1-4: Timestamp (uint32)
    final timestampMs = buffer.getUint32(1, Endian.little);

    // Byte 5-6: Pressure Raw (int16)
    final pressureRaw = buffer.getInt16(5, Endian.little);

    // Byte 7-18: IMU Raw (6 x int16)
    final accelX = buffer.getInt16(7, Endian.little);
    final accelY = buffer.getInt16(9, Endian.little);
    final accelZ = buffer.getInt16(11, Endian.little);
    final gyroX = buffer.getInt16(13, Endian.little);
    final gyroY = buffer.getInt16(15, Endian.little);
    final gyroZ = buffer.getInt16(17, Endian.little);

    // Byte 19-20: Temp Raw
    final tempRaw = buffer.getInt16(19, Endian.little);

    // Byte 21-24: Device Status (uint16 + uint8 + uint8)
    final batteryMv = buffer.getUint16(21, Endian.little);
    final batteryPercent = data[23];
    final statusFlags = data[24];

    // Byte 25-26: Checksum
    final crc = buffer.getUint16(25, Endian.little);

    return CollarDataPacket(
      packetType: data[0],
      timestampMs: timestampMs,
      pressureFiltered: 0,
      pressureRaw: pressureRaw,
      heartRateBpm: 0, // Calculated by App Algo
      respiratoryRateBpm: 0, // Calculated by App Algo
      temperatureC: tempRaw / 100.0,
      batteryPercent: batteryPercent,
      batteryMv: batteryMv,
      signalQuality: 100, // Calculated by App Algo
      statusFlags: statusFlags,
      crc16: crc,
      imuAccel: [accelX, accelY, accelZ],
      imuGyro: [gyroX, gyroY, gyroZ],
    );
  }
}
