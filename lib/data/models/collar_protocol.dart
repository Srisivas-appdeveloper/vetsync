import 'dart:typed_data';

/// BLE Command IDs
class CollarCommandId {
  static const int switchMode = 0x10;
  static const int startStream = 0x12;
  static const int stopStream = 0x13;
  static const int getInfo = 0x14;
  static const int getBattery = 0x15;
  static const int reboot = 0x31;
}

/// BLE Response IDs
class CollarResponseId {
  static const int modeSwitch = 0x11;
  static const int deviceInfo = 0xA0;
  static const int battery = 0xB1;
  static const int ack = 0xAA;
}

/// Command to send to collar
class CollarCommand {
  final int commandId;
  final List<int> parameters;

  CollarCommand({required this.commandId, this.parameters = const []});

  /// Convert to bytes for transmission
  Uint8List toBytes() {
    // Calculate total length (Command ID + Parameters + Checksum)
    // Note: The protocol images show different lengths for different commands.
    // We'll construct the payload first, then calculate checksum.

    final payload = <int>[commandId, ...parameters];

    // Calculate checksum (XOR of all bytes)
    int checksum = 0;
    for (final byte in payload) {
      checksum ^= byte;
    }

    return Uint8List.fromList([...payload, checksum]);
  }

  /// Switch operating mode
  static CollarCommand switchMode({
    required int targetMode, // 0x01 = STANDARD, 0x02 = HIGH-RES
  }) {
    return CollarCommand(
      commandId: CollarCommandId.switchMode,
      parameters: [targetMode],
    );
  }

  /// Start data streaming
  static CollarCommand startStream() {
    return CollarCommand(commandId: CollarCommandId.startStream);
  }

  /// Stop data streaming
  static CollarCommand stopStream() {
    return CollarCommand(commandId: CollarCommandId.stopStream);
  }

  /// Get device info
  static CollarCommand getInfo() {
    return CollarCommand(commandId: CollarCommandId.getInfo);
  }

  /// Get battery status
  static CollarCommand getBattery() {
    return CollarCommand(commandId: CollarCommandId.getBattery);
  }

  /// Reboot device
  static CollarCommand reboot() {
    return CollarCommand(commandId: CollarCommandId.reboot);
  }
}

/// Base response from collar
abstract class CollarResponse {
  final int responseId;

  CollarResponse(this.responseId);

  static CollarResponse? fromBytes(Uint8List bytes) {
    if (bytes.isEmpty) return null;

    final responseId = bytes[0];

    try {
      switch (responseId) {
        case CollarResponseId.modeSwitch:
          return ModeSwitchResponse.fromBytes(bytes);
        case CollarResponseId.deviceInfo:
          return DeviceInfoResponse.fromBytes(bytes);
        case CollarResponseId.battery:
          return BatteryResponse.fromBytes(bytes);
        case CollarResponseId.ack:
          return AckResponse.fromBytes(bytes);
        default:
          return null;
      }
    } catch (e) {
      print('Error parsing response 0x${responseId.toRadixString(16)}: $e');
      return null;
    }
  }
}

/// Response to mode switch command
class ModeSwitchResponse extends CollarResponse {
  final int currentMode;
  final bool success;

  ModeSwitchResponse({required this.currentMode, required this.success})
    : super(CollarResponseId.modeSwitch);

  factory ModeSwitchResponse.fromBytes(Uint8List bytes) {
    // Structure: [ID, CurrentMode, Success, Checksum]
    if (bytes.length < 4)
      throw Exception('Invalid mode switch response length');

    return ModeSwitchResponse(currentMode: bytes[1], success: bytes[2] == 0x01);
  }
}

/// Device information response
class DeviceInfoResponse extends CollarResponse {
  final String deviceId;
  final String macAddress;
  final String firmwareVersion;
  final int batteryPercent;
  final int currentMode;

  DeviceInfoResponse({
    required this.deviceId,
    required this.macAddress,
    required this.firmwareVersion,
    required this.batteryPercent,
    required this.currentMode,
  }) : super(CollarResponseId.deviceInfo);

  factory DeviceInfoResponse.fromBytes(Uint8List bytes) {
    // Structure: [ID, DeviceID(8), MAC(6), FW_Major, FW_Minor, FW_Patch, HW_Ver, Battery, Mode, Checksum]
    // Total: 1 + 8 + 6 + 1 + 1 + 1 + 1 + 1 + 1 + 1 = 22 bytes
    if (bytes.length < 22)
      throw Exception('Invalid device info response length');

    final data = ByteData.view(bytes.buffer);

    // Parse Device ID (null terminated string)
    final deviceIdBytes = bytes.sublist(1, 9);
    final deviceId = String.fromCharCodes(
      deviceIdBytes.takeWhile((byte) => byte != 0),
    );

    // Parse MAC Address
    final macBytes = bytes.sublist(9, 15);
    final macAddress = macBytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join(':')
        .toUpperCase();

    // Parse Firmware Version
    final major = bytes[15];
    final minor = bytes[16];
    final patch = bytes[17];
    final firmwareVersion = '$major.$minor.$patch';

    // Parse Battery and Mode
    final batteryPercent = bytes[19];
    final currentMode = bytes[20];

    return DeviceInfoResponse(
      deviceId: deviceId,
      macAddress: macAddress,
      firmwareVersion: firmwareVersion,
      batteryPercent: batteryPercent,
      currentMode: currentMode,
    );
  }
}

/// Battery status response
class BatteryResponse extends CollarResponse {
  final int batteryPercent;
  final bool isCharging;

  BatteryResponse({required this.batteryPercent, required this.isCharging})
    : super(CollarResponseId.battery);

  factory BatteryResponse.fromBytes(Uint8List bytes) {
    // Structure assumed from context (0xB1 packet)
    // Let's assume: [ID, Battery%, ChargingStatus, Checksum]
    if (bytes.length < 2) throw Exception('Invalid battery response length');

    return BatteryResponse(
      batteryPercent: bytes[1],
      isCharging: bytes.length > 2 ? bytes[2] == 1 : false,
    );
  }
}

/// Generic ACK response
class AckResponse extends CollarResponse {
  AckResponse() : super(CollarResponseId.ack);

  factory AckResponse.fromBytes(Uint8List bytes) {
    return AckResponse();
  }
}
