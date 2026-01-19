import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_pages.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_typography.dart';
import '../../../app/themes/app_theme.dart';
import '../../../data/models/models.dart';
import '../../controllers/session_controller.dart';
import '../../controllers/baseline_controller.dart';

/// Baseline complete page - unified completion screen with quality-based gating
class BaselineCompletePage extends StatelessWidget {
  const BaselineCompletePage({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionController = Get.find<SessionController>();
    final baselineController = Get.find<BaselineController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Baseline Complete'),
        automaticallyImplyLeading: false, // Cannot go back
      ),
      body: Obx(() {
        final baseline = baselineController.baselineData.value;
        if (baseline == null) {
          return const Center(child: Text('No baseline data available'));
        }

        return SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // Quality Header
              _buildQualityHeader(baseline),
              const SizedBox(height: 24),

              // Patient Info
              _buildPatientInfo(sessionController),
              const SizedBox(height: 24),

              // Statistics
              _buildStatistics(baseline),
              const SizedBox(height: 24),

              // Decision Gating
              _buildDecisionSection(baseline, baselineController, sessionController),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildQualityHeader(BaselineData baseline) {
    final quality = baseline.qualityScore;

    // Use COMPUTED quality, not firmware's constant
    final qualityColor = quality >= 75 ? AppColors.success :
                         quality >= 60 ? AppColors.warning : AppColors.error;

    final qualityLabel = quality >= 75 ? 'Excellent' :
                         quality >= 60 ? 'Good' : 'Poor';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: qualityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: qualityColor, width: 2),
      ),
      child: Column(
        children: [
          Icon(
            quality >= 60 ? Icons.check_circle : Icons.warning,
            size: 48,
            color: qualityColor,
          ),
          const SizedBox(height: 12),
          Text(
            'Baseline Complete',
            style: AppTypography.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Quality: $qualityLabel ($quality%)',
            style: AppTypography.titleMedium.copyWith(
              color: qualityColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientInfo(SessionController sessionController) {
    final animal = sessionController.currentAnimal.value;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            animal?.species == Species.dog ? Icons.pets : Icons.cruelty_free,
            size: 32,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  animal?.name ?? 'Unknown',
                  style: AppTypography.titleMedium,
                ),
                Text(
                  '${animal?.breed ?? 'Unknown'} • ${animal?.weightDisplay ?? 'Unknown'}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(BaselineData baseline) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Baseline Statistics',
          style: AppTypography.headlineSmall,
        ),
        const SizedBox(height: 16),

        // HR
        _buildVitalCard(
          icon: Icons.favorite,
          color: AppColors.error,
          label: 'Heart Rate',
          value: '${baseline.heartRate.mean.round()} bpm',
          range: '${baseline.heartRate.min.round()}-${baseline.heartRate.max.round()}',
          stdDev: baseline.heartRate.stdDev,
        ),
        const SizedBox(height: 12),

        // RR
        _buildVitalCard(
          icon: Icons.air,
          color: AppColors.info,
          label: 'Respiratory Rate',
          value: '${baseline.respiratoryRate.mean.round()} brpm',
          range: '${baseline.respiratoryRate.min.round()}-${baseline.respiratoryRate.max.round()}',
          stdDev: baseline.respiratoryRate.stdDev,
        ),
        const SizedBox(height: 12),

        // Temperature (ONLY IF VALID!)
        if (baseline.temperature.mean > 15 && baseline.temperature.mean < 45)
          _buildVitalCard(
            icon: Icons.thermostat,
            color: AppColors.warning,
            label: 'Temperature',
            value: '${baseline.temperature.mean.toStringAsFixed(1)} °C',
            range: '${baseline.temperature.min.toStringAsFixed(1)}-${baseline.temperature.max.toStringAsFixed(1)}',
            stdDev: baseline.temperature.stdDev,
          ),
        const SizedBox(height: 16),

        // Collection metadata
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _metadataRow('Duration:', baseline.formattedDuration),
              const SizedBox(height: 8),
              _metadataRow('Samples Collected:', '${baseline.durationSeconds * 10}'), // Approximate: 10 Hz
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVitalCard({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    required String range,
    required double stdDev,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.labelSmall),
                const SizedBox(height: 4),
                Text(value, style: AppTypography.titleLarge),
                const SizedBox(height: 2),
                Text(
                  'Range: $range • SD: ${stdDev.toStringAsFixed(1)}',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metadataRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTypography.labelMedium,
        ),
      ],
    );
  }

  Widget _buildDecisionSection(
    BaselineData baseline,
    BaselineController baselineController,
    SessionController sessionController,
  ) {
    final quality = baseline.qualityScore;

    if (quality >= 60) {
      // GOOD QUALITY: Single clear CTA
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.successSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.success),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Baseline quality is good. Ready to proceed.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.successDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _proceedToPreSurgery(baselineController, sessionController),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Continue to Pre-Surgery',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: 12),

          TextButton(
            onPressed: () => _recollectBaseline(baselineController),
            child: const Text('Recollect Baseline'),
          ),
        ],
      );
    } else {
      // POOR QUALITY: Recommend recollection
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warningSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning, color: AppColors.warning),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Baseline quality is below recommended threshold',
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.warningDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Recommendations:\n'
                  '• Ensure collar is properly positioned\n'
                  '• Keep pet calm and still\n'
                  '• Check for environmental interference',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.warningDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _recollectBaseline(baselineController),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Recollect Baseline',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showProceedAnywayDialog(baselineController, sessionController),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Proceed Anyway (Not Recommended)'),
            ),
          ),
        ],
      );
    }
  }

  void _proceedToPreSurgery(
    BaselineController baselineController,
    SessionController sessionController,
  ) async {
    // Baseline is already saved, just navigate to pre-surgery
    print('[BaselineComplete] ========================================');
    print('[BaselineComplete] 🚀 PROCEED TO PRE-SURGERY BUTTON PRESSED');
    print('[BaselineComplete] ========================================');
    print('[BaselineComplete] Target Route: ${Routes.preSurgery}');

    try {
      print('[BaselineComplete] 🚀 Attempting navigation to pre-surgery...');
      Get.offAllNamed(Routes.preSurgery);
      print('[BaselineComplete] ✅ Navigation successful');
      print('[BaselineComplete] ========================================');
    } catch (e, stackTrace) {
      print('[BaselineComplete] ========================================');
      print('[BaselineComplete] ❌ NAVIGATION ERROR');
      print('[BaselineComplete] ========================================');
      print('[BaselineComplete] Error Type: ${e.runtimeType}');
      print('[BaselineComplete] Error Message: $e');
      print('[BaselineComplete] Attempted Route: ${Routes.preSurgery}');
      print('[BaselineComplete] Stack Trace:');
      print(stackTrace);
      print('[BaselineComplete] ========================================');

      Get.snackbar(
        'Navigation Error',
        'Failed to navigate to pre-surgery. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
        duration: const Duration(seconds: 5),
      );
    }
  }

  void _recollectBaseline(BaselineController baselineController) {
    Get.back(); // Return to baseline collection page
    baselineController.restartCollection();
  }

  void _showProceedAnywayDialog(
    BaselineController baselineController,
    SessionController sessionController,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Proceed with Low Quality?'),
        content: const Text(
          'Baseline quality is below recommended threshold. '
          'Proceeding may result in less accurate monitoring.\n\n'
          'Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _proceedToPreSurgery(baselineController, sessionController);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
            ),
            child: const Text('Proceed Anyway'),
          ),
        ],
      ),
    );
  }
}
