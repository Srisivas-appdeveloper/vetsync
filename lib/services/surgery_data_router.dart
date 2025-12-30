import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class SurgeryDataRouter extends GetxService {
  Future<void> initialize({
    required String sessionId,
    required String laptopIp,
    required int laptopPort,
    required BluetoothCharacteristic dataCharacteristic,
  }) async {}

  Future<void> shutdown() async {}
}
