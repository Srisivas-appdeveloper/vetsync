import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/themes/app_colors.dart';
import '../../data/models/models.dart';
import '../controllers/session_controller.dart';

/// Slide-up panel for adding annotations during a session
class AnnotationPanel extends StatefulWidget {
  final VoidCallback onClose;
  final Function(Annotation)? onAnnotationAdded;

  const AnnotationPanel({
    super.key,
    required this.onClose,
    this.onAnnotationAdded,
  });

  @override
  State<AnnotationPanel> createState() => _AnnotationPanelState();
}

class _AnnotationPanelState extends State<AnnotationPanel> {
  final SessionController _sessionController = Get.find<SessionController>();
  final TextEditingController _notesController = TextEditingController();

  AnnotationCategory _selectedCategory = AnnotationCategory.event;
  PhysiologicalEventType? _selectedEventType;
  AnnotationSeverity _selectedSeverity = AnnotationSeverity.info;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: Colors.black54,
        child: GestureDetector(
          onTap: () {}, // Prevent tap through
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Add Annotation',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: widget.onClose,
                        ),
                      ],
                    ),
                  ),

                  const Divider(),

                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category selection
                          const Text(
                            'Category',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildCategoryChips(),
                          const SizedBox(height: 16),

                          // Event type (for physiological)
                          if (_selectedCategory ==
                              AnnotationCategory.physiological) ...[
                            const Text(
                              'Event Type',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildEventTypeDropdown(),
                            const SizedBox(height: 16),
                          ],

                          // Severity
                          const Text(
                            'Severity',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildSeverityChips(),
                          const SizedBox(height: 16),

                          // Notes
                          const Text(
                            'Notes (optional)',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Add additional notes...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: AppColors.surface,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Quick annotations
                          _buildQuickAnnotations(),
                          const SizedBox(height: 24),

                          // Submit button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSubmitting
                                  ? null
                                  : _submitAnnotation,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Add Annotation'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = [
      AnnotationCategory.event,
      AnnotationCategory.physiological,
      AnnotationCategory.surgical,
      AnnotationCategory.medication,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((category) {
        final isSelected = _selectedCategory == category;
        return ChoiceChip(
          label: Text(category.displayName),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedCategory = category;
              _selectedEventType = null;
            });
          },
          selectedColor: AppColors.primary.withValues(alpha: 0.2),
          labelStyle: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEventTypeDropdown() {
    return DropdownButtonFormField<PhysiologicalEventType>(
      value: _selectedEventType,
      hint: const Text('Select event type'),
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: PhysiologicalEventType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Row(
            children: [
              if (type.isCritical)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.warning, color: AppColors.error, size: 16),
                ),
              Text(type.displayName),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedEventType = value;
          if (value?.isCritical == true) {
            _selectedSeverity = AnnotationSeverity.critical;
          }
        });
      },
    );
  }

  Widget _buildSeverityChips() {
    final severities = [
      AnnotationSeverity.info,
      AnnotationSeverity.warning,
      AnnotationSeverity.critical,
    ];

    return Wrap(
      spacing: 8,
      children: severities.map((severity) {
        final isSelected = _selectedSeverity == severity;
        Color chipColor;
        switch (severity) {
          case AnnotationSeverity.info:
            chipColor = AppColors.info;
            break;
          case AnnotationSeverity.warning:
            chipColor = AppColors.warning;
            break;
          case AnnotationSeverity.critical:
            chipColor = AppColors.error;
            break;
        }

        return ChoiceChip(
          label: Text(severity.displayName),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedSeverity = severity;
            });
          },
          selectedColor: chipColor.withValues(alpha: 0.2),
          labelStyle: TextStyle(
            color: isSelected ? chipColor : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickAnnotations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Add',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _QuickButton(
              label: 'Movement',
              icon: Icons.directions_walk,
              onTap: () =>
                  _quickAdd('Movement detected', AnnotationCategory.behavior),
            ),
            _QuickButton(
              label: 'Position Change',
              icon: Icons.rotate_right,
              onTap: () =>
                  _quickAdd('Position changed', AnnotationCategory.behavior),
            ),
            _QuickButton(
              label: 'Vocalization',
              icon: Icons.record_voice_over,
              onTap: () =>
                  _quickAdd('Vocalization', AnnotationCategory.behavior),
            ),
            _QuickButton(
              label: 'Defecation',
              icon: Icons.warning,
              color: AppColors.warning,
              onTap: () =>
                  _quickAddPhysiological(PhysiologicalEventType.defecation),
            ),
            _QuickButton(
              label: 'Urination',
              icon: Icons.water_drop,
              color: AppColors.warning,
              onTap: () =>
                  _quickAddPhysiological(PhysiologicalEventType.urination),
            ),
            _QuickButton(
              label: 'Regurgitation',
              icon: Icons.sick,
              color: AppColors.error,
              onTap: () =>
                  _quickAddPhysiological(PhysiologicalEventType.regurgitation),
            ),
          ],
        ),
      ],
    );
  }

  void _quickAdd(String type, AnnotationCategory category) async {
    setState(() => _isSubmitting = true);

    await _sessionController.addAnnotation(
      category: category,
      type: type,
      severity: AnnotationSeverity.info,
    );

    setState(() => _isSubmitting = false);
    widget.onClose();

    Get.snackbar(
      'Annotation Added',
      type,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  void _quickAddPhysiological(PhysiologicalEventType eventType) async {
    setState(() => _isSubmitting = true);

    await _sessionController.addPhysiologicalEvent(eventType: eventType);

    setState(() => _isSubmitting = false);
    widget.onClose();

    Get.snackbar(
      'Event Logged',
      eventType.displayName,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  void _submitAnnotation() async {
    if (_selectedCategory == AnnotationCategory.physiological &&
        _selectedEventType == null) {
      Get.snackbar(
        'Error',
        'Please select an event type',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final type = _selectedCategory == AnnotationCategory.physiological
        ? _selectedEventType!.displayName
        : _selectedCategory.displayName;

    await _sessionController.addAnnotation(
      category: _selectedCategory,
      type: type,
      description: _notesController.text.isNotEmpty
          ? _notesController.text
          : null,
      severity: _selectedSeverity,
      structuredData: _selectedEventType != null
          ? {'event_type': _selectedEventType!.value}
          : null,
    );

    setState(() => _isSubmitting = false);
    widget.onClose();

    Get.snackbar(
      'Annotation Added',
      type,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }
}

class _QuickButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _QuickButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppColors.primary;

    return Material(
      color: buttonColor.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: buttonColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: buttonColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
