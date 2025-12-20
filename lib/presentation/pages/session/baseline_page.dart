import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_typography.dart';
import '../../../app/themes/app_theme.dart';
import '../../controllers/baseline_controller.dart';
import '../../controllers/session_controller.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/waveform_chart.dart';

/// Baseline collection screen - 5 minute pre-surgery data collection
class BaselineCollectionPage extends GetView<BaselineController> {
  const BaselineCollectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionController = Get.find<SessionController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Baseline Collection'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: controller.skipBaseline,
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
              collarId: sessionController.currentCollar.value?.serialNumber,
              isConnected: sessionController.isCollarConnected,
              batteryPercent: sessionController.batteryPercent.value,
              signalQuality: sessionController.signalQuality.value,
            ),
          ),

          Expanded(child: Obx(() => _buildContent())),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (controller.isComplete.value) {
      return _buildComplete();
    }

    if (!controller.isCollecting.value) {
      return _buildStart();
    }

    return _buildCollecting();
  }

  Widget _buildStart() {
    final sessionController = Get.find<SessionController>();
    final animal = sessionController.currentAnimal.value;

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),

          // Instructions card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.infoSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.info.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info),
                    const SizedBox(width: 12),
                    Text(
                      'Baseline Collection',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.infoDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Collect 5 minutes of baseline data before surgery. '
                  'This establishes normal vital ranges for ${animal?.name ?? 'this pet'}.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.infoDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Checklist
          _buildChecklist(),
          const SizedBox(height: 32),

          // Start button
          ElevatedButton.icon(
            onPressed: controller.startCollection,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Baseline Collection'),
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
          _checklistItem('Collar is properly positioned'),
          _checklistItem('Pet is calm and comfortable'),
          _checklistItem('Minimal environmental noise'),
          // _checklistItem('Good signal quality (>50%)'), // Removed for debug
        ],
      ),
    );
  }

  Widget _checklistItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 20, color: AppColors.success),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildCollecting() {
    return Column(
      children: [
        // Progress section
        Container(
          padding: const EdgeInsets.all(24),
          color: AppColors.surface,
          child: Column(
            children: [
              // Timer
              Obx(
                () => Text(
                  controller.remainingTimeFormatted,
                  style: AppTypography.timerLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text('remaining', style: AppTypography.bodySmall),
              const SizedBox(height: 16),

              // Progress bar
              Obx(
                () => LinearProgressIndicator(
                  value: controller.progress,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),

              // Quality indicator
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Signal Quality: ', style: AppTypography.bodySmall),
                    Text(
                      '${controller.avgQuality.value.round()}%',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.getQualityColor(
                          controller.avgQuality.value.round(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // === DEBUG RAW DATA CARD ===
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            border: Border.all(color: Colors.blue),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RAW DATA (Debug)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.blue.shade900,
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Packets: ${controller.totalSamples.value} (Valid: ${controller.validSamples.value})',
                    ),
                    Text(
                      'Signal Quality: ${controller.currentQuality.value}% (BYPASSED)',
                    ),
                    Text('Battery: ${controller.batteryPercent}%'),
                    if (controller.latestVitals != null)
                      Text(
                        'Last HR: ${controller.latestVitals!.heartRateBpm} bpm',
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // === END DEBUG CARD ===

        // Waveform display
        Expanded(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Live vitals
                _buildLiveVitals(),
                const SizedBox(height: 16),

                // Waveform chart
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Obx(
                      () => RealtimeWaveformChart(
                        displaySeconds: 10,
                        sampleRate: 100,
                        minY: -1.0,
                        maxY: 1.0,
                        title: 'BCG Signal',
                        lineColor: AppColors.primary,
                        isPaused: controller.isPaused.value,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Pause/Resume button
                Obx(
                  () => OutlinedButton.icon(
                    onPressed: controller.isPaused.value
                        ? controller.resumeCollection
                        : controller.pauseCollection,
                    icon: Icon(
                      controller.isPaused.value
                          ? Icons.play_arrow
                          : Icons.pause,
                    ),
                    label: Text(controller.isPaused.value ? 'Resume' : 'Pause'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLiveVitals() {
    final sessionController = Get.find<SessionController>();

    return Obx(() {
      final vitals = sessionController.latestVitals.value;

      return Row(
        children: [
          Expanded(
            child: VitalCard(
              label: 'Heart Rate',
              value: vitals?.heartRateBpm.toString() ?? '--',
              unit: 'bpm',
              icon: Icons.favorite,
              color: AppColors.error,
              compact: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: VitalCard(
              label: 'Resp Rate',
              value: vitals?.respiratoryRateBpm.toString() ?? '--',
              unit: 'brpm',
              icon: Icons.air,
              color: AppColors.primary,
              compact: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: VitalCard(
              label: 'Temp',
              value: vitals?.temperatureC.toStringAsFixed(1) ?? '--',
              unit: '°C',
              icon: Icons.thermostat,
              color: AppColors.warning,
              compact: true,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildComplete() {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),

          // Success icon
          const Icon(Icons.check_circle, size: 80, color: AppColors.success),
          const SizedBox(height: 24),

          Text(
            'Baseline Complete!',
            style: AppTypography.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Results card
          Obx(() => _buildResultsCard()),
          const SizedBox(height: 24),

          // Actions
          ElevatedButton(
            onPressed: controller.saveAndProceed,
            child: const Text('Continue to Pre-Surgery'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: controller.restartCollection,
            child: const Text('Recollect Baseline'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsCard() {
    final baseline = controller.baselineData.value;
    if (baseline == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Baseline Results', style: AppTypography.titleMedium),
          const SizedBox(height: 16),

          // Quality
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Data Quality', style: AppTypography.bodyMedium),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getQualityColor(
                    baseline.qualityScore,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${baseline.qualityLabel} (${baseline.qualityScore}%)',
                  style: AppTypography.labelMedium.copyWith(
                    color: _getQualityColor(baseline.qualityScore),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          // Heart Rate
          _resultRow(
            'Heart Rate',
            '${baseline.heartRate.mean.round()} ± ${baseline.heartRate.stdDev.round()} bpm',
            '${baseline.heartRate.min.round()}-${baseline.heartRate.max.round()}',
          ),
          const SizedBox(height: 12),

          // Respiratory Rate
          _resultRow(
            'Respiratory Rate',
            '${baseline.respiratoryRate.mean.round()} ± ${baseline.respiratoryRate.stdDev.round()} brpm',
            '${baseline.respiratoryRate.min.round()}-${baseline.respiratoryRate.max.round()}',
          ),
          const SizedBox(height: 12),

          // Temperature
          _resultRow(
            'Temperature',
            '${baseline.temperature.mean.toStringAsFixed(1)} ± ${baseline.temperature.stdDev.toStringAsFixed(1)} °C',
            '${baseline.temperature.min.toStringAsFixed(1)}-${baseline.temperature.max.toStringAsFixed(1)}',
          ),
          const Divider(height: 24),

          // Duration
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Collection Duration', style: AppTypography.bodySmall),
              Text(
                baseline.formattedDuration,
                style: AppTypography.labelMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value, String range) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: Text(label, style: AppTypography.bodyMedium)),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: AppTypography.titleSmall,
            textAlign: TextAlign.right,
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            range,
            style: AppTypography.caption,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Color _getQualityColor(int quality) {
    if (quality >= 75) return AppColors.success;
    if (quality >= 50) return AppColors.warning;
    return AppColors.error;
  }
}
