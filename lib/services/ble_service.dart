import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEService extends GetxService {
  BluetoothCharacteristic? get dataCharacteristic => null;

  Future<void> sendCommand(int command) async {}
  Future<void> disconnect() async {}
}
