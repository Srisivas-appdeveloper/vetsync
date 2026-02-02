import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_typography.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/constants/app_config.dart';
import '../../controllers/baseline_controller.dart';
import '../../controllers/session_controller.dart';
import '../../widgets/common_widgets.dart';

/// Baseline collection screen - 5 minute data collection
class BaselineCollectionPage extends GetView<BaselineController> {
  const BaselineCollectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionController = Get.find<SessionController>();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Baseline Collection'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showCancelDialog(),
        ),
      ),
      body: Column(
        children: [
          // Status bar
          Obx(() => SessionStatusBar(
            collarId: sessionController.currentCollar.value?.serialNumber,
            isConnected: sessionController.isCollarConnected,
            batteryPercent: sessionController.batteryPercent.value,
            signalQuality: sessionController.signalQuality.value,
          )),
          
          Expanded(
            child: Obx(() => _buildContent()),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContent() {
    if (!controller.isCollecting.value) {
      return _buildStartView();
    }

    return _buildCollectionView();
  }
  
  Widget _buildStartView() {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.monitor_heart_outlined,
            size: 80,
            color: AppColors.primary,
          ),
          const SizedBox(height: 24),
          
          Text(
            'Ready to Collect Baseline',
            style: AppTypography.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          
          Text(
            'Position the collar on the pet and ensure a stable signal before starting. '
            'The pet should be calm and still during collection.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          Text(
            'Collection will take 5 minutes.',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Current signal quality indicator
          _buildSignalCheck(),
          const SizedBox(height: 32),
          
          ElevatedButton.icon(
            onPressed: controller.startCollection,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Collection'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
          const SizedBox(height: 16),
          
          TextButton(
            onPressed: controller.skipBaseline,
            child: const Text('Skip Baseline (Not Recommended)'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSignalCheck() {
    final quality = controller.currentQuality.value;
    Color color;
    String status;
    IconData icon;
    
    if (quality >= 75) {
      color = AppColors.success;
      status = 'Excellent Signal';
      icon = Icons.check_circle;
    } else if (quality >= 50) {
      color = AppColors.warning;
      status = 'Fair Signal - Adjust collar position';
      icon = Icons.warning;
    } else {
      color = AppColors.error;
      status = 'Poor Signal - Reposition collar';
      icon = Icons.error;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                status,
                style: AppTypography.labelMedium.copyWith(color: color),
              ),
              Text(
                'Quality: $quality%',
                style: AppTypography.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildCollectionView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Progress section
          _buildProgressSection(),

          // Waveform display (fixed height since we're now scrollable)
          SizedBox(
            height: 250, // Fixed height for waveform (increased to prevent overflow)
            child: _buildWaveformDisplay(),
          ),

          // Real-time vitals
          _buildVitalsRow(),

          // Quality indicator
          _buildQualityBar(),

          // Real-time quality feedback
          _buildQualityIndicators(),

          // Controls
          _buildControls(),
        ],
      ),
    );
  }
  
  Widget _buildProgressSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        children: [
          // Timer
          Obx(() => Text(
            controller.remainingTimeFormatted,
            style: AppTypography.timerLarge.copyWith(
              color: AppColors.primary,
            ),
          )),
          const SizedBox(height: 8),
          
          // Progress bar
          Obx(() => ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: controller.progress,
              minHeight: 8,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          )),
          const SizedBox(height: 12),

          // Completion readiness indicator
          Obx(() => controller.canComplete.value
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.successSurface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Ready to complete',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.successDark,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink()),
          const SizedBox(height: 8),

          // Status message
          Obx(() => Text(
                controller.statusMessage.value,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              )),
        ],
      ),
    );
  }
  
  Widget _buildWaveformDisplay() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'BCG Waveform',
            style: AppTypography.labelSmall,
          ),
          const SizedBox(height: 8),

          // Fixed height for chart to prevent overflow
          SizedBox(
            height: 150,
            child: Obx(() => _WaveformChart(
              data: controller.waveformBuffer.toList(),
            )),
          ),
        ],
      ),
    );
  }
  
  Widget _buildVitalsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Obx(() {
        final vitals = controller.latestVitals;

        // Use confidence-gated display values
        final displayHR = vitals?.displayHR;
        final displayRR = vitals?.displayRR;
        final displayTemp = vitals?.displayTemperature;

        return Row(
          children: [
            Expanded(
              child: VitalCard(
                label: 'Heart Rate',
                value: displayHR?.toString() ?? 'Analyzing...',
                unit: displayHR != null ? 'bpm' : '',
                icon: Icons.favorite,
                color: AppColors.error,
                compact: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: VitalCard(
                label: 'Resp Rate',
                value: displayRR?.toString() ?? 'Analyzing...',
                unit: displayRR != null ? 'brpm' : '',
                icon: Icons.air,
                color: AppColors.info,
                compact: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: VitalCard(
                label: 'Temp',
                value: displayTemp?.toStringAsFixed(1) ?? '--',
                unit: displayTemp != null ? '°C' : '',
                icon: Icons.thermostat,
                color: AppColors.warning,
                compact: true,
              ),
            ),
          ],
        );
      }),
    );
  }
  
  Widget _buildQualityBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Obx(() => Row(
        children: [
          Text(
            'Signal Quality',
            style: AppTypography.labelSmall,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: controller.avgQuality.value / 100,
                minHeight: 6,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.getQualityColor(controller.avgQuality.value.round()),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${controller.avgQuality.value.round()}%',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.getQualityColor(controller.avgQuality.value.round()),
            ),
          ),
        ],
      )),
    );
  }
  
  Widget _buildQualityIndicators() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Obx(() {
        final stability = controller.currentStability.value;
        final validHRCount = controller.heartRateSamples.length;

        return Column(
          children: [
            // Stability indicator
            _buildQualityIndicator(
              label: 'Signal Stability',
              value: stability.round(),
              icon: Icons.waves,
              color: _getQualityIndicatorColor(stability.round()),
            ),
            const SizedBox(height: 12),

            // Sample count indicator
            _buildQualityIndicator(
              label: 'Valid HR Samples',
              value: validHRCount,
              maxValue: AppConfig.baselineMinimumHRSamples,
              icon: Icons.favorite,
              color: validHRCount >= AppConfig.baselineMinimumHRSamples
                  ? AppColors.success
                  : AppColors.warning,
              showAsCount: true,
            ),

            // Actionable guidance
            if (stability < 60 && validHRCount >= 10)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _buildGuidance('Keep pet calm and still for better quality'),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildQualityIndicator({
    required String label,
    required int value,
    int maxValue = 100,
    required IconData icon,
    required Color color,
    bool showAsCount = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.labelSmall),
                const SizedBox(height: 4),
                if (showAsCount)
                  Row(
                    children: [
                      Text(
                        '$value samples',
                        style: AppTypography.titleSmall.copyWith(color: color),
                      ),
                      if (value >= maxValue) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.check_circle,
                          color: color,
                          size: 16,
                        ),
                      ] else ...[
                        const SizedBox(width: 6),
                        Text(
                          '(need $maxValue)',
                          style: AppTypography.labelSmall.copyWith(
                            color: color.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ],
                  )
                else
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: value / maxValue,
                      minHeight: 8,
                      backgroundColor: AppColors.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
              ],
            ),
          ),
          if (!showAsCount)
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                '$value%',
                style: AppTypography.titleMedium.copyWith(color: color),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGuidance(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.infoSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.info, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.infoDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getQualityIndicatorColor(int quality) {
    if (quality >= 75) return AppColors.success;
    if (quality >= 50) return AppColors.warning;
    return AppColors.error;
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Restart button (with confirmation dialog)
          OutlinedButton.icon(
            onPressed: () => _showRestartConfirmation(),
            icon: const Icon(Icons.refresh),
            label: const Text('Restart'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.warning,
              side: const BorderSide(color: AppColors.warning),
            ),
          ),

          // Abort button (with confirmation dialog)
          OutlinedButton.icon(
            onPressed: () => _showAbortConfirmation(),
            icon: const Icon(Icons.close),
            label: const Text('Abort'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showRestartConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Restart Baseline?'),
        content: Obx(() => Text(
          'This will discard all collected data and start over. '
          'The 5-minute timer will reset.\n\n'
          'Current progress: ${controller.remainingTimeFormatted} remaining',
        )),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.restartCollection();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
            ),
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }

  void _showAbortConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Abort Baseline?'),
        content: const Text(
          'This will stop baseline collection. '
          'You will need to restart from the beginning.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.abortCollection();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Abort'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Baseline?'),
        content: const Text(
          'Are you sure you want to cancel baseline collection? '
          'This will end the session setup.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Continue Collection'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.find<SessionController>().cancelSession();
            },
            child: const Text('Cancel Session'),
          ),
        ],
      ),
    );
  }
}

/// Real-time waveform chart using fl_chart
class _WaveformChart extends StatelessWidget {
  final List<double> data;

  const _WaveformChart({
    required this.data,
  });
  
  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text('Waiting for data...'),
      );
    }
    
    // Use last 500 samples for display (5 seconds at 100 Hz)
    final displayData = data.length > 500 
        ? data.sublist(data.length - 500) 
        : data;
    
    final spots = displayData.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value);
    }).toList();
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 0.5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.border,
              strokeWidth: 0.5,
            );
          },
        ),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: displayData.length.toDouble() - 1,
        minY: -1.5,
        maxY: 1.5,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.2,
            color: AppColors.primary,
            barWidth: 1.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withOpacity(0.1),
            ),
          ),
        ],
        lineTouchData: const LineTouchData(enabled: false),
      ),
      duration: const Duration(milliseconds: 0), // No animation for real-time
    );
  }
}
