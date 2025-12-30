import 'package:get/get.dart';

class CalibrationService extends GetxService {
  bool get hasCustomCalibration => false;
  double? get calibrationQuality => 0.0;

  Future<void> loadSavedCalibration() async {}
  Future<bool> downloadAndApplyCalibration() async {
    return false;
  }
}
