import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_pages.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_typography.dart';
import '../../../app/themes/app_theme.dart';
import '../../../data/models/models.dart';
import '../../controllers/session_controller.dart';

/// Session complete page - summary and cleanup
class SessionCompletePage extends StatelessWidget {
  const SessionCompletePage({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionController = Get.find<SessionController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),

              // Success icon
              const Icon(
                Icons.check_circle,
                size: 100,
                color: AppColors.success,
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Session Complete!',
                style: AppTypography.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              Obx(
                () => Text(
                  'Session ${sessionController.currentSession.value?.sessionCode ?? ''}',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),

              // Summary card
              _buildSummaryCard(sessionController),
              const SizedBox(height: 16),

              // Data quality card
              _buildQualityCard(sessionController),
              const SizedBox(height: 16),

              // Calibration card
              _buildCalibrationCard(sessionController),
              const SizedBox(height: 32),

              // Actions
              ElevatedButton.icon(
                onPressed: () {
                  sessionController.clearSession();
                  Get.offAllNamed(Routes.dashboard);
                },
                icon: const Icon(Icons.home),
                label: const Text('Return to Dashboard'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: () {
                  sessionController.clearSession();
                  Get.offAllNamed(Routes.petSelection);
                },
                icon: const Icon(Icons.add),
                label: const Text('Start New Session'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(SessionController sessionController) {
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
          Row(
            children: [
              const Icon(Icons.summarize, color: AppColors.primary),
              const SizedBox(width: 12),
              Text('Session Summary', style: AppTypography.titleMedium),
            ],
          ),
          const Divider(height: 24),

          // Pet info
          Obx(() {
            final animal = sessionController.currentAnimal.value;
            return _summaryRow('Patient', animal?.name ?? '-');
          }),
          const SizedBox(height: 8),

          // Surgery type
          Obx(() {
            final session = sessionController.currentSession.value;
            return _summaryRow('Surgery', session?.surgeryType ?? '-');
          }),
          const SizedBox(height: 8),

          // Duration
          Obx(
            () => _summaryRow(
              'Total Duration',
              sessionController.sessionDuration.value,
            ),
          ),
          const SizedBox(height: 8),

          // Surgery duration
          Obx(() {
            final session = sessionController.currentSession.value;
            if (session?.surgeryDuration != null) {
              return Column(
                children: [
                  _summaryRow(
                    'Surgery Duration',
                    _formatDuration(session!.surgeryDuration!),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            }
            return const SizedBox.shrink();
          }),

          // Annotations count
          Obx(
            () => _summaryRow(
              'Annotations',
              '${sessionController.sessionAnnotations.length}',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityCard(SessionController sessionController) {
    return Obx(() {
      final session = sessionController.currentSession.value;
      final baselineQuality = session?.baselineQuality ?? 0;
      final overallQuality = session?.overallQualityScore ?? 0;

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
            Row(
              children: [
                const Icon(Icons.analytics, color: AppColors.primary),
                const SizedBox(width: 12),
                Text('Data Quality', style: AppTypography.titleMedium),
              ],
            ),
            const Divider(height: 24),

            // Baseline quality
            _qualityRow('Baseline Quality', baselineQuality),
            const SizedBox(height: 12),

            // Overall quality
            _qualityRow('Overall Quality', overallQuality),
            const SizedBox(height: 12),

            // Training recommendation
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: overallQuality >= 75
                    ? AppColors.successSurface
                    : overallQuality >= 50
                    ? AppColors.warningSurface
                    : AppColors.errorSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    overallQuality >= 75
                        ? Icons.check_circle
                        : overallQuality >= 50
                        ? Icons.info
                        : Icons.warning,
                    color: overallQuality >= 75
                        ? AppColors.success
                        : overallQuality >= 50
                        ? AppColors.warning
                        : AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      overallQuality >= 75
                          ? 'Excellent quality - recommended for ML training'
                          : overallQuality >= 50
                          ? 'Acceptable quality - usable for training'
                          : 'Low quality - may need review',
                      style: AppTypography.bodySmall.copyWith(
                        color: overallQuality >= 75
                            ? AppColors.successDark
                            : overallQuality >= 50
                            ? AppColors.warningDark
                            : AppColors.errorDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCalibrationCard(SessionController sessionController) {
    return Obx(() {
      final session = sessionController.currentSession.value;
      final isCalibrated = session?.isCalibrated ?? false;

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
            Row(
              children: [
                const Icon(Icons.tune, color: AppColors.primary),
                const SizedBox(width: 12),
                Text('Calibration', style: AppTypography.titleMedium),
              ],
            ),
            const Divider(height: 24),

            // Calibration status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Status'),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isCalibrated
                        ? AppColors.successSurface
                        : AppColors.warningSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isCalibrated ? 'Calibrated ✓' : 'Not Calibrated',
                    style: AppTypography.labelMedium.copyWith(
                      color: isCalibrated
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),

            if (isCalibrated && session?.calibrationCorrelation != null) ...[
              const SizedBox(height: 12),
              _summaryRow(
                'Correlation (r)',
                session!.calibrationCorrelation!.toStringAsFixed(3),
              ),
              const SizedBox(height: 8),
              _summaryRow(
                'Mean Error',
                '±${session.calibrationErrorBpm?.toStringAsFixed(1) ?? '-'} bpm',
              ),
              const SizedBox(height: 8),
              _summaryRow('Quality', session.calibrationQualityLabel ?? '-'),
            ],
          ],
        ),
      );
    });
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodyMedium),
        Text(value, style: AppTypography.titleSmall),
      ],
    );
  }

  Widget _qualityRow(String label, int quality) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.bodyMedium),
            Text(
              '$quality%',
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.getQualityColor(quality),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: quality / 100,
          backgroundColor: AppColors.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(
            AppColors.getQualityColor(quality),
          ),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}
