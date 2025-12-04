// lib/core/constants/ble_constants.dart
class BlePacketTypes {
  BlePacketTypes._();

  static const int filteredData = 0xF1; // 34 bytes
  static const int rawData = 0xF2; // 27 bytes
  static const int pressure = 0x01; // 9 bytes
  static const int imu = 0x02;
  static const int battery = 0x03;
  static const int temperature = 0x04;
  static const int error = 0xFE;

  // Command IDs
  static const int cmdSwitchMode = 0x10;
  static const int respModeConfirm = 0x11;

  // Mode Values
  static const int modeFiltered = 0x01;
  static const int modeRaw = 0x02;
}

class BleStatusFlags {
  BleStatusFlags._();

  static const int charging = 1 << 0; // 0x01
  static const int lowBattery = 1 << 1; // 0x02
  static const int sensorError = 1 << 2; // 0x04
  static const int motionDetected = 1 << 3; // 0x08
  static const int tempWarning = 1 << 4; // 0x10
  static const int bleConnected = 1 << 5; // 0x20
  static const int modeRaw = 1 << 6; // 0x40
  static const int calibration = 1 << 7; // 0x80
}
