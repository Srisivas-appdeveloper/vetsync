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

/// Recovery monitoring page - post-surgery monitoring
class RecoveryPage extends StatelessWidget {
  const RecoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionController = Get.find<SessionController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Recovery header
            _buildRecoveryHeader(sessionController),

            // Status bar
            Obx(
              () => SessionStatusBar(
                collarId: sessionController.currentCollar.value?.serialNumber,
                isConnected: sessionController.isCollarConnected,
                batteryPercent: sessionController.batteryPercent.value,
                signalQuality: sessionController.signalQuality.value,
              ),
            ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Vitals
                    _buildVitalsSection(sessionController),
                    const SizedBox(height: 16),

                    // Waveform
                    _buildWaveformSection(),
                    const SizedBox(height: 16),

                    // Quick physiological events
                    _buildPhysioEvents(sessionController),
                    const SizedBox(height: 16),

                    // Session summary
                    _buildSessionSummary(sessionController),
                    const SizedBox(height: 24),

                    // End session button
                    _buildEndSessionButton(sessionController),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAnnotationSheet(sessionController),
        child: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildRecoveryHeader(SessionController sessionController) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.recoveryBanner,
        border: Border(
          bottom: BorderSide(color: AppColors.recoveryGreen.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          // Recovery indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.recoveryGreen,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite, size: 16, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  'RECOVERY',
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Timer
          Expanded(
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sessionController.phaseDuration.value,
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.successDark,
                    ),
                  ),
                  Text(
                    'Recovery Duration',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.successDark.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Total session time
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  sessionController.sessionDuration.value,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.successDark,
                  ),
                ),
                Text(
                  'Total Session',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.successDark.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsSection(SessionController sessionController) {
    return Obx(() {
      final vitals = sessionController.latestVitals.value;
      final animal = sessionController.currentAnimal.value;
      final ranges = animal?.vitalRanges;

      return Row(
        children: [
          Expanded(
            child: VitalCard(
              label: 'Heart Rate',
              value: vitals?.heartRateBpm.toString() ?? '--',
              unit: 'bpm',
              icon: Icons.favorite,
              range: ranges?.heartRate,
              currentValue: vitals?.heartRateBpm.toDouble(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: VitalCard(
              label: 'Resp Rate',
              value: vitals?.respiratoryRateBpm.toString() ?? '--',
              unit: 'brpm',
              icon: Icons.air,
              range: ranges?.respiratoryRate,
              currentValue: vitals?.respiratoryRateBpm.toDouble(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: VitalCard(
              label: 'Temp',
              value: vitals?.temperatureC.toStringAsFixed(1) ?? '--',
              unit: '°C',
              icon: Icons.thermostat,
              range: ranges?.temperature,
              currentValue: vitals?.temperatureC,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildWaveformSection() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const RealtimeWaveformChart(
        displaySeconds: 10,
        sampleRate: 100, // Filtered mode in recovery
        minY: -1.0,
        maxY: 1.0,
        title: 'BCG Signal',
        lineColor: AppColors.success,
      ),
    );
  }

  Widget _buildPhysioEvents(SessionController sessionController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Events', style: AppTypography.titleSmall),
        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _QuickEventButton(
              label: 'Awake',
              icon: Icons.visibility,
              onPressed: () => sessionController.addAnnotation(
                category: AnnotationCategory.recovery,
                type: 'awakening',
                description: 'Patient showing signs of awakening',
              ),
            ),
            _QuickEventButton(
              label: 'Moving',
              icon: Icons.directions_walk,
              onPressed: () => sessionController.addAnnotation(
                category: AnnotationCategory.recovery,
                type: 'movement',
                description: 'Voluntary movement observed',
              ),
            ),
            _QuickEventButton(
              label: 'Stable',
              icon: Icons.check_circle,
              onPressed: () => sessionController.addAnnotation(
                category: AnnotationCategory.recovery,
                type: 'stable',
                description: 'Vitals stable',
              ),
            ),
            _QuickEventButton(
              label: 'Urination',
              icon: Icons.water_drop,
              onPressed: () => sessionController.addPhysiologicalEvent(
                eventType: PhysiologicalEventType.urination,
              ),
            ),
            _QuickEventButton(
              label: 'Vomit',
              icon: Icons.warning,
              color: AppColors.error,
              onPressed: () => sessionController.addPhysiologicalEvent(
                eventType: PhysiologicalEventType.vomiting,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSessionSummary(SessionController sessionController) {
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
          Text('Session Summary', style: AppTypography.titleSmall),
          const SizedBox(height: 12),

          Obx(
            () => _summaryRow(
              'Total Duration',
              sessionController.sessionDuration.value,
            ),
          ),
          const SizedBox(height: 8),

          Obx(
            () => _summaryRow(
              'Annotations',
              '${sessionController.sessionAnnotations.length}',
            ),
          ),
          const SizedBox(height: 8),

          Obx(() {
            final session = sessionController.currentSession.value;
            return _summaryRow(
              'Calibrated',
              session?.isCalibrated == true ? 'Yes ✓' : 'No',
            );
          }),
          const SizedBox(height: 8),

          Obx(() {
            final session = sessionController.currentSession.value;
            if (session?.calibrationCorrelation != null) {
              return _summaryRow(
                'Correlation',
                'r = ${session!.calibrationCorrelation!.toStringAsFixed(3)}',
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySmall),
        Text(value, style: AppTypography.labelMedium),
      ],
    );
  }

  Widget _buildEndSessionButton(SessionController sessionController) {
    return ElevatedButton.icon(
      onPressed: () => _showEndSessionDialog(sessionController),
      icon: const Icon(Icons.stop),
      label: const Text('End Session'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  void _showEndSessionDialog(SessionController sessionController) {
    Get.dialog(
      AlertDialog(
        title: const Text('End Session?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to end this session?'),
            const SizedBox(height: 16),
            Obx(
              () => Text(
                'Duration: ${sessionController.sessionDuration.value}',
                style: AppTypography.bodySmall,
              ),
            ),
            Obx(
              () => Text(
                'Annotations: ${sessionController.sessionAnnotations.length}',
                style: AppTypography.bodySmall,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final success = await sessionController.endSession();
              if (success) {
                Get.offNamed(Routes.sessionComplete);
              }
            },
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }

  void _showAnnotationSheet(SessionController sessionController) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Add Recovery Note', style: AppTypography.titleLarge),
            const SizedBox(height: 16),

            // Quick options
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _AnnotationOption(
                  label: '🏥 Ready for Discharge',
                  onTap: () {
                    Get.back();
                    sessionController.addAnnotation(
                      category: AnnotationCategory.recovery,
                      type: 'discharge_ready',
                    );
                  },
                ),
                _AnnotationOption(
                  label: '👁️ Eyes Opening',
                  onTap: () {
                    Get.back();
                    sessionController.addAnnotation(
                      category: AnnotationCategory.recovery,
                      type: 'eyes_opening',
                    );
                  },
                ),
                _AnnotationOption(
                  label: '💉 Pain Medication',
                  onTap: () {
                    Get.back();
                    sessionController.addAnnotation(
                      category: AnnotationCategory.medication,
                      type: 'pain_medication',
                    );
                  },
                ),
                _AnnotationOption(
                  label: '🌡️ Temperature Check',
                  onTap: () {
                    Get.back();
                    sessionController.addAnnotation(
                      category: AnnotationCategory.recovery,
                      type: 'temperature_check',
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _QuickEventButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;

  const _QuickEventButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: buttonColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: buttonColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: buttonColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(color: buttonColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnnotationOption extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AnnotationOption({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: AppTypography.labelMedium),
      ),
    );
  }
}
