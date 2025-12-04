import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_pages.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_typography.dart';
import '../../../app/themes/app_theme.dart';
import '../../../data/models/models.dart';
import '../../controllers/session_controller.dart';
import '../../widgets/common_widgets.dart';

/// End session confirmation page
class EndSessionPage extends StatefulWidget {
  const EndSessionPage({super.key});

  @override
  State<EndSessionPage> createState() => _EndSessionPageState();
}

class _EndSessionPageState extends State<EndSessionPage> {
  final SessionController _sessionController = Get.find<SessionController>();

  final notesController = TextEditingController();
  final RxString outcome = 'successful'.obs;
  final RxBool isLoading = false.obs;

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  Future<void> _endSession() async {
    isLoading.value = true;

    try {
      // Add final notes if provided
      if (notesController.text.isNotEmpty) {
        await _sessionController.addAnnotation(
          category: AnnotationCategory.event,
          type: 'session_notes',
          description: notesController.text.trim(),
        );
      }

      // Add outcome annotation
      await _sessionController.addAnnotation(
        category: AnnotationCategory.event,
        type: 'session_outcome',
        description: 'Outcome: ${outcome.value}',
      );

      final success = await _sessionController.endSession();

      if (success) {
        Get.offAllNamed(Routes.sessionComplete);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to end session');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('End Session')),
      body: Obx(
        () => LoadingOverlay(
          isLoading: isLoading.value,
          message: 'Saving session...',
          child: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Session summary
                _buildSessionSummary(),
                const SizedBox(height: 24),

                // Outcome selection
                _buildOutcomeSelection(),
                const SizedBox(height: 24),

                // Final notes
                _buildNotesSection(),
                const SizedBox(height: 32),

                // End button
                ElevatedButton(
                  onPressed: _endSession,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Complete Session'),
                ),
                const SizedBox(height: 12),

                // Cancel
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Continue Monitoring'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionSummary() {
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
          Text('Session Summary', style: AppTypography.titleMedium),
          const Divider(height: 24),

          // Patient
          Obx(
            () => _summaryRow(
              'Patient',
              _sessionController.currentAnimal.value?.name ?? '-',
            ),
          ),
          const SizedBox(height: 8),

          // Session code
          Obx(
            () => _summaryRow(
              'Session Code',
              _sessionController.currentSession.value?.sessionCode ?? '-',
            ),
          ),
          const SizedBox(height: 8),

          // Total duration
          Obx(
            () => _summaryRow(
              'Total Duration',
              _sessionController.sessionDuration.value,
            ),
          ),
          const SizedBox(height: 8),

          // Current phase
          Obx(
            () => _summaryRow(
              'Current Phase',
              _sessionController
                      .currentSession
                      .value
                      ?.currentPhase
                      .displayName ??
                  '-',
            ),
          ),
          const SizedBox(height: 8),

          // Annotations count
          Obx(
            () => _summaryRow(
              'Total Annotations',
              '${_sessionController.sessionAnnotations.length}',
            ),
          ),
          const SizedBox(height: 8),

          // Calibration status
          Obx(() {
            final session = _sessionController.currentSession.value;
            return _summaryRow(
              'Calibrated',
              session?.isCalibrated == true
                  ? 'Yes (r=${session?.calibrationCorrelation?.toStringAsFixed(2) ?? "-"})'
                  : 'No',
            );
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

  Widget _buildOutcomeSelection() {
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
          Text('Surgery Outcome', style: AppTypography.titleSmall),
          const SizedBox(height: 12),

          Obx(
            () => Column(
              children: [
                _outcomeOption(
                  'successful',
                  'Successful',
                  'Surgery completed without complications',
                  Icons.check_circle,
                  AppColors.success,
                ),
                const SizedBox(height: 8),
                _outcomeOption(
                  'complications',
                  'With Complications',
                  'Surgery completed with minor issues',
                  Icons.warning,
                  AppColors.warning,
                ),
                const SizedBox(height: 8),
                _outcomeOption(
                  'aborted',
                  'Aborted',
                  'Surgery was terminated early',
                  Icons.cancel,
                  AppColors.error,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _outcomeOption(
    String value,
    String label,
    String description,
    IconData icon,
    Color color,
  ) {
    final isSelected = outcome.value == value;

    return InkWell(
      onTap: () => outcome.value = value,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.labelMedium.copyWith(
                      color: isSelected ? color : AppColors.textPrimary,
                    ),
                  ),
                  Text(description, style: AppTypography.caption),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Final Notes (optional)', style: AppTypography.labelMedium),
        const SizedBox(height: 8),
        TextField(
          controller: notesController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Any final observations or notes about the session...',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
