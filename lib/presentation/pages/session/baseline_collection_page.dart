import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_typography.dart';
import '../../../app/themes/app_theme.dart';
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
    if (controller.isComplete.value) {
      return _buildCompleteView();
    }
    
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
    return Column(
      children: [
        // Progress section
        _buildProgressSection(),
        
        // Waveform display
        Expanded(
          child: _buildWaveformDisplay(),
        ),
        
        // Real-time vitals
        _buildVitalsRow(),
        
        // Quality indicator
        _buildQualityBar(),
        
        // Controls
        _buildControls(),
      ],
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
          const SizedBox(height: 8),
          
          // Status text
          Obx(() => Text(
            controller.isPaused.value
                ? 'PAUSED - Tap Resume to continue'
                : 'Collecting baseline data...',
            style: AppTypography.labelSmall.copyWith(
              color: controller.isPaused.value 
                  ? AppColors.warning 
                  : AppColors.textSecondary,
            ),
          )),
        ],
      ),
    );
  }
  
  Widget _buildWaveformDisplay() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BCG Waveform',
            style: AppTypography.labelSmall,
          ),
          const SizedBox(height: 8),
          
          Expanded(
            child: Obx(() => _WaveformChart(
              data: controller.waveformBuffer.toList(),
              isPaused: controller.isPaused.value,
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
                color: AppColors.info,
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
  
  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Restart button
          OutlinedButton.icon(
            onPressed: controller.restartCollection,
            icon: const Icon(Icons.refresh),
            label: const Text('Restart'),
          ),
          const Spacer(),
          
          // Pause/Resume button
          Obx(() => ElevatedButton.icon(
            onPressed: controller.isPaused.value
                ? controller.resumeCollection
                : controller.pauseCollection,
            icon: Icon(
              controller.isPaused.value ? Icons.play_arrow : Icons.pause,
            ),
            label: Text(controller.isPaused.value ? 'Resume' : 'Pause'),
          )),
        ],
      ),
    );
  }
  
  Widget _buildCompleteView() {
    final baseline = controller.baselineData.value;
    if (baseline == null) {
      return const Center(child: Text('No data collected'));
    }
    
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Success header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.successSurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 64,
                  color: AppColors.success,
                ),
                const SizedBox(height: 16),
                Text(
                  'Baseline Complete',
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.successDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Quality: ${baseline.qualityLabel} (${baseline.qualityScore}%)',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.successDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Baseline stats
          Text(
            'Baseline Statistics',
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: 12),
          
          _buildStatCard(
            'Heart Rate',
            '${baseline.heartRate.mean.round()} bpm',
            'Range: ${baseline.heartRate.min.round()}-${baseline.heartRate.max.round()} bpm',
            baseline.heartRate.isStable,
          ),
          const SizedBox(height: 8),
          
          _buildStatCard(
            'Respiratory Rate',
            '${baseline.respiratoryRate.mean.round()} brpm',
            'Range: ${baseline.respiratoryRate.min.round()}-${baseline.respiratoryRate.max.round()} brpm',
            baseline.respiratoryRate.isStable,
          ),
          const SizedBox(height: 8),
          
          _buildStatCard(
            'Temperature',
            '${baseline.temperature.mean.toStringAsFixed(1)}°C',
            'Range: ${baseline.temperature.min.toStringAsFixed(1)}-${baseline.temperature.max.toStringAsFixed(1)}°C',
            baseline.temperature.isStable,
          ),
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
  
  Widget _buildStatCard(String label, String value, String range, bool isStable) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.labelSmall),
                const SizedBox(height: 4),
                Text(value, style: AppTypography.titleLarge),
                const SizedBox(height: 2),
                Text(range, style: AppTypography.caption),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isStable ? AppColors.successSurface : AppColors.warningSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isStable ? Icons.check : Icons.warning,
                  size: 14,
                  color: isStable ? AppColors.success : AppColors.warning,
                ),
                const SizedBox(width: 4),
                Text(
                  isStable ? 'Stable' : 'Variable',
                  style: AppTypography.labelSmall.copyWith(
                    color: isStable ? AppColors.successDark : AppColors.warningDark,
                  ),
                ),
              ],
            ),
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
  final bool isPaused;
  
  const _WaveformChart({
    required this.data,
    this.isPaused = false,
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
            color: isPaused ? AppColors.textDisabled : AppColors.primary,
            barWidth: 1.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: (isPaused ? AppColors.textDisabled : AppColors.primary)
                  .withOpacity(0.1),
            ),
          ),
        ],
        lineTouchData: const LineTouchData(enabled: false),
      ),
      duration: const Duration(milliseconds: 0), // No animation for real-time
    );
  }
}
