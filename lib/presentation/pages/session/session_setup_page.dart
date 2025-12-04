import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../app/routes/app_pages.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_typography.dart';
import '../../../app/themes/app_theme.dart';
import '../../../data/models/models.dart';
import '../../controllers/session_controller.dart';
import '../../widgets/common_widgets.dart';

/// Session setup page - configure initial session parameters
class SessionSetupPage extends StatefulWidget {
  const SessionSetupPage({super.key});

  @override
  State<SessionSetupPage> createState() => _SessionSetupPageState();
}

class _SessionSetupPageState extends State<SessionSetupPage> {
  final SessionController _sessionController = Get.find<SessionController>();
  final ImagePicker _picker = ImagePicker();
  
  // Form state
  final formKey = GlobalKey<FormState>();
  final notesController = TextEditingController();
  
  final Rx<PetPosition> position = PetPosition.standing.obs;
  final Rx<AnxietyLevel> anxiety = AnxietyLevel.calm.obs;
  final Rx<File?> collarPhoto = Rx<File?>(null);
  final RxBool isLoading = false.obs;
  
  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }
  
  Future<void> _takeCollarPhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        collarPhoto.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to take photo');
    }
  }
  
  Future<void> _startSession() async {
    if (!formKey.currentState!.validate()) return;
    
    isLoading.value = true;
    
    try {
      final success = await _sessionController.initializeSession(
        animal: _sessionController.currentAnimal.value!,
        collar: _sessionController.currentCollar.value!,
        collarPhotoPath: collarPhoto.value?.path,
        position: position.value,
        anxiety: anxiety.value,
        notes: notesController.text.isEmpty ? null : notesController.text,
      );
      
      if (success) {
        Get.offNamed(Routes.baselineCollection);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to start session');
    } finally {
      isLoading.value = false;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Session Setup'),
      ),
      body: Obx(() => LoadingOverlay(
        isLoading: isLoading.value,
        message: 'Starting session...',
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Pet and collar summary
                _buildSummaryCard(),
                const SizedBox(height: 24),
                
                // Collar photo
                _buildCollarPhoto(),
                const SizedBox(height: 24),
                
                // Position selection
                _buildPositionSelection(),
                const SizedBox(height: 24),
                
                // Anxiety level
                _buildAnxietySelection(),
                const SizedBox(height: 24),
                
                // Notes
                _buildNotesField(),
                const SizedBox(height: 32),
                
                // Start button
                ElevatedButton(
                  onPressed: _startSession,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Start Session'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      )),
    );
  }
  
  Widget _buildSummaryCard() {
    final animal = _sessionController.currentAnimal.value;
    final collar = _sessionController.currentCollar.value;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Pet info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      animal?.species == Species.dog 
                          ? Icons.pets 
                          : Icons.cruelty_free,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(animal?.name ?? '-', style: AppTypography.titleMedium),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${animal?.breed ?? '-'} • ${animal?.weightDisplay ?? '-'}',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          
          Container(
            width: 1,
            height: 40,
            color: AppColors.border,
          ),
          
          // Collar info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bluetooth, color: AppColors.success, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        collar?.serialNumber ?? '-',
                        style: AppTypography.titleSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.battery_std,
                        color: AppColors.getBatteryColor(collar?.batteryPercent ?? 100),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${collar?.batteryPercent ?? 100}%',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCollarPhoto() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Collar Photo (optional)', style: AppTypography.labelMedium),
        const SizedBox(height: 4),
        Text(
          'Take a photo of the collar placement for reference',
          style: AppTypography.caption,
        ),
        const SizedBox(height: 12),
        
        Obx(() {
          if (collarPhoto.value != null) {
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    collarPhoto.value!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                    ),
                    onPressed: () => collarPhoto.value = null,
                  ),
                ),
              ],
            );
          }
          
          return OutlinedButton.icon(
            onPressed: _takeCollarPhoto,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take Photo'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 32),
            ),
          );
        }),
      ],
    );
  }
  
  Widget _buildPositionSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Initial Position', style: AppTypography.labelMedium),
        const SizedBox(height: 12),
        
        Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: PetPosition.values.map((pos) {
            final isSelected = position.value == pos;
            return ChoiceChip(
              label: Text(_getPositionLabel(pos)),
              selected: isSelected,
              onSelected: (_) => position.value = pos,
              avatar: Icon(
                _getPositionIcon(pos),
                size: 18,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            );
          }).toList(),
        )),
      ],
    );
  }
  
  Widget _buildAnxietySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Anxiety Level', style: AppTypography.labelMedium),
        const SizedBox(height: 12),
        
        Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AnxietyLevel.values.map((level) {
            final isSelected = anxiety.value == level;
            return ChoiceChip(
              label: Text(_getAnxietyLabel(level)),
              selected: isSelected,
              onSelected: (_) => anxiety.value = level,
              backgroundColor: _getAnxietyColor(level).withOpacity(0.1),
              selectedColor: _getAnxietyColor(level),
            );
          }).toList(),
        )),
      ],
    );
  }
  
  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Initial Notes (optional)', style: AppTypography.labelMedium),
        const SizedBox(height: 12),
        
        TextFormField(
          controller: notesController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Any observations before starting...',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
  
  String _getPositionLabel(PetPosition pos) {
    switch (pos) {
      case PetPosition.standing:
        return 'Standing';
      case PetPosition.sitting:
        return 'Sitting';
      case PetPosition.laying:
        return 'Laying';
      case PetPosition.verySick:
        return 'Very Sick';
    }
  }
  
  IconData _getPositionIcon(PetPosition pos) {
    switch (pos) {
      case PetPosition.standing:
        return Icons.pets;
      case PetPosition.sitting:
        return Icons.chair;
      case PetPosition.laying:
        return Icons.airline_seat_flat;
      case PetPosition.verySick:
        return Icons.healing;
    }
  }
  
  String _getAnxietyLabel(AnxietyLevel level) {
    switch (level) {
      case AnxietyLevel.calm:
        return 'Calm';
      case AnxietyLevel.mild:
        return 'Mild';
      case AnxietyLevel.moderate:
        return 'Moderate';
      case AnxietyLevel.severe:
        return 'Severe';
    }
  }
  
  Color _getAnxietyColor(AnxietyLevel level) {
    switch (level) {
      case AnxietyLevel.calm:
        return AppColors.success;
      case AnxietyLevel.mild:
        return AppColors.info;
      case AnxietyLevel.moderate:
        return AppColors.warning;
      case AnxietyLevel.severe:
        return AppColors.error;
    }
  }
}
