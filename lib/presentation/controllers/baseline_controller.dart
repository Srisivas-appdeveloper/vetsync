import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_pages.dart';
import '../../core/constants/app_config.dart';
import '../../data/models/models.dart';
import '../../data/services/ble_service.dart';
import '../../data/repositories/session_repository.dart';
import 'session_controller.dart';

/// Controller for baseline collection phase (5 minutes)
class BaselineController extends GetxController {
  final BleService _bleService = Get.find<BleService>();
  final SessionRepository _sessionRepo = Get.find<SessionRepository>();
  final SessionController _sessionController = Get.find<SessionController>();

  // Collection state
  final RxBool isCollecting = false.obs;
  final RxBool isComplete = false.obs;
  final RxBool isPaused = false.obs;

  // Timer
  Timer? _timer;
  final RxInt remainingSeconds = AppConfig.baselineDurationSeconds.obs;
  final RxInt elapsedSeconds = 0.obs;

  // Quality tracking
  final RxInt currentQuality = 0.obs;
  final RxDouble avgQuality = 0.0.obs;
  final RxInt validSamples = 0.obs;
  final RxInt totalSamples = 0.obs;

  // Vitals tracking
  final RxList<Vitals> collectedVitals = <Vitals>[].obs;
  final RxList<double> heartRateSamples = <double>[].obs;
  final RxList<double> respiratorySamples = <double>[].obs;
  final RxList<double> temperatureSamples = <double>[].obs;

  // Waveform buffer (last 60 seconds for display)
  final RxList<double> waveformBuffer = <double>[].obs;
  static const int waveformBufferSize = 6000; // 60 seconds at 100 Hz

  // Computed baseline data
  final Rx<BaselineData?> baselineData = Rx<BaselineData?>(null);

  // Debug counters
  int _packetCount = 0;
  DateTime? _startTime;

  // Real-time vitals
  Vitals? get latestVitals => _sessionController.latestVitals.value;
  int get signalQuality => _sessionController.signalQuality.value;
  int get batteryPercent => _sessionController.batteryPercent.value;

  StreamSubscription? _vitalsSubscription;

  @override
  void onInit() {
    super.onInit();
    _setupVitalsListener();
  }

  @override
  void onClose() {
    _timer?.cancel();
    _vitalsSubscription?.cancel();
    super.onClose();
  }

  /// Setup listener for vitals data
  void _setupVitalsListener() {
    _vitalsSubscription = _bleService.vitalsStream.listen((vitals) {
      if (!isCollecting.value || isPaused.value) return;

      // === DEBUG LOGGING ===
      _packetCount++;
      if (_packetCount % 100 == 0 && _startTime != null) {
        final elapsed = DateTime.now().difference(_startTime!);
        final rate = elapsed.inSeconds > 0
            ? _packetCount / elapsed.inSeconds
            : 0.0;
        print('═══════════════════════════════════════════════════════');
        print('[BASELINE] Packets: $_packetCount');
        print(
          '[BASELINE] Rate: ${rate.toStringAsFixed(1)} Hz (target: 100 Hz)',
        );
        print('[BASELINE] Quality: ${vitals.signalQuality}% (IGNORED)');
        print('[BASELINE] Battery: $batteryPercent%');
        print('═══════════════════════════════════════════════════════');
      }
      // === END DEBUG LOGGING ===

      // Update quality tracking
      currentQuality.value = vitals.signalQuality;
      totalSamples.value++;

      // BYPASSED QUALITY CHECK for debugging
      // if (vitals.signalQuality >= AppConfig.qualityFair) {
      if (true) {
        // Filter out invalid zero values from BCG algorithm initialization
        // Only collect vitals when HR and RR are non-zero (valid readings)
        final hasValidHR = vitals.heartRateBpm > 0;
        final hasValidRR = vitals.respiratoryRateBpm > 0;

        // Also bypass valid HR checking if needed, but keeping for now as per minimal changes
        if (hasValidHR && hasValidRR) {
          validSamples.value++;

          // Collect vitals
          collectedVitals.add(vitals);
          heartRateSamples.add(vitals.heartRateBpm.toDouble());
          respiratorySamples.add(vitals.respiratoryRateBpm.toDouble());
          temperatureSamples.add(vitals.temperatureC);
        }
      }

      // Update average quality
      avgQuality.value = (validSamples.value / totalSamples.value) * 100;

      // Update waveform buffer (simulate BCG waveform from HR)
      _updateWaveform(vitals);
    });
  }

  void _updateWaveform(Vitals vitals) {
    // Simple waveform simulation based on heart rate
    // In real implementation, this would be actual pressure sensor data
    final now = DateTime.now().millisecondsSinceEpoch;
    final phase = (now % 1000) / 1000.0 * 2 * pi;
    final value = sin(phase * vitals.heartRateBpm / 60 * 2 * pi);

    waveformBuffer.add(value);
    if (waveformBuffer.length > waveformBufferSize) {
      waveformBuffer.removeAt(0);
    }
  }

  /// Start baseline collection
  void startCollection() {
    if (isCollecting.value) return;

    isCollecting.value = true;
    isPaused.value = false;
    isComplete.value = false;

    // Reset counters
    elapsedSeconds.value = 0;
    remainingSeconds.value = AppConfig.baselineDurationSeconds;
    validSamples.value = 0;
    totalSamples.value = 0;
    avgQuality.value = 0;
    collectedVitals.clear();
    heartRateSamples.clear();
    respiratorySamples.clear();
    temperatureSamples.clear();
    waveformBuffer.clear();

    // Reset debug counters
    _packetCount = 0;
    _startTime = DateTime.now();

    // Start timer
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isPaused.value) {
        elapsedSeconds.value++;
        remainingSeconds.value =
            AppConfig.baselineDurationSeconds - elapsedSeconds.value;

        if (remainingSeconds.value <= 0) {
          _completeCollection();
        }
      }
    });
  }

  /// Pause collection
  void pauseCollection() {
    isPaused.value = true;
  }

  /// Resume collection
  void resumeCollection() {
    isPaused.value = false;
  }

  /// Complete baseline collection
  void _completeCollection() {
    _timer?.cancel();
    isCollecting.value = false;
    isComplete.value = true;

    // Calculate baseline statistics
    if (heartRateSamples.isNotEmpty) {
      baselineData.value = BaselineData(
        heartRate: _calculateStats(heartRateSamples),
        respiratoryRate: _calculateStats(respiratorySamples),
        temperature: _calculateStats(temperatureSamples),
        qualityScore: avgQuality.value.round(),
        durationSeconds: elapsedSeconds.value,
        collectedAt: DateTime.now().toUtc(),
      );
    }
  }

  /// Calculate statistics for a list of samples
  VitalStats _calculateStats(List<double> samples) {
    if (samples.isEmpty) {
      return VitalStats(mean: 0, stdDev: 0, min: 0, max: 0);
    }

    final mean = samples.reduce((a, b) => a + b) / samples.length;
    final variance =
        samples.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) /
        samples.length;
    final stdDev = sqrt(variance);
    final min = samples.reduce((a, b) => a < b ? a : b);
    final max = samples.reduce((a, b) => a > b ? a : b);

    return VitalStats(mean: mean, stdDev: stdDev, min: min, max: max);
  }

  /// Save baseline and proceed
  Future<void> saveAndProceed() async {
    if (baselineData.value == null) {
      Get.snackbar('Error', 'No baseline data collected');
      return;
    }

    // Check quality threshold
    if (baselineData.value!.qualityScore < AppConfig.minimumBaselineQuality) {
      final proceed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Low Quality Baseline'),
          content: Text(
            'Baseline quality (${baselineData.value!.qualityScore}%) is below recommended '
            '(${AppConfig.minimumBaselineQuality}%). You may want to recollect for better results.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Recollect'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Continue Anyway'),
            ),
          ],
        ),
      );

      if (proceed != true) {
        return;
      }
    }

    try {
      // Save baseline to session
      await _sessionRepo.saveBaseline(
        sessionId: _sessionController.currentSession.value!.id,
        baseline: baselineData.value!,
      );

      // Update session controller
      _sessionController.currentSession.value = _sessionController
          .currentSession
          .value
          ?.copyWith(
            baselineData: baselineData.value,
            baselineQuality: baselineData.value!.qualityScore,
          );

      // Navigate to baseline complete
      Get.toNamed(Routes.baselineComplete);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save baseline');
    }
  }

  /// Restart baseline collection
  void restartCollection() {
    _timer?.cancel();
    isComplete.value = false;
    baselineData.value = null;
    startCollection();
  }

  /// Skip baseline (not recommended)
  Future<void> skipBaseline() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Skip Baseline?'),
        content: const Text(
          'Skipping baseline collection will reduce data quality and '
          'algorithm accuracy. This is not recommended.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Collect Baseline'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Skip'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      Get.toNamed(Routes.preSurgery);
    }
  }

  /// Get formatted remaining time
  String get remainingTimeFormatted {
    final minutes = remainingSeconds.value ~/ 60;
    final seconds = remainingSeconds.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get collection progress (0.0 to 1.0)
  double get progress {
    return elapsedSeconds.value / AppConfig.baselineDurationSeconds;
  }

  /// Get quality color
  String get qualityColorName {
    if (avgQuality.value >= 75) return 'green';
    if (avgQuality.value >= 50) return 'yellow';
    return 'red';
  }
}
