import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_pages.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_typography.dart';
import '../../../app/themes/app_theme.dart';
import '../../../data/models/models.dart';
import '../../controllers/session_controller.dart';
import '../../widgets/common_widgets.dart';

/// Pre-surgery monitoring page - after baseline, before surgery starts
class PreSurgeryPage extends StatefulWidget {
  const PreSurgeryPage({super.key});

  @override
  State<PreSurgeryPage> createState() => _PreSurgeryPageState();
}

class _PreSurgeryPageState extends State<PreSurgeryPage> {
  late final SessionController sessionController;

  @override
  void initState() {
    super.initState();
    sessionController = Get.find<SessionController>();

    // Debug logging
    print('[PreSurgery] ========================================');
    print('[PreSurgery] INIT STATE');
    print('[PreSurgery] SessionController session ID: ${sessionController.currentSession.value?.id ?? "NULL"}');

    // Get session from navigation arguments if available (for reference)
    final passedSession = Get.arguments as Session?;
    if (passedSession != null) {
      print('[PreSurgery] Passed session ID: ${passedSession.id}');

      // ALWAYS trust the SessionController session, only update if passed session is better
      if (passedSession.id.isNotEmpty &&
          sessionController.currentSession.value?.id != passedSession.id) {
        print('[PreSurgery] ✅ Updating session from navigation: ${passedSession.id}');
        sessionController.currentSession.value = passedSession;
      } else if (passedSession.id.isEmpty) {
        print('[PreSurgery] ⚠️ WARNING: Passed session has EMPTY ID - ignoring it');
        print('[PreSurgery] ⚠️ Keeping SessionController session: ${sessionController.currentSession.value?.id}');
      }
    }

    // Final validation
    final finalSessionId = sessionController.currentSession.value?.id;
    if (finalSessionId == null || finalSessionId.isEmpty) {
      print('[PreSurgery] ❌ CRITICAL: No valid session ID available!');
      print('[PreSurgery] Session object: ${sessionController.currentSession.value}');
    } else {
      print('[PreSurgery] ✅ Using session ID: $finalSessionId');
    }

    print('[PreSurgery] ========================================');

    // Load baseline data when entering pre-surgery phase
    // This ensures baseline is available even if navigating from other routes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sessionController.loadBaselineData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Pre-surgery header
            _buildPreSurgeryHeader(sessionController),

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
                    // Vitals display
                    _buildVitalsSection(sessionController),
                    const SizedBox(height: 16),

                    // Baseline summary
                    _buildBaselineSummary(sessionController),
                    const SizedBox(height: 16),

                    // Quick annotations
                    _buildQuickAnnotations(sessionController),
                    const SizedBox(height: 24),

                    // Start surgery button
                    _buildStartSurgeryButton(sessionController),
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
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPreSurgeryHeader(SessionController sessionController) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.preSurgeryBanner,
        border: Border(
          bottom: BorderSide(color: AppColors.info.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          // Phase indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.info,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.schedule, size: 16, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  'PRE-SURGERY',
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
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.infoDark,
                    ),
                  ),
                  Text(
                    'Waiting Duration',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.infoDark.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Pet info
          Obx(() {
            final animal = sessionController.currentAnimal.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  animal?.name ?? '',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.infoDark,
                  ),
                ),
                Text(
                  animal?.breed ?? '',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.infoDark.withOpacity(0.7),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildVitalsSection(SessionController sessionController) {
    return Obx(() {
      final vitals = sessionController.latestVitals.value;
      final animal = sessionController.currentAnimal.value;
      final ranges = animal?.vitalRanges;

      return LayoutBuilder(
        builder: (context, constraints) {
          // Use Row layout for normal screens, adjust sizing for very small screens
          final isSmallScreen = constraints.maxWidth < 360;

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
                  compact: isSmallScreen,
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
                  compact: isSmallScreen,
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
                  compact: isSmallScreen,
                ),
              ),
            ],
          );
        },
      );
    });
  }

  Widget _buildBaselineSummary(SessionController sessionController) {
    return Obx(() {
      final baseline = sessionController.baselineData.value;

      if (baseline == null) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.warningSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.warning.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.warning,
                    color: AppColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No baseline data available',
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.warningDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Consider collecting baseline for better monitoring and anomaly detection.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.warningDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _returnToBaselineCollection(),
                  icon: const Icon(Icons.analytics_outlined, size: 18),
                  label: const Text('Collect Baseline'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.warning,
                    side: BorderSide(color: AppColors.warning),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.successSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.success.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Baseline Collected (${baseline.qualityScore}% quality)',
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.successDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _baselineStat(
                  'HR',
                  '${baseline.heartRate.mean.round()} bpm',
                  range: '${baseline.heartRate.min.round()}-${baseline.heartRate.max.round()}',
                ),
                _baselineStat(
                  'RR',
                  '${baseline.respiratoryRate.mean.round()} brpm',
                  range: '${baseline.respiratoryRate.min.round()}-${baseline.respiratoryRate.max.round()}',
                ),
                if (baseline.temperature.mean > 15 && baseline.temperature.mean < 45)
                  _baselineStat(
                    'Temp',
                    '${baseline.temperature.mean.toStringAsFixed(1)} °C',
                    range: '${baseline.temperature.min.toStringAsFixed(1)}-${baseline.temperature.max.toStringAsFixed(1)}',
                  ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _baselineStat(String label, String value, {String? range}) {
    return Column(
      children: [
        Text(label, style: AppTypography.caption),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.successDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (range != null) ...[
          const SizedBox(height: 2),
          Text(
            range,
            style: AppTypography.caption.copyWith(
              color: AppColors.successDark.withOpacity(0.7),
              fontSize: 10,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuickAnnotations(SessionController sessionController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Annotations', style: AppTypography.titleSmall),
        const SizedBox(height: 12),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              QuickAnnotationButton(
                label: 'Anxious',
                emoji: '😰',
                onPressed: () => sessionController.addAnnotation(
                  category: AnnotationCategory.behavior,
                  type: 'anxiety_observed',
                ),
              ),
              const SizedBox(width: 8),
              QuickAnnotationButton(
                label: 'Medication',
                emoji: '💊',
                onPressed: () => sessionController.addAnnotation(
                  category: AnnotationCategory.medication,
                  type: 'pre_medication',
                ),
              ),
              const SizedBox(width: 8),
              QuickAnnotationButton(
                label: 'Prep Done',
                emoji: '✅',
                onPressed: () => sessionController.addAnnotation(
                  category: AnnotationCategory.preparation,
                  type: 'preparation_complete',
                ),
              ),
              const SizedBox(width: 8),
              QuickAnnotationButton(
                label: 'IV Started',
                emoji: '💉',
                onPressed: () => sessionController.addAnnotation(
                  category: AnnotationCategory.preparation,
                  type: 'iv_catheter_placed',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStartSurgeryButton(SessionController sessionController) {
    return ElevatedButton.icon(
      onPressed: () => Get.toNamed(Routes.startSurgery),
      icon: const Icon(Icons.play_arrow),
      label: const Text('Start Surgery'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.surgeryRed,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  void _returnToBaselineCollection() {
    // Navigate back to baseline collection page
    Get.back(); // Go back from pre-surgery
    Get.toNamed(Routes.baselineCollection);
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
            Text('Add Pre-Surgery Note', style: AppTypography.titleLarge),
            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _AnnotationOption(
                  label: '🩺 Vitals Check',
                  onTap: () {
                    Get.back();
                    sessionController.addAnnotation(
                      category: AnnotationCategory.preparation,
                      type: 'vitals_check',
                    );
                  },
                ),
                _AnnotationOption(
                  label: '🧴 Skin Prep',
                  onTap: () {
                    Get.back();
                    sessionController.addAnnotation(
                      category: AnnotationCategory.preparation,
                      type: 'skin_preparation',
                    );
                  },
                ),
                _AnnotationOption(
                  label: '💊 Sedation Given',
                  onTap: () {
                    Get.back();
                    sessionController.addAnnotation(
                      category: AnnotationCategory.anesthesia,
                      type: 'sedation_given',
                    );
                  },
                ),
                _AnnotationOption(
                  label: '🫁 Intubation',
                  onTap: () {
                    Get.back();
                    sessionController.addAnnotation(
                      category: AnnotationCategory.anesthesia,
                      type: 'intubation',
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
