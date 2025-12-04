// lib/data/models/collar_data_packet.dart
import 'dart:typed_data';

import 'package:vetsync/core/constants/ble_constants.dart';

class FilteredDataPacket {
  final int packetType; // 0xF1
  final int timestampMs; // uint32
  final int sequenceNumber; // uint16

  // Pressure (filtered, 100 Hz)
  final double pressureFiltered; // float32, Pascals
  final int pressureQuality; // uint8, 0-100

  // IMU (100 Hz decimated)
  final double accelX; // float32, m/s²
  final double accelY;
  final double accelZ;
  final double gyroX; // float32, °/s
  final double gyroY;
  final double gyroZ;

  // Environmental
  final double temperatureC; // int16 / 100

  // Battery
  final int batteryMv; // uint16
  final int batteryPercent; // uint8
  final int statusFlags; // uint8

  final int crc16; // uint16

  FilteredDataPacket({
    required this.packetType,
    required this.timestampMs,
    required this.sequenceNumber,
    required this.pressureFiltered,
    required this.pressureQuality,
    required this.accelX,
    required this.accelY,
    required this.accelZ,
    required this.gyroX,
    required this.gyroY,
    required this.gyroZ,
    required this.temperatureC,
    required this.batteryMv,
    required this.batteryPercent,
    required this.statusFlags,
    required this.crc16,
  });

  factory FilteredDataPacket.fromBytes(Uint8List bytes) {
    if (bytes.length != 34) {
      throw ArgumentError(
        'FilteredDataPacket must be 34 bytes, got ${bytes.length}',
      );
    }

    final buffer = bytes.buffer;
    final data = ByteData.view(buffer);

    // Use little-endian byte order (ARM default)
    return FilteredDataPacket(
      packetType: data.getUint8(0),
      timestampMs: data.getUint32(1, Endian.little),
      sequenceNumber: data.getUint16(5, Endian.little),
      pressureFiltered: data.getFloat32(7, Endian.little),
      pressureQuality: data.getUint8(11),
      accelX: data.getFloat32(12, Endian.little),
      accelY: data.getFloat32(16, Endian.little),
      accelZ: data.getFloat32(20, Endian.little),
      gyroX: data.getInt16(24, Endian.little) / 100.0,
      gyroY: data.getInt16(26, Endian.little) / 100.0,
      gyroZ: data.getInt16(28, Endian.little) / 100.0,
      temperatureC: data.getInt16(30, Endian.little) / 100.0,
      batteryMv: data.getUint16(32, Endian.little),
      batteryPercent: data.getUint8(34),
      statusFlags: data.getUint8(35),
      crc16: data.getUint16(36, Endian.little),
    );
  }

  bool get isCharging => (statusFlags & BleStatusFlags.charging) != 0;
  bool get isLowBattery => (statusFlags & BleStatusFlags.lowBattery) != 0;
  bool get hasSensorError => (statusFlags & BleStatusFlags.sensorError) != 0;
  bool get isRawMode => (statusFlags & BleStatusFlags.modeRaw) != 0;
}
