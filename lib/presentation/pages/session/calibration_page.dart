import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_pages.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_typography.dart';
import '../../../app/themes/app_theme.dart';
import '../../../data/models/models.dart';
import '../../controllers/session_controller.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/waveform_chart.dart';
import 'dart:math';

/// Calibration page - ECG/BCG correlation during surgery
class CalibrationPage extends StatefulWidget {
  const CalibrationPage({super.key});

  @override
  State<CalibrationPage> createState() => _CalibrationPageState();
}

class _CalibrationPageState extends State<CalibrationPage> {
  final SessionController _sessionController = Get.find<SessionController>();

  // Calibration state
  final RxBool isCalibrating = false.obs;
  final RxBool isComplete = false.obs;
  final RxInt calibrationProgress = 0.obs;
  final RxDouble correlation = 0.0.obs;
  final RxDouble errorBpm = 0.0.obs;
  final Rx<CalibrationStatus> status = CalibrationStatus.pending.obs;

  // Timer
  Timer? _progressTimer;
  static const int calibrationDurationSeconds = 120; // 2 minutes

  // Waveform streams (simulated - in real app, these come from BLE/WebSocket)
  final StreamController<double> _bcgStreamController =
      StreamController<double>.broadcast();
  final StreamController<double> _ecgStreamController =
      StreamController<double>.broadcast();

  Stream<double> get bcgStream => _bcgStreamController.stream;
  Stream<double> get ecgStream => _ecgStreamController.stream;

  @override
  void dispose() {
    _progressTimer?.cancel();
    _bcgStreamController.close();
    _ecgStreamController.close();
    super.dispose();
  }

  void _startCalibration() {
    isCalibrating.value = true;
    calibrationProgress.value = 0;

    _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      calibrationProgress.value++;

      if (calibrationProgress.value >= calibrationDurationSeconds) {
        _completeCalibration();
      }
    });

    // Simulate waveform data (in real app, this comes from services)
    _simulateWaveformData();
  }

  void _simulateWaveformData() {
    // This would be replaced with actual BLE and WebSocket data streams
    Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (!isCalibrating.value) {
        timer.cancel();
        return;
      }

      final t = DateTime.now().millisecondsSinceEpoch / 1000.0;
      // Simulated BCG signal
      _bcgStreamController.add(
        0.5 * (sin(t * 2 * 3.14159 * 1.2) + 0.3 * sin(t * 2 * 3.14159 * 2.4)),
      );
      // Simulated ECG signal (higher frequency)
      _ecgStreamController.add(
        0.8 * sin(t * 2 * 3.14159 * 1.2) + 0.1 * (t % 1 < 0.1 ? 3 : 0),
      );
    });
  }

  void _completeCalibration() {
    _progressTimer?.cancel();
    isCalibrating.value = false;
    isComplete.value = true;

    // Simulated calibration results
    // In real app, these come from algorithm correlation computation
    correlation.value = 0.92 + (DateTime.now().millisecond % 8) / 100;
    errorBpm.value = 2.5 + (DateTime.now().millisecond % 30) / 10;

    if (correlation.value >= 0.95) {
      status.value = CalibrationStatus.success;
    } else if (correlation.value >= 0.85) {
      status.value = CalibrationStatus.success;
    } else if (correlation.value >= 0.70) {
      status.value = CalibrationStatus.lowQuality;
    } else {
      status.value = CalibrationStatus.failed;
    }
  }

  void _skipCalibration() {
    Get.dialog(
      AlertDialog(
        title: const Text('Skip Calibration?'),
        content: const Text(
          'Skipping calibration will mark this session as uncalibrated. '
          'The data can still be used but with reduced accuracy validation.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              _proceedToRecovery(skipCalibration: true);
            },
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }

  Future<void> _proceedToRecovery({bool skipCalibration = false}) async {
    final success = await _sessionController.startRecovery(
      calibrationSuccess: !skipCalibration && status.value.isSuccess,
      calibrationCorrelation: skipCalibration ? null : correlation.value,
      calibrationErrorBpm: skipCalibration ? null : errorBpm.value,
    );

    if (success) {
      Get.offNamed(Routes.recovery);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ECG Calibration'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _skipCalibration,
            child: Text(
              'Skip',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Status bar
          Obx(
            () => SessionStatusBar(
              collarId: _sessionController.currentCollar.value?.serialNumber,
              isConnected: _sessionController.isCollarConnected,
              batteryPercent: _sessionController.batteryPercent.value,
              signalQuality: _sessionController.signalQuality.value,
            ),
          ),

          // Phase banner
          Obx(
            () => PhaseBanner(
              phase: SessionPhase.calibration,
              duration: _sessionController.phaseDuration.value,
            ),
          ),

          Expanded(
            child: Obx(() {
              if (isComplete.value) {
                return _buildResults();
              }
              if (isCalibrating.value) {
                return _buildCalibrating();
              }
              return _buildStart();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStart() {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),

          // Instructions
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.warningSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.tune, color: AppColors.warning),
                    const SizedBox(width: 12),
                    Text(
                      'ECG Calibration',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.warningDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'This phase correlates the BCG signal from the collar with '
                  'the ECG ground truth from the PLUX equipment. '
                  'Ensure the ECG leads are properly attached.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.warningDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Checklist
          _buildChecklist(),
          const SizedBox(height: 32),

          // Connection status
          _buildConnectionStatus(),
          const SizedBox(height: 32),

          // Start button
          ElevatedButton.icon(
            onPressed: _startCalibration,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Calibration (2 min)'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklist() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Before starting:', style: AppTypography.titleSmall),
          const SizedBox(height: 12),
          _checklistItem('ECG leads properly attached', true),
          _checklistItem('PLUX BITalino connected', true),
          _checklistItem('Laptop app receiving ECG data', true),
          _checklistItem('Animal is stable post-surgery', true),
        ],
      ),
    );
  }

  Widget _checklistItem(String text, bool checked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            checked ? Icons.check_circle : Icons.circle_outlined,
            size: 20,
            color: checked ? AppColors.success : AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Connection Status', style: AppTypography.titleSmall),
          const SizedBox(height: 12),
          Row(
            children: [
              _connectionIndicator('Collar (BCG)', true),
              const SizedBox(width: 24),
              _connectionIndicator(
                'Laptop (ECG)',
                _sessionController.isLaptopConnected,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _connectionIndicator(String label, bool connected) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: connected ? AppColors.success : AppColors.error,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: connected ? AppColors.success : AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildCalibrating() {
    return Column(
      children: [
        // Progress section
        Container(
          padding: const EdgeInsets.all(24),
          color: AppColors.surface,
          child: Column(
            children: [
              Obx(
                () => Text(
                  '${calibrationDurationSeconds - calibrationProgress.value}s',
                  style: AppTypography.timerLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text('remaining'),
              const SizedBox(height: 16),

              Obx(
                () => LinearProgressIndicator(
                  value: calibrationProgress.value / calibrationDurationSeconds,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Recording BCG and ECG signals...',
                style: AppTypography.caption,
              ),
            ],
          ),
        ),

        // Dual waveform display
        Expanded(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: DualWaveformChart(
              bcgStream: bcgStream,
              ecgStream: ecgStream,
              displaySeconds: 10,
              bcgSampleRate: 128,
              ecgSampleRate: 1000,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),

          // Status icon
          Obx(
            () => Icon(
              status.value.isSuccess ? Icons.check_circle : Icons.warning,
              size: 80,
              color: status.value.isSuccess
                  ? AppColors.success
                  : AppColors.warning,
            ),
          ),
          const SizedBox(height: 16),

          Obx(
            () => Text(
              status.value.isSuccess
                  ? 'Calibration Successful!'
                  : 'Calibration Complete',
              style: AppTypography.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),

          // Results card
          _buildResultsCard(),
          const SizedBox(height: 24),

          // Actions
          ElevatedButton(
            onPressed: () => _proceedToRecovery(),
            child: const Text('Continue to Recovery'),
          ),
          const SizedBox(height: 12),

          Obx(() {
            if (!status.value.isSuccess) {
              return OutlinedButton(
                onPressed: () {
                  isComplete.value = false;
                  calibrationProgress.value = 0;
                },
                child: const Text('Retry Calibration'),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildResultsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Correlation
          _resultRow(
            'Correlation (r)',
            Obx(
              () => Text(
                correlation.value.toStringAsFixed(3),
                style: AppTypography.titleMedium.copyWith(
                  color: correlation.value >= 0.90
                      ? AppColors.success
                      : AppColors.warning,
                ),
              ),
            ),
          ),
          const Divider(height: 24),

          // Error
          _resultRow(
            'Mean Error',
            Obx(
              () => Text(
                '±${errorBpm.value.toStringAsFixed(1)} bpm',
                style: AppTypography.titleMedium,
              ),
            ),
          ),
          const Divider(height: 24),

          // Quality label
          _resultRow(
            'Quality',
            Obx(
              () => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getQualityColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getQualityLabel(),
                  style: AppTypography.labelMedium.copyWith(
                    color: _getQualityColor(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultRow(String label, Widget value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodyMedium),
        value,
      ],
    );
  }

  String _getQualityLabel() {
    if (correlation.value >= 0.95) return 'Excellent';
    if (correlation.value >= 0.90) return 'Good';
    if (correlation.value >= 0.85) return 'Acceptable';
    return 'Low Quality';
  }

  Color _getQualityColor() {
    if (correlation.value >= 0.95) return AppColors.success;
    if (correlation.value >= 0.90) return AppColors.primary;
    if (correlation.value >= 0.85) return AppColors.warning;
    return AppColors.error;
  }
}

// Need this for sin function
