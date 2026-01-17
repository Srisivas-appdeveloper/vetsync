// lib/presentation/controllers/monitoring_controller.dart
import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../data/services/ble_service.dart';
import '../../services/bcg_service.dart';
import '../../data/models/models.dart';
import 'dart:async';
import 'dart:collection';
import 'package:fl_chart/fl_chart.dart';
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

  // Waveform Visualization
  static const int maxWaveformSamples = 1000; // 5s @ 200Hz or 10s @ 100Hz
  final RxList<FlSpot> waveformSpots = RxList<FlSpot>([]);
  final Queue<double> _waveformBuffer = Queue<double>();

  // Connection Watchdog
  DateTime? _lastDataTime;
  Timer? _watchdogTimer;
  final RxBool isDataActive = false.obs; // True if receiving data recently
  StreamSubscription? _rawStreamSubscription;

  // Computed
  Rx<FirmwareMode> get currentMode => _bleService.currentMode;
  bool get isStandardMode => currentMode.value == FirmwareMode.filtered;
  bool get isHighResMode => currentMode.value == FirmwareMode.raw;
  bool get isConnected => _bleService.isConnected.value;

  @override
  void onInit() {
    super.onInit();

    // Listen to raw data stream
    _rawStreamSubscription = bcgService.rawDataStream.listen(
      _onRawDataReceived,
    );

    // Start watchdog to update active status
    _startWatchdog();
  }

  @override
  void onClose() {
    _rawStreamSubscription?.cancel();
    _watchdogTimer?.cancel();
    super.onClose();
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

  // --- Waveform Logic ---

  void _onRawDataReceived(List<int> samples) {
    _lastDataTime = DateTime.now();
    if (!isDataActive.value) isDataActive.value = true;

    // Debug logging (only log occasionally to avoid spam)
    if (_waveformBuffer.isEmpty || _waveformBuffer.length % 100 == 0) {
      print('[MON] 📊 Waveform data: ${samples.length} samples, buffer size: ${_waveformBuffer.length}, first value: ${samples.isNotEmpty ? samples.first : "empty"}');
    }

    // Adjust buffer for raw samples depending on resolution
    // Standard: 100Hz, High-Res: 128Hz
    // We just plot them sequentially for now

    for (final sample in samples) {
      _waveformBuffer.add(sample.toDouble());
      if (_waveformBuffer.length > maxWaveformSamples) {
        _waveformBuffer.removeFirst();
      }
    }

    _updateWaveformSpots();
  }

  void _updateWaveformSpots() {
    // Create spots from buffer
    // X-axis: simply index or relative time
    final spots = <FlSpot>[];
    int index = 0;

    // Downsample for rendering performance if needed, but for 1000 points it's fine
    // Or just take last N points

    for (final val in _waveformBuffer) {
      spots.add(FlSpot(index.toDouble(), val));
      index++;
    }

    waveformSpots.assignAll(spots);
  }

  void _startWatchdog() {
    _watchdogTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (_lastDataTime == null) {
        isDataActive.value = false;
        return;
      }

      final diff = DateTime.now().difference(_lastDataTime!);
      // Increased timeout from 5s to 15s to match BLE service improvements
      if (diff.inSeconds > 15) {
        isDataActive.value = false;
      } else {
        isDataActive.value = true;
      }
    });
  }
}
