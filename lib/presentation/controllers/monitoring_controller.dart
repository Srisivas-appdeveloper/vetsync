// lib/presentation/controllers/monitoring_controller.dart
import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../data/services/ble_service.dart';
import '../../services/bcg_service.dart';
import '../../data/models/models.dart';
import '../../core/algorithms/bcg_algorithm.dart';

class MonitoringController extends GetxController {
  final BleService _bleService = Get.find<BleService>();

  // Expose service for UI listening
  BcgService get bcgService => _bleService.bcgService;

  // Observables linked to BleService
  BcgResult? get lastBcgResult => _bleService.bcgService.latestResult;
  double get temperature => _bleService.bcgService.temperatureCelsius;
  int get signalQuality => _bleService.signalQuality.value;

  Rx<BleConnectionState> get connectionState => _bleService.connectionState;

  // Local UI state
  final RxBool isStreaming = false.obs;

  // Computed
  Rx<FirmwareMode> get currentMode => _bleService.currentMode;
  bool get isStandardMode => currentMode.value == FirmwareMode.filtered;
  bool get isHighResMode => currentMode.value == FirmwareMode.raw;
  bool get isConnected => _bleService.isConnected;

  @override
  void onInit() {
    super.onInit();
    // Listen to changes to trigger UI updates if needed
    // The VitalSignsDisplay handles its own updates if we pass reactive values or trigger rebuilds
  }

  // Actions

  Future<void> toggleStreaming() async {
    // In current protocol, streaming starts automatically or via command.
    // If we have a start/stop command:
    // if (isStreaming.value) {
    //   await _bleService.sendCommand(CollarCommand.stopStream());
    //   isStreaming.value = false;
    // } else {
    //   await _bleService.sendCommand(CollarCommand.startStream());
    //   isStreaming.value = true;
    // }

    // For now, assume streaming is active when connected or toggle dummy state
    isStreaming.value = !isStreaming.value;
  }

  Future<void> switchMode() async {
    try {
      final newMode = isStandardMode ? FirmwareMode.raw : FirmwareMode.filtered;
      await _bleService.switchMode(newMode);
      Get.snackbar(
        'Success',
        'Switched to ${newMode == FirmwareMode.raw ? 'HIGH-RES' : 'STANDARD'} mode',
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to switch mode: $e');
    }
  }

  void resetService() {
    _bleService.bcgService.reset();
  }

  void connectToDevice(BluetoothDevice device) {
    // This might be handled by a separate scan controller,
    // but if we are here we assume we might be viewing an active session
  }
}
