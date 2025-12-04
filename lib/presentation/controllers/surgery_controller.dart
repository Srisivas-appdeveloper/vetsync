import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../app/routes/app_pages.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_typography.dart';
import '../../data/models/models.dart';
import '../../data/services/ble_service.dart';
import '../../data/repositories/annotation_repository.dart';
import 'session_controller.dart';

/// Controller for surgery phase - handles annotations and voice notes
class SurgeryController extends GetxController {
  final SessionController _sessionController = Get.find<SessionController>();
  final BleService _bleService = Get.find<BleService>();
  final AnnotationRepository _annotationRepo = Get.find<AnnotationRepository>();
  
  // Recording state
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  final RxBool isRecording = false.obs;
  final RxBool isPlaying = false.obs;
  final RxInt recordingDuration = 0.obs;
  Timer? _recordingTimer;
  String? _currentRecordingPath;
  
  // Quick annotation categories
  final RxList<AnnotationCategory> recentCategories = <AnnotationCategory>[].obs;
  
  // Annotation dialog state
  final Rx<AnnotationCategory?> selectedCategory = Rx<AnnotationCategory?>(null);
  final RxString selectedType = ''.obs;
  final TextEditingController notesController = TextEditingController();
  
  // Physiological event tracking
  final RxList<PhysiologicalEventType> recentPhysioEvents = <PhysiologicalEventType>[].obs;
  
  // Session shortcuts
  Session? get currentSession => _sessionController.currentSession.value;
  String get sessionDuration => _sessionController.sessionDuration.value;
  String get phaseDuration => _sessionController.phaseDuration.value;
  Vitals? get latestVitals => _sessionController.latestVitals.value;
  int get signalQuality => _sessionController.signalQuality.value;
  int get batteryPercent => _sessionController.batteryPercent.value;
  List<Annotation> get annotations => _sessionController.sessionAnnotations;
  
  @override
  void onInit() {
    super.onInit();
    _loadRecentCategories();
  }
  
  @override
  void onClose() {
    _recorder.dispose();
    _player.dispose();
    notesController.dispose();
    _recordingTimer?.cancel();
    super.onClose();
  }
  
  void _loadRecentCategories() {
    // Default frequently used categories
    recentCategories.value = [
      AnnotationCategory.anesthesia,
      AnnotationCategory.medication,
      AnnotationCategory.surgical,
      AnnotationCategory.event,
    ];
  }
  
  // ============================================================
  // Quick Annotations
  // ============================================================
  
  /// Add quick annotation with predefined type
  Future<void> addQuickAnnotation(
    AnnotationCategory category,
    String type,
  ) async {
    await _sessionController.addAnnotation(
      category: category,
      type: type,
    );
    
    // Update recent categories
    recentCategories.remove(category);
    recentCategories.insert(0, category);
    if (recentCategories.length > 4) {
      recentCategories.removeLast();
    }
    
    Get.snackbar(
      'Annotation Added',
      '${category.emoji} $type',
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
    );
  }
  
  /// Add physiological event
  Future<void> addPhysiologicalEvent(PhysiologicalEventType eventType) async {
    await _sessionController.addPhysiologicalEvent(
      eventType: eventType,
    );
    
    // Track recent events
    recentPhysioEvents.remove(eventType);
    recentPhysioEvents.insert(0, eventType);
    if (recentPhysioEvents.length > 4) {
      recentPhysioEvents.removeLast();
    }
    
    if (eventType.isCritical) {
      Get.snackbar(
        '⚠️ Critical Event',
        eventType.displayName,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } else {
      Get.snackbar(
        'Event Recorded',
        eventType.displayName,
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.TOP,
      );
    }
  }
  
  // ============================================================
  // Custom Annotation Dialog
  // ============================================================
  
  /// Show annotation dialog
  void showAnnotationDialog() {
    selectedCategory.value = null;
    selectedType.value = '';
    notesController.clear();
    
    Get.bottomSheet(
      _AnnotationBottomSheet(controller: this),
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
  
  /// Get types for selected category
  List<String> getTypesForCategory(AnnotationCategory category) {
    switch (category) {
      case AnnotationCategory.anesthesia:
        return AnnotationTypes.anesthesia;
      case AnnotationCategory.medication:
        return AnnotationTypes.medication;
      case AnnotationCategory.preparation:
        return AnnotationTypes.preparation;
      case AnnotationCategory.surgical:
        return AnnotationTypes.surgical;
      case AnnotationCategory.event:
        return AnnotationTypes.event;
      case AnnotationCategory.recovery:
        return AnnotationTypes.recovery;
      case AnnotationCategory.behavior:
        return AnnotationTypes.behavior;
      case AnnotationCategory.emergency:
        return AnnotationTypes.emergency;
      default:
        return [];
    }
  }
  
  /// Submit custom annotation
  Future<void> submitAnnotation() async {
    if (selectedCategory.value == null || selectedType.isEmpty) {
      Get.snackbar('Error', 'Please select category and type');
      return;
    }
    
    await _sessionController.addAnnotation(
      category: selectedCategory.value!,
      type: selectedType.value,
      description: notesController.text.isEmpty ? null : notesController.text,
      voiceNotePath: _currentRecordingPath,
    );
    
    // Reset state
    _currentRecordingPath = null;
    Get.back();
    
    Get.snackbar(
      'Annotation Added',
      '${selectedCategory.value!.emoji} ${selectedType.value}',
      duration: const Duration(seconds: 2),
    );
  }
  
  // ============================================================
  // Voice Notes
  // ============================================================
  
  /// Start recording voice note
  Future<void> startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final path = '${dir.path}/voice_note_$timestamp.m4a';
        
        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: path,
        );
        
        _currentRecordingPath = path;
        isRecording.value = true;
        recordingDuration.value = 0;
        
        // Start duration timer
        _recordingTimer = Timer.periodic(
          const Duration(seconds: 1),
          (_) => recordingDuration.value++,
        );
      } else {
        Get.snackbar('Permission Required', 'Microphone permission is needed');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to start recording');
    }
  }
  
  /// Stop recording
  Future<void> stopRecording() async {
    try {
      _recordingTimer?.cancel();
      final path = await _recorder.stop();
      isRecording.value = false;
      
      if (path != null) {
        _currentRecordingPath = path;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to stop recording');
    }
  }
  
  /// Play recording
  Future<void> playRecording() async {
    if (_currentRecordingPath == null) return;
    
    try {
      isPlaying.value = true;
      await _player.play(DeviceFileSource(_currentRecordingPath!));
      _player.onPlayerComplete.listen((_) {
        isPlaying.value = false;
      });
    } catch (e) {
      isPlaying.value = false;
    }
  }
  
  /// Stop playback
  Future<void> stopPlayback() async {
    await _player.stop();
    isPlaying.value = false;
  }
  
  /// Delete recording
  void deleteRecording() {
    if (_currentRecordingPath != null) {
      try {
        File(_currentRecordingPath!).deleteSync();
      } catch (e) {
        // Ignore deletion errors
      }
      _currentRecordingPath = null;
    }
  }
  
  /// Get formatted recording duration
  String get recordingDurationFormatted {
    final mins = recordingDuration.value ~/ 60;
    final secs = recordingDuration.value % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
  
  bool get hasRecording => _currentRecordingPath != null;
  
  // ============================================================
  // Phase Transitions
  // ============================================================
  
  /// End surgery phase
  Future<void> endSurgery() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('End Surgery?'),
        content: const Text(
          'This will transition to the calibration phase. '
          'Make sure ECG equipment is ready for calibration.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('End Surgery'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final success = await _sessionController.endSurgery();
      if (success) {
        Get.offNamed(Routes.calibration);
      }
    }
  }
  
  /// Emergency stop
  Future<void> emergencyStop() async {
    await _sessionController.addAnnotation(
      category: AnnotationCategory.emergency,
      type: 'emergency_stop',
      description: 'Emergency stop triggered',
      severity: AnnotationSeverity.critical,
    );
    
    Get.snackbar(
      '⚠️ Emergency Stop',
      'Session paused. Contact supervisor.',
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      duration: const Duration(seconds: 10),
    );
  }
}

/// Annotation bottom sheet widget
class _AnnotationBottomSheet extends StatelessWidget {
  final SurgeryController controller;
  
  const _AnnotationBottomSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
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
              
              Text('Add Annotation', style: AppTypography.titleLarge),
              const SizedBox(height: 24),
              
              // Category selection
              Text('Category', style: AppTypography.labelMedium),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AnnotationCategory.values
                    .where((c) => c != AnnotationCategory.system && 
                                  c != AnnotationCategory.physiological)
                    .map((category) => _CategoryChip(
                          category: category,
                          isSelected: controller.selectedCategory.value == category,
                          onTap: () {
                            controller.selectedCategory.value = category;
                            controller.selectedType.value = '';
                          },
                        ))
                    .toList(),
              )),
              const SizedBox(height: 20),
              
              // Type selection
              Obx(() {
                if (controller.selectedCategory.value == null) {
                  return const SizedBox.shrink();
                }
                
                final types = controller.getTypesForCategory(
                  controller.selectedCategory.value!,
                );
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Type', style: AppTypography.labelMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: types.map((type) => ChoiceChip(
                        label: Text(type),
                        selected: controller.selectedType.value == type,
                        onSelected: (_) => controller.selectedType.value = type,
                      )).toList(),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 20),
              
              // Notes
              Text('Notes (optional)', style: AppTypography.labelMedium),
              const SizedBox(height: 8),
              TextField(
                controller: controller.notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Additional details...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              
              // Voice note
              Text('Voice Note (optional)', style: AppTypography.labelMedium),
              const SizedBox(height: 8),
              _VoiceNoteWidget(controller: controller),
              const SizedBox(height: 24),
              
              // Submit
              ElevatedButton(
                onPressed: controller.submitAnnotation,
                child: const Text('Add Annotation'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final AnnotationCategory category;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.getAnnotationColor(category.name)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? AppColors.getAnnotationColor(category.name)
                : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(category.emoji),
            const SizedBox(width: 6),
            Text(
              category.displayName,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoiceNoteWidget extends StatelessWidget {
  final SurgeryController controller;
  
  const _VoiceNoteWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isRecording.value) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.errorSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.mic, color: AppColors.error),
              const SizedBox(width: 12),
              Text(
                'Recording: ${controller.recordingDurationFormatted}',
                style: AppTypography.titleSmall.copyWith(color: AppColors.error),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.stop, color: AppColors.error),
                onPressed: controller.stopRecording,
              ),
            ],
          ),
        );
      }
      
      if (controller.hasRecording) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.successSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  controller.isPlaying.value ? Icons.stop : Icons.play_arrow,
                  color: AppColors.success,
                ),
                onPressed: controller.isPlaying.value
                    ? controller.stopPlayback
                    : controller.playRecording,
              ),
              const SizedBox(width: 8),
              Text(
                'Voice note recorded',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.successDark),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete, color: AppColors.error),
                onPressed: controller.deleteRecording,
              ),
            ],
          ),
        );
      }
      
      return OutlinedButton.icon(
        onPressed: controller.startRecording,
        icon: const Icon(Icons.mic),
        label: const Text('Record Voice Note'),
      );
    });
  }
}
