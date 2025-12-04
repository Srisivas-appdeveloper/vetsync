import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_pages.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_typography.dart';
import '../../../app/themes/app_theme.dart';
import '../../../data/models/models.dart';
import '../../controllers/session_controller.dart';
import '../../controllers/baseline_controller.dart';

/// Baseline complete page - shows baseline results and proceed options
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
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            
            // Success icon
            const Icon(
              Icons.check_circle,
              size: 80,
              color: AppColors.success,
            ),
            const SizedBox(height: 16),
            
            Text(
              'Baseline Collection Complete',
              style: AppTypography.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            Obx(() => Text(
              'Patient: ${sessionController.currentAnimal.value?.name ?? "Unknown"}',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            )),
            const SizedBox(height: 32),
            
            // Results card
            _buildResultsCard(baselineController),
            const SizedBox(height: 16),
            
            // Quality assessment
            _buildQualityAssessment(baselineController),
            const SizedBox(height: 32),
            
            // Actions
            ElevatedButton(
              onPressed: () => Get.offNamed(Routes.preSurgery),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Continue to Pre-Surgery'),
            ),
            const SizedBox(height: 12),
            
            OutlinedButton(
              onPressed: () {
                baselineController.restartCollection();
                Get.back();
              },
              child: const Text('Recollect Baseline'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  Widget _buildResultsCard(BaselineController controller) {
    return Obx(() {
      final baseline = controller.baselineData.value;
      
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
            Text('Baseline Values', style: AppTypography.titleMedium),
            const Divider(height: 24),
            
            // Heart Rate
            _resultRow(
              icon: Icons.favorite,
              iconColor: AppColors.error,
              label: 'Heart Rate',
              value: baseline != null 
                  ? '${baseline.heartRate.mean.round()} bpm'
                  : '-- bpm',
              range: baseline != null
                  ? '${baseline.heartRate.min.round()}-${baseline.heartRate.max.round()}'
                  : '--',
            ),
            const SizedBox(height: 16),
            
            // Respiratory Rate
            _resultRow(
              icon: Icons.air,
              iconColor: AppColors.primary,
              label: 'Respiratory Rate',
              value: baseline != null
                  ? '${baseline.respiratoryRate.mean.round()} brpm'
                  : '-- brpm',
              range: baseline != null
                  ? '${baseline.respiratoryRate.min.round()}-${baseline.respiratoryRate.max.round()}'
                  : '--',
            ),
            const SizedBox(height: 16),
            
            // Temperature
            _resultRow(
              icon: Icons.thermostat,
              iconColor: AppColors.warning,
              label: 'Temperature',
              value: baseline != null
                  ? '${baseline.temperature.mean.toStringAsFixed(1)} °C'
                  : '-- °C',
              range: baseline != null
                  ? '${baseline.temperature.min.toStringAsFixed(1)}-${baseline.temperature.max.toStringAsFixed(1)}'
                  : '--',
            ),
            const Divider(height: 24),
            
            // Duration
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Collection Duration', style: AppTypography.bodySmall),
                Text(
                  baseline?.formattedDuration ?? '--:--',
                  style: AppTypography.labelMedium,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
  
  Widget _resultRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String range,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.bodySmall),
              const SizedBox(height: 2),
              Text(value, style: AppTypography.titleMedium),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Range', style: AppTypography.caption),
            Text(range, style: AppTypography.labelSmall),
          ],
        ),
      ],
    );
  }
  
  Widget _buildQualityAssessment(BaselineController controller) {
    return Obx(() {
      final baseline = controller.baselineData.value;
      final quality = baseline?.qualityScore ?? 0;
      
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getQualityBackgroundColor(quality),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _getQualityColor(quality).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getQualityColor(quality),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$quality%',
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getQualityLabel(quality),
                    style: AppTypography.titleSmall.copyWith(
                      color: _getQualityTextColor(quality),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getQualityDescription(quality),
                    style: AppTypography.bodySmall.copyWith(
                      color: _getQualityTextColor(quality).withOpacity(0.8),
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
  
  String _getQualityLabel(int quality) {
    if (quality >= 90) return 'Excellent Quality';
    if (quality >= 75) return 'Good Quality';
    if (quality >= 50) return 'Acceptable Quality';
    return 'Low Quality';
  }
  
  String _getQualityDescription(int quality) {
    if (quality >= 90) return 'Optimal for ML training dataset';
    if (quality >= 75) return 'Good baseline for comparison';
    if (quality >= 50) return 'Usable but consider recollection';
    return 'Recollection recommended';
  }
  
  Color _getQualityColor(int quality) {
    if (quality >= 75) return AppColors.success;
    if (quality >= 50) return AppColors.warning;
    return AppColors.error;
  }
  
  Color _getQualityBackgroundColor(int quality) {
    if (quality >= 75) return AppColors.successSurface;
    if (quality >= 50) return AppColors.warningSurface;
    return AppColors.errorSurface;
  }
  
  Color _getQualityTextColor(int quality) {
    if (quality >= 75) return AppColors.successDark;
    if (quality >= 50) return AppColors.warningDark;
    return AppColors.errorDark;
  }
}
