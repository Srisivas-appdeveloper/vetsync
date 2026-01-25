import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_pages.dart';
import '../../app/themes/app_colors.dart';
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

  // Timer
  Timer? _timer;
  final RxInt remainingSeconds = AppConfig.baselineDurationSeconds.obs;
  final RxInt elapsedSeconds = 0.obs;
  int _targetDurationSeconds = AppConfig
      .baselineDurationSeconds; // Dynamic target that updates on extension
  DateTime?
  _lastExtensionTime; // Track when we last extended to prevent repeated snackbars

  // Quality tracking
  final RxInt currentQuality = 0.obs;
  final RxDouble avgQuality = 0.0.obs;
  final RxInt validSamples = 0.obs;
  final RxInt totalSamples = 0.obs;

  // Dynamic completion criteria
  final RxBool canComplete = false.obs;
  final RxDouble currentStability = 0.0.obs;
  final RxDouble currentHRConfidence = 0.0.obs;
  final RxString statusMessage = 'Waiting to start...'.obs;

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

  // No signal warning
  final RxBool showNoSignalWarning = false.obs;
  Timer? _noSignalCheckTimer;

  // Processing status for better user feedback
  final RxString processingStatus = 'Waiting for data...'.obs;
  final RxInt bufferedSamplesCount = 0.obs;

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
    _noSignalCheckTimer?.cancel();
    super.onClose();
  }

  /// Setup listener for vitals data
  void _setupVitalsListener() {
    _vitalsSubscription = _bleService.vitalsStream.listen((vitals) {
      if (!isCollecting.value) return;

      // === DEBUG LOGGING ===
      _packetCount++;

      // Update processing status for UI feedback
      if (_packetCount == 1) {
        processingStatus.value = 'First data received, buffering...';
      } else if (_packetCount < 10) {
        processingStatus.value = 'Buffering samples... ($_packetCount/10)';
      } else if (currentQuality.value == 0) {
        processingStatus.value =
            'Analyzing signal quality... (${_packetCount} samples)';
      } else {
        processingStatus.value = 'Processing vital signs...';
      }
      bufferedSamplesCount.value = _packetCount;

      if (_packetCount % 100 == 0 && _startTime != null) {
        final elapsed = DateTime.now().difference(_startTime!);
        final rate = elapsed.inSeconds > 0
            ? _packetCount / elapsed.inSeconds
            : 0.0;
        print('═══════════════════════════════════════════════════════');
        print('[BASELINE] Vitals received: $_packetCount');
        print(
          '[BASELINE] Vitals rate: ${rate.toStringAsFixed(1)} Hz (BCG batch processing rate)',
        );
        print('[BASELINE] Signal Quality: ${vitals.signalQuality}%');
        print('[BASELINE] Battery: $batteryPercent%');
        print('[BASELINE] HR: ${vitals.heartRateBpm.toStringAsFixed(1)} bpm');
        print(
          '[BASELINE] RR: ${vitals.respiratoryRateBpm.toStringAsFixed(1)} brpm',
        );
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

          // Only add temperature if valid (not NaN)
          if (!vitals.temperatureC.isNaN) {
            temperatureSamples.add(vitals.temperatureC);
          }
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
    isComplete.value = false;

    // Reset counters
    elapsedSeconds.value = 0;
    remainingSeconds.value = AppConfig.baselineDurationSeconds;
    _targetDurationSeconds =
        AppConfig.baselineDurationSeconds; // Initialize dynamic target
    _lastExtensionTime = null; // Reset extension timestamp
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
    showNoSignalWarning.value = false;
    processingStatus.value = 'Waiting for data...';
    bufferedSamplesCount.value = 0;

    // Check for no signal after 60 seconds
    _noSignalCheckTimer?.cancel();
    _noSignalCheckTimer = Timer(const Duration(seconds: 60), () {
      // If still no valid vitals after 60 seconds, show warning
      if (validSamples.value == 0 && currentQuality.value == 0) {
        showNoSignalWarning.value = true;
      }
    });

    // Start timer
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsedSeconds.value++;
      remainingSeconds.value = _targetDurationSeconds - elapsedSeconds.value;

      // Check completion criteria every second
      _checkCompletionCriteria();

      if (remainingSeconds.value <= 0) {
        // TEMPORARY: Force complete after 2 minutes
        // TODO: Uncomment quality-based completion when ready for production
        _completeCollection();

        /* ========== COMMENTED OUT FOR QUICK TESTING - UNCOMMENT WHEN READY ==========
        // Minimum duration reached
        if (canComplete.value) {
          _completeCollection();
        } else {
          _extendBaseline();
        }
        ========== END COMMENTED SECTION ========== */
      }
    });
  }

  /// Check if baseline can complete early
  void _checkCompletionCriteria() {
    // TEMPORARY: Force completion after 2 minutes without quality checks
    // TODO: Uncomment quality checks below when ready for production
    if (elapsedSeconds.value < AppConfig.baselineMinimumSeconds) {
      canComplete.value = false;
      statusMessage.value = 'Collecting baseline data...';
      return;
    }

    // Force completion after 2 minutes
    canComplete.value = true;
    statusMessage.value = 'Ready to complete';

    /* ========== COMMENTED OUT FOR QUICK TESTING - UNCOMMENT WHEN READY ==========
    // Can complete if:
    // 1. At least minimum duration elapsed
    // 2. Enough valid HR measurements
    // 3. HR has low coefficient of variation (stable)
    // 4. Average quality above threshold

    if (elapsedSeconds.value < AppConfig.baselineMinimumSeconds) {
      canComplete.value = false;
      _updateStatusMessage();
      return;
    }

    // Check if we have enough valid samples
    final validHRCount = heartRateSamples.length;
    if (validHRCount < AppConfig.baselineMinimumHRSamples) {
      canComplete.value = false;
      statusMessage.value =
          'Collecting samples... ($validHRCount/${AppConfig.baselineMinimumHRSamples})';
      return;
    }

    // Calculate HR coefficient of variation
    final hrCV = _calculateCoefficientOfVariation(heartRateSamples);

    // Calculate current stability (based on quality)
    currentStability.value = avgQuality.value;

    // Can complete if all criteria met
    canComplete.value =
        (currentStability.value >= AppConfig.baselineStabilityThreshold * 100 &&
        hrCV < AppConfig.baselineCVThreshold);

    _updateStatusMessage();
    ========== END COMMENTED SECTION ========== */
  }

  /// Calculate coefficient of variation
  double _calculateCoefficientOfVariation(List<double> samples) {
    if (samples.isEmpty) return 1.0;

    final mean = samples.reduce((a, b) => a + b) / samples.length;
    if (mean == 0) return 1.0;

    final variance =
        samples.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) /
        samples.length;
    final stdDev = sqrt(variance);

    return stdDev / mean;
  }

  /// Update status message based on current state
  void _updateStatusMessage() {
    final stability = currentStability.value;
    final validHRCount = heartRateSamples.length;

    if (validHRCount < AppConfig.baselineMinimumHRSamples) {
      statusMessage.value =
          'Collecting samples... ($validHRCount/${AppConfig.baselineMinimumHRSamples})';
    } else if (stability < 40) {
      statusMessage.value = 'Detecting movement... keep pet still';
    } else if (stability < 60) {
      statusMessage.value = 'Signal stabilizing...';
    } else if (canComplete.value) {
      statusMessage.value = 'Ready to complete - High quality data';
    } else {
      statusMessage.value = 'Collecting high-quality data...';
    }
  }

  /// Extend baseline if quality not met
  void _extendBaseline() {
    final totalDuration = elapsedSeconds.value;
    final now = DateTime.now();

    // Check if we've extended recently (within last 5 seconds) to prevent repeated snackbars
    if (_lastExtensionTime != null) {
      final timeSinceLastExtension = now.difference(_lastExtensionTime!);
      if (timeSinceLastExtension.inSeconds < 5) {
        print(
          '[Baseline] 🔇 Extension already triggered ${timeSinceLastExtension.inSeconds}s ago, skipping snackbar',
        );
        return; // Don't extend again so soon
      }
    }

    if (totalDuration >= AppConfig.baselineMaximumSeconds) {
      // Max duration reached, complete anyway
      print(
        '[Baseline] ⚠️ Maximum duration reached, completing with current quality',
      );
      print('[Baseline] Quality: ${avgQuality.value.round()}%');
      _completeCollection();
    } else {
      // Add 1 more minute (up to max)
      print('[Baseline] ⏱️ Extending baseline by 1 minute');

      // Update the dynamic target duration to next minute boundary
      final targetDuration =
          (totalDuration ~/ 60 + 1) * 60; // Round up to next minute
      _targetDurationSeconds = targetDuration.clamp(
        0,
        AppConfig.baselineMaximumSeconds,
      );
      remainingSeconds.value = _targetDurationSeconds - elapsedSeconds.value;

      print('[Baseline] New target duration: $_targetDurationSeconds seconds');
      print('[Baseline] Remaining seconds: ${remainingSeconds.value}');
      print('[Baseline] Signal quality not yet stable, extending collection');

      // Update last extension time
      _lastExtensionTime = now;
    }
  }

  /// Abort baseline collection
  Future<void> abortCollection() async {
    print('[Baseline] ⛔ Aborting baseline collection');

    // Stop timer and collection
    _timer?.cancel();
    isCollecting.value = false;
    isComplete.value = false;

    // Navigate back
    Get.back();

    // Show snackbar
    Get.snackbar(
      'Baseline Aborted',
      'You can restart baseline collection when ready.',
      backgroundColor: AppColors.warning,
      duration: const Duration(seconds: 5),
    );
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

      // Navigate to baseline complete page
      print('[Baseline] ========================================');
      print('[Baseline] 🚀 Attempting navigation to baseline complete...');
      print('[Baseline] Target Route: ${Routes.baselineComplete}');
      try {
        Get.toNamed(Routes.baselineComplete);
        print('[Baseline] ✅ Navigation successful');
        print('[Baseline] ========================================');
      } catch (e, stackTrace) {
        print('[Baseline] ========================================');
        print('[Baseline] ❌ NAVIGATION ERROR');
        print('[Baseline] ========================================');
        print('[Baseline] Error Type: ${e.runtimeType}');
        print('[Baseline] Error Message: $e');
        print('[Baseline] Attempted Route: ${Routes.baselineComplete}');
        print('[Baseline] Stack Trace:');
        print(stackTrace);
        print('[Baseline] ========================================');

        Get.snackbar(
          'Navigation Error',
          'Baseline collected but failed to navigate. Check logs.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.errorContainer,
          colorText: Get.theme.colorScheme.onErrorContainer,
          duration: const Duration(seconds: 5),
        );
      }
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

      // Update session controller with baseline data
      _sessionController.baselineData.value = baselineData.value;

      final currentSessionId = _sessionController.currentSession.value?.id;
      print('[Baseline] 📝 Current session ID before copyWith: $currentSessionId');

      _sessionController.currentSession.value = _sessionController
          .currentSession
          .value
          ?.copyWith(
            baselineData: baselineData.value,
            baselineQuality: baselineData.value!.qualityScore,
          );

      print('[Baseline] 📝 Current session ID after copyWith: ${_sessionController.currentSession.value?.id}');
      print('[Baseline] ✅ Baseline saved successfully');
      print('[Baseline] Quality: ${baselineData.value!.qualityScore}%');
      print('[Baseline] HR: ${baselineData.value!.heartRate.mean.round()} bpm');
      print(
        '[Baseline] RR: ${baselineData.value!.respiratoryRate.mean.round()} brpm',
      );

      // Navigate to baseline complete
      print('[Baseline] ========================================');
      print('[Baseline] 💾 SAVE AND PROCEED BUTTON PRESSED');
      print('[Baseline] 🚀 Attempting navigation to baseline complete...');
      print('[Baseline] Target Route: ${Routes.baselineComplete}');
      try {
        Get.toNamed(Routes.baselineComplete);
        print('[Baseline] ✅ Navigation successful');
        print('[Baseline] ========================================');
      } catch (e, stackTrace) {
        print('[Baseline] ========================================');
        print('[Baseline] ❌ NAVIGATION ERROR');
        print('[Baseline] ========================================');
        print('[Baseline] Error Type: ${e.runtimeType}');
        print('[Baseline] Error Message: $e');
        print('[Baseline] Attempted Route: ${Routes.baselineComplete}');
        print('[Baseline] Stack Trace:');
        print(stackTrace);
        print('[Baseline] ========================================');

        Get.snackbar(
          'Navigation Error',
          'Baseline saved but failed to navigate. Check logs.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.errorContainer,
          colorText: Get.theme.colorScheme.onErrorContainer,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save baseline');
    }
  }

  /// Restart baseline collection
  Future<void> restartCollection() async {
    print('[Baseline] 🔄 Restarting baseline collection');

    // 1. Stop current collection
    _timer?.cancel();
    isCollecting.value = false;
    isComplete.value = false;

    // 2. Clear all buffers and data
    collectedVitals.clear();
    heartRateSamples.clear();
    respiratorySamples.clear();
    temperatureSamples.clear();
    waveformBuffer.clear();
    baselineData.value = null;

    // 3. Reset counters
    elapsedSeconds.value = 0;
    remainingSeconds.value = AppConfig.baselineDurationSeconds;
    _targetDurationSeconds =
        AppConfig.baselineDurationSeconds; // Reset dynamic target
    _lastExtensionTime = null; // Reset extension timestamp
    validSamples.value = 0;
    totalSamples.value = 0;
    avgQuality.value = 0;
    currentQuality.value = 0;

    // 4. Reset debug counters
    _packetCount = 0;
    _startTime = null;
    showNoSignalWarning.value = false;
    processingStatus.value = 'Waiting for data...';
    bufferedSamplesCount.value = 0;

    // 5. DO NOT disconnect BLE (firmware keeps streaming)
    // 6. DO NOT send any command to firmware (no pause/resume command exists)

    // 7. Restart collection
    print('[Baseline] ✅ Restart complete, starting fresh collection');
    startCollection();
  }

  /// Skip baseline (not recommended)
  Future<void> skipBaseline() async {
    print('[Baseline] ========================================');
    print('[Baseline] ⏭️ SKIP BASELINE BUTTON PRESSED');
    print('[Baseline] ========================================');

    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Skip Baseline?'),
          content: const Text(
            'Skipping baseline collection will reduce data quality and '
            'algorithm accuracy. This is not recommended.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                print(
                  '[Baseline] 📱 Skip cancelled - user chose to collect baseline',
                );
                Get.back(result: false);
              },
              child: const Text('Collect Baseline'),
            ),
            TextButton(
              onPressed: () {
                print(
                  '[Baseline] ⚠️ Skip confirmed - proceeding without baseline',
                );
                Get.back(result: true);
              },
              child: const Text('Skip'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        print('[Baseline] 🚀 Attempting navigation to pre-surgery...');
        print('[Baseline] Target Route: ${Routes.preSurgery}');
        print('[Baseline] Session ID: ${_sessionController.currentSession.value?.id}');
        Get.toNamed(
          Routes.preSurgery,
          arguments: _sessionController.currentSession.value,
        );
        print('[Baseline] ✅ Navigation successful');
      } else {
        print('[Baseline] ℹ️ User chose to continue baseline collection');
      }
      print('[Baseline] ========================================');
    } catch (e, stackTrace) {
      print('[Baseline] ========================================');
      print('[Baseline] ❌ SKIP BASELINE ERROR');
      print('[Baseline] ========================================');
      print('[Baseline] Error Type: ${e.runtimeType}');
      print('[Baseline] Error Message: $e');
      print('[Baseline] Stack Trace:');
      print(stackTrace);
      print('[Baseline] ========================================');

      Get.snackbar(
        'Navigation Error',
        'Failed to skip baseline. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
        duration: const Duration(seconds: 5),
      );
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
