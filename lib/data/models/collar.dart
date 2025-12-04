import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'enums.dart';

/// Collar device model
class Collar {
  final String id;
  final String serialNumber;
  final String? firmwareVersion;
  final int batteryPercent;
  final CollarStatus status;
  final String? currentSessionId;
  final String? lastUsedByAnimalId;
  final DateTime? lastSeenAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Collar({
    required this.id,
    required this.serialNumber,
    this.firmwareVersion,
    required this.batteryPercent,
    required this.status,
    this.currentSessionId,
    this.lastUsedByAnimalId,
    this.lastSeenAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if collar is available for use
  bool get isAvailable => status == CollarStatus.available;

  /// Check if battery is low
  bool get isBatteryLow => batteryPercent <= 20;

  /// Check if battery is critical
  bool get isBatteryCritical => batteryPercent <= 10;

  /// Get battery status message
  String? get batteryWarningMessage {
    if (batteryPercent <= 5) return 'Battery emergency! Replace immediately';
    if (batteryPercent <= 10) return 'Battery critical';
    if (batteryPercent <= 20) return 'Battery low';
    if (batteryPercent <= 35) return 'May not last full session';
    return null;
  }

  factory Collar.fromJson(Map<String, dynamic> json) {
    return Collar(
      id: json['collar_id'] as String? ?? json['id'] as String,
      serialNumber: json['serial_number'] as String,
      firmwareVersion: json['firmware_version'] as String?,
      batteryPercent: json['battery_percent'] as int? ?? 100,
      status: CollarStatus.fromString(json['status'] as String? ?? 'available'),
      currentSessionId: json['current_session_id'] as String?,
      lastUsedByAnimalId: json['last_used_by_animal_id'] as String?,
      lastSeenAt: json['last_seen_at'] != null
          ? DateTime.parse(json['last_seen_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'collar_id': id,
      'serial_number': serialNumber,
      'firmware_version': firmwareVersion,
      'battery_percent': batteryPercent,
      'status': status.value,
      'current_session_id': currentSessionId,
      'last_used_by_animal_id': lastUsedByAnimalId,
      'last_seen_at': lastSeenAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Collar copyWith({
    String? id,
    String? serialNumber,
    String? firmwareVersion,
    int? batteryPercent,
    CollarStatus? status,
    String? currentSessionId,
    String? lastUsedByAnimalId,
    DateTime? lastSeenAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Collar(
      id: id ?? this.id,
      serialNumber: serialNumber ?? this.serialNumber,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      status: status ?? this.status,
      currentSessionId: currentSessionId ?? this.currentSessionId,
      lastUsedByAnimalId: lastUsedByAnimalId ?? this.lastUsedByAnimalId,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'Collar(id: $id, serial: $serialNumber, battery: $batteryPercent%)';
}

/// Discovered collar from BLE scan
class DiscoveredCollar {
  final BluetoothDevice device;
  final int rssi;
  final String collarId;
  final int? batteryPercent;
  final String? firmwareVersion;
  final DateTime discoveredAt;

  DiscoveredCollar({
    required this.device,
    required this.rssi,
    required this.collarId,
    this.batteryPercent,
    this.firmwareVersion,
    DateTime? discoveredAt,
  }) : discoveredAt = discoveredAt ?? DateTime.now();

  /// Get signal strength enum
  SignalStrength get signalStrength => SignalStrength.fromRssi(rssi);

  /// Get signal strength as percentage (approximate)
  int get signalPercent {
    // RSSI typically ranges from -30 (excellent) to -100 (poor)
    // Map to 0-100%
    const minRssi = -100;
    const maxRssi = -30;
    final clamped = rssi.clamp(minRssi, maxRssi);
    return ((clamped - minRssi) / (maxRssi - minRssi) * 100).round();
  }

  /// Check if collar is close enough for connection
  bool get isInRange => rssi >= -80;

  /// Get status color based on signal strength
  String get statusColor {
    switch (signalStrength) {
      case SignalStrength.excellent:
        return 'green';
      case SignalStrength.good:
        return 'blue';
      case SignalStrength.fair:
        return 'yellow';
      case SignalStrength.poor:
        return 'red';
    }
  }

  @override
  String toString() =>
      'DiscoveredCollar(id: $collarId, rssi: $rssi, battery: $batteryPercent%)';
}
