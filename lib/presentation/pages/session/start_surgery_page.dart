import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_pages.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_typography.dart';
import '../../../app/themes/app_theme.dart';
import '../../../data/models/models.dart';
import '../../controllers/session_controller.dart';
import '../../widgets/common_widgets.dart';

/// Start surgery confirmation page - final checks before surgery begins
class StartSurgeryPage extends StatefulWidget {
  const StartSurgeryPage({super.key});

  @override
  State<StartSurgeryPage> createState() => _StartSurgeryPageState();
}

class _StartSurgeryPageState extends State<StartSurgeryPage> {
  final SessionController _sessionController = Get.find<SessionController>();

  // Checklist state
  final RxMap<String, bool> checklist = <String, bool>{
    'collar_secure': false,
    'ecg_ready': false,
    'anesthesia_stable': false,
    'team_ready': false,
  }.obs;

  // Surgery type
  final surgeryTypeController = TextEditingController();
  final RxString selectedSurgeryType = ''.obs;
  final RxBool isLoading = false.obs;

  bool get allChecked => checklist.values.every((v) => v);

  @override
  void dispose() {
    surgeryTypeController.dispose();
    super.dispose();
  }

  Future<void> _startSurgery() async {
    if (!allChecked) {
      Get.snackbar(
        'Complete Checklist',
        'Please verify all items before starting surgery',
        backgroundColor: AppColors.warning,
      );
      return;
    }

    final surgeryType = selectedSurgeryType.value.isNotEmpty
        ? selectedSurgeryType.value
        : surgeryTypeController.text.trim();

    if (surgeryType.isEmpty) {
      Get.snackbar('Error', 'Please specify the surgery type');
      return;
    }

    isLoading.value = true;

    try {
      final success = await _sessionController.startSurgery(
        surgeryType: surgeryType,
        surgeryReason:
            '', // TODO: Replace with actual reason or collect from user
        asaStatus: ASAStatus
            .values
            .first, // TODO: Replace with actual ASA status or collect from user
      );

      if (success) {
        Get.offNamed(Routes.surgery);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to start surgery');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Start Surgery'),
        backgroundColor: AppColors.surgeryBanner,
      ),
      body: Obx(
        () => LoadingOverlay(
          isLoading: isLoading.value,
          message: 'Starting surgery...',
          child: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Warning banner
                _buildWarningBanner(),
                const SizedBox(height: 24),

                // Patient info
                _buildPatientInfo(),
                const SizedBox(height: 24),

                // Surgery type selection
                _buildSurgeryTypeSection(),
                const SizedBox(height: 24),

                // Pre-surgery checklist
                _buildChecklist(),
                const SizedBox(height: 32),

                // Start button
                _buildStartButton(),
                const SizedBox(height: 16),

                // Cancel button
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surgeryBanner,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surgeryRed.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber,
            color: AppColors.surgeryRed,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Starting Surgery Mode',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.surgeryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'The collar will switch to raw data transmission mode '
                  'for maximum signal fidelity.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.surgeryText.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientInfo() {
    final animal = _sessionController.currentAnimal.value;
    final collar = _sessionController.currentCollar.value;

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
          Text('Patient Information', style: AppTypography.titleSmall),
          const Divider(height: 24),
          _infoRow('Patient', animal?.name ?? '-'),
          const SizedBox(height: 8),
          _infoRow(
            'Species/Breed',
            '${animal?.species.displayName ?? '-'} - ${animal?.breed ?? '-'}',
          ),
          const SizedBox(height: 8),
          _infoRow('Weight', animal?.weightDisplay ?? '-'),
          const SizedBox(height: 8),
          _infoRow('Collar', collar?.serialNumber ?? '-'),
          const SizedBox(height: 8),
          _infoRow('Battery', '${collar?.batteryPercent ?? 0}%'),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySmall),
        Text(value, style: AppTypography.labelMedium),
      ],
    );
  }

  Widget _buildSurgeryTypeSection() {
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
          Text('Surgery Type *', style: AppTypography.titleSmall),
          const SizedBox(height: 12),

          // Common surgery types
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  [
                        'Spay',
                        'Neuter',
                        'Dental',
                        'Mass Removal',
                        'Orthopedic',
                        'Abdominal',
                      ]
                      .map(
                        (type) => ChoiceChip(
                          label: Text(type),
                          selected: selectedSurgeryType.value == type,
                          onSelected: (_) {
                            selectedSurgeryType.value = type;
                            surgeryTypeController.clear();
                          },
                        ),
                      )
                      .toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Custom surgery type
          TextField(
            controller: surgeryTypeController,
            decoration: const InputDecoration(
              labelText: 'Or enter custom surgery type',
              hintText: 'e.g., Laparoscopy',
            ),
            onChanged: (_) => selectedSurgeryType.value = '',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pre-Surgery Checklist', style: AppTypography.titleSmall),
              Obx(
                () => Text(
                  '${checklist.values.where((v) => v).length}/${checklist.length}',
                  style: AppTypography.labelMedium.copyWith(
                    color: allChecked
                        ? AppColors.success
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          Obx(
            () => Column(
              children: [
                _checklistItem(
                  'collar_secure',
                  'Collar secured and positioned correctly',
                  Icons.bluetooth_connected,
                ),
                _checklistItem(
                  'ecg_ready',
                  'ECG equipment ready for calibration',
                  Icons.monitor_heart,
                ),
                _checklistItem(
                  'anesthesia_stable',
                  'Anesthesia stable and monitored',
                  Icons.air,
                ),
                _checklistItem(
                  'team_ready',
                  'Surgical team ready to proceed',
                  Icons.groups,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _checklistItem(String key, String label, IconData icon) {
    final isChecked = checklist[key] ?? false;

    return InkWell(
      onTap: () => checklist[key] = !isChecked,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isChecked ? AppColors.success : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isChecked ? AppColors.success : AppColors.border,
                  width: 2,
                ),
              ),
              child: isChecked
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  decoration: isChecked ? TextDecoration.lineThrough : null,
                  color: isChecked
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return Obx(
      () => ElevatedButton.icon(
        onPressed: allChecked ? _startSurgery : null,
        icon: const Icon(Icons.play_arrow),
        label: const Text('BEGIN SURGERY'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.surgeryRed,
          disabledBackgroundColor: AppColors.surfaceVariant,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
