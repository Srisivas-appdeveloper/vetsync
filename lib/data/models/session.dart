import 'enums.dart';
import 'baseline_data.dart';

/// Session model representing a complete clinical session
class Session {
  final String id;
  final String sessionCode;
  final String animalId;
  final String collarId;
  final String observerId;
  final String clinicId;
  final SessionPhase currentPhase;
  
  // Surgery Details
  final String? surgeryType;
  final String? surgeryReason;
  final ASAStatus? asaStatus;
  
  // Baseline
  final BaselineData? baselineData;
  final int? baselineQuality;
  
  // Calibration
  final bool isCalibrated;
  final CalibrationStatus? calibrationStatus;
  final double? calibrationErrorBpm;
  final double? calibrationCorrelation;
  
  // Data Quality Flags
  final bool partialCollarData;
  final bool useForTraining;
  final int? overallQualityScore;
  
  // Timing
  final DateTime startedAt;
  final DateTime? surgeryStartedAt;
  final DateTime? surgeryEndedAt;
  final DateTime? endedAt;
  
  // Media
  final String? collarPhotoKey;
  
  // Initial conditions
  final PetPosition? initialPosition;
  final AnxietyLevel? initialAnxiety;
  final String? initialNotes;
  
  // Annotations count (for display)
  final int annotationCount;
  
  Session({
    required this.id,
    required this.sessionCode,
    required this.animalId,
    required this.collarId,
    required this.observerId,
    required this.clinicId,
    required this.currentPhase,
    this.surgeryType,
    this.surgeryReason,
    this.asaStatus,
    this.baselineData,
    this.baselineQuality,
    this.isCalibrated = false,
    this.calibrationStatus,
    this.calibrationErrorBpm,
    this.calibrationCorrelation,
    this.partialCollarData = false,
    this.useForTraining = true,
    this.overallQualityScore,
    required this.startedAt,
    this.surgeryStartedAt,
    this.surgeryEndedAt,
    this.endedAt,
    this.collarPhotoKey,
    this.initialPosition,
    this.initialAnxiety,
    this.initialNotes,
    this.annotationCount = 0,
  });
  
  /// Check if session is active (not completed)
  bool get isActive => endedAt == null;
  
  /// Get total session duration
  Duration get duration {
    final end = endedAt ?? DateTime.now();
    return end.difference(startedAt);
  }
  
  /// Get surgery duration
  Duration? get surgeryDuration {
    if (surgeryStartedAt == null) return null;
    final end = surgeryEndedAt ?? DateTime.now();
    return end.difference(surgeryStartedAt!);
  }
  
  /// Get formatted duration string
  String get formattedDuration {
    final d = duration;
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:'
           '${minutes.toString().padLeft(2, '0')}:'
           '${seconds.toString().padLeft(2, '0')}';
  }
  
  /// Get phase display color
  String get phaseDisplayColor {
    switch (currentPhase) {
      case SessionPhase.preSurgery:
        return 'blue';
      case SessionPhase.surgery:
        return 'red';
      case SessionPhase.calibration:
        return 'orange';
      case SessionPhase.recovery:
        return 'green';
      case SessionPhase.completed:
        return 'gray';
    }
  }
  
  /// Check if baseline is complete
  bool get hasBaseline => baselineData != null && (baselineQuality ?? 0) >= 60;
  
  /// Get baseline heart rate mean
  double? get baselineHeartRate => baselineData?.heartRate.mean;
  
  /// Get baseline respiratory rate mean
  double? get baselineRespRate => baselineData?.respiratoryRate.mean;
  
  /// Get baseline temperature mean
  double? get baselineTemp => baselineData?.temperature.mean;
  
  /// Check if surgery details are filled
  bool get hasSurgeryDetails =>
      surgeryType != null &&
      surgeryType!.isNotEmpty &&
      surgeryReason != null &&
      surgeryReason!.isNotEmpty &&
      asaStatus != null;
  
  /// Get calibration quality label
  String? get calibrationQualityLabel {
    if (calibrationCorrelation == null) return null;
    if (calibrationCorrelation! > 0.95) return 'Excellent';
    if (calibrationCorrelation! > 0.90) return 'Good';
    if (calibrationCorrelation! > 0.85) return 'Acceptable';
    return 'Failed';
  }
  
  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['session_id'] as String? ?? json['id'] as String,
      sessionCode: json['session_code'] as String,
      animalId: json['animal_id'] as String,
      collarId: json['collar_id'] as String,
      observerId: json['observer_id'] as String,
      clinicId: json['clinic_id'] as String,
      currentPhase: SessionPhase.fromString(json['current_phase'] as String),
      surgeryType: json['surgery_type'] as String?,
      surgeryReason: json['surgery_reason'] as String?,
      asaStatus: json['asa_status'] != null
          ? ASAStatus.fromString(json['asa_status'] as String)
          : null,
      baselineData: json['baseline_data'] != null
          ? BaselineData.fromJson(json['baseline_data'] as Map<String, dynamic>)
          : null,
      baselineQuality: json['baseline_quality'] as int?,
      isCalibrated: json['is_calibrated'] as bool? ?? false,
      calibrationStatus: json['calibration_status'] != null
          ? CalibrationStatus.fromString(json['calibration_status'] as String)
          : null,
      calibrationErrorBpm: (json['calibration_error_bpm'] as num?)?.toDouble(),
      calibrationCorrelation: (json['calibration_correlation'] as num?)?.toDouble(),
      partialCollarData: json['partial_collar_data'] as bool? ?? false,
      useForTraining: json['use_for_training'] as bool? ?? true,
      overallQualityScore: json['overall_quality_score'] as int?,
      startedAt: DateTime.parse(json['started_at'] as String),
      surgeryStartedAt: json['surgery_started_at'] != null
          ? DateTime.parse(json['surgery_started_at'] as String)
          : null,
      surgeryEndedAt: json['surgery_ended_at'] != null
          ? DateTime.parse(json['surgery_ended_at'] as String)
          : null,
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'] as String)
          : null,
      collarPhotoKey: json['collar_photo_key'] as String?,
      initialPosition: json['initial_position'] != null
          ? PetPosition.fromString(json['initial_position'] as String)
          : null,
      initialAnxiety: json['initial_anxiety'] != null
          ? AnxietyLevel.fromString(json['initial_anxiety'] as String)
          : null,
      initialNotes: json['initial_notes'] as String?,
      annotationCount: json['annotation_count'] as int? ?? 0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'session_id': id,
      'session_code': sessionCode,
      'animal_id': animalId,
      'collar_id': collarId,
      'observer_id': observerId,
      'clinic_id': clinicId,
      'current_phase': currentPhase.value,
      'surgery_type': surgeryType,
      'surgery_reason': surgeryReason,
      'asa_status': asaStatus?.value,
      'baseline_data': baselineData?.toJson(),
      'baseline_quality': baselineQuality,
      'is_calibrated': isCalibrated,
      'calibration_status': calibrationStatus?.value,
      'calibration_error_bpm': calibrationErrorBpm,
      'calibration_correlation': calibrationCorrelation,
      'partial_collar_data': partialCollarData,
      'use_for_training': useForTraining,
      'overall_quality_score': overallQualityScore,
      'started_at': startedAt.toIso8601String(),
      'surgery_started_at': surgeryStartedAt?.toIso8601String(),
      'surgery_ended_at': surgeryEndedAt?.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'collar_photo_key': collarPhotoKey,
      'initial_position': initialPosition?.value,
      'initial_anxiety': initialAnxiety?.value,
      'initial_notes': initialNotes,
      'annotation_count': annotationCount,
    };
  }
  
  Session copyWith({
    String? id,
    String? sessionCode,
    String? animalId,
    String? collarId,
    String? observerId,
    String? clinicId,
    SessionPhase? currentPhase,
    String? surgeryType,
    String? surgeryReason,
    ASAStatus? asaStatus,
    BaselineData? baselineData,
    int? baselineQuality,
    bool? isCalibrated,
    CalibrationStatus? calibrationStatus,
    double? calibrationErrorBpm,
    double? calibrationCorrelation,
    bool? partialCollarData,
    bool? useForTraining,
    int? overallQualityScore,
    DateTime? startedAt,
    DateTime? surgeryStartedAt,
    DateTime? surgeryEndedAt,
    DateTime? endedAt,
    String? collarPhotoKey,
    PetPosition? initialPosition,
    AnxietyLevel? initialAnxiety,
    String? initialNotes,
    int? annotationCount,
  }) {
    return Session(
      id: id ?? this.id,
      sessionCode: sessionCode ?? this.sessionCode,
      animalId: animalId ?? this.animalId,
      collarId: collarId ?? this.collarId,
      observerId: observerId ?? this.observerId,
      clinicId: clinicId ?? this.clinicId,
      currentPhase: currentPhase ?? this.currentPhase,
      surgeryType: surgeryType ?? this.surgeryType,
      surgeryReason: surgeryReason ?? this.surgeryReason,
      asaStatus: asaStatus ?? this.asaStatus,
      baselineData: baselineData ?? this.baselineData,
      baselineQuality: baselineQuality ?? this.baselineQuality,
      isCalibrated: isCalibrated ?? this.isCalibrated,
      calibrationStatus: calibrationStatus ?? this.calibrationStatus,
      calibrationErrorBpm: calibrationErrorBpm ?? this.calibrationErrorBpm,
      calibrationCorrelation: calibrationCorrelation ?? this.calibrationCorrelation,
      partialCollarData: partialCollarData ?? this.partialCollarData,
      useForTraining: useForTraining ?? this.useForTraining,
      overallQualityScore: overallQualityScore ?? this.overallQualityScore,
      startedAt: startedAt ?? this.startedAt,
      surgeryStartedAt: surgeryStartedAt ?? this.surgeryStartedAt,
      surgeryEndedAt: surgeryEndedAt ?? this.surgeryEndedAt,
      endedAt: endedAt ?? this.endedAt,
      collarPhotoKey: collarPhotoKey ?? this.collarPhotoKey,
      initialPosition: initialPosition ?? this.initialPosition,
      initialAnxiety: initialAnxiety ?? this.initialAnxiety,
      initialNotes: initialNotes ?? this.initialNotes,
      annotationCount: annotationCount ?? this.annotationCount,
    );
  }
  
  @override
  String toString() => 'Session(id: $id, code: $sessionCode, phase: ${currentPhase.value})';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Session && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
