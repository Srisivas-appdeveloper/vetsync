/// Statistics for a single vital measurement
class VitalStats {
  final double mean;
  final double stdDev;
  final double min;
  final double max;
  
  VitalStats({
    required this.mean,
    required this.stdDev,
    required this.min,
    required this.max,
  });
  
  /// Get coefficient of variation (CV) as percentage
  double get coefficientOfVariation => (stdDev / mean) * 100;
  
  /// Check if statistics are stable (low CV)
  bool get isStable => coefficientOfVariation < 15;
  
  factory VitalStats.fromJson(Map<String, dynamic> json) {
    return VitalStats(
      mean: (json['mean'] as num).toDouble(),
      stdDev: (json['std_dev'] as num? ?? json['stdDev'] as num? ?? 0).toDouble(),
      min: (json['min'] as num).toDouble(),
      max: (json['max'] as num).toDouble(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'mean': mean,
      'std_dev': stdDev,
      'min': min,
      'max': max,
    };
  }
  
  @override
  String toString() => 'VitalStats(mean: ${mean.toStringAsFixed(1)}, stdDev: ${stdDev.toStringAsFixed(2)})';
}

/// Baseline data collected during the 5-minute baseline collection phase
class BaselineData {
  final VitalStats heartRate;
  final VitalStats respiratoryRate;
  final VitalStats temperature;
  final int qualityScore;
  final int durationSeconds;
  final DateTime collectedAt;
  
  BaselineData({
    required this.heartRate,
    required this.respiratoryRate,
    required this.temperature,
    required this.qualityScore,
    required this.durationSeconds,
    required this.collectedAt,
  });
  
  /// Check if baseline is acceptable (quality >= 60)
  bool get isAcceptable => qualityScore >= 60;
  
  /// Check if baseline is good (quality >= 75)
  bool get isGood => qualityScore >= 75;
  
  /// Check if baseline is excellent (quality >= 85)
  bool get isExcellent => qualityScore >= 85;
  
  /// Get quality label
  String get qualityLabel {
    if (qualityScore >= 85) return 'Excellent';
    if (qualityScore >= 75) return 'Good';
    if (qualityScore >= 60) return 'Acceptable';
    return 'Poor';
  }
  
  /// Get formatted duration
  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
  
  factory BaselineData.fromJson(Map<String, dynamic> json) {
    return BaselineData(
      heartRate: VitalStats.fromJson(json['heart_rate'] as Map<String, dynamic>),
      respiratoryRate: VitalStats.fromJson(json['respiratory_rate'] as Map<String, dynamic>),
      temperature: VitalStats.fromJson(json['temperature'] as Map<String, dynamic>),
      qualityScore: json['quality_score'] as int,
      durationSeconds: json['duration_seconds'] as int,
      collectedAt: DateTime.parse(json['collected_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'heart_rate': heartRate.toJson(),
      'respiratory_rate': respiratoryRate.toJson(),
      'temperature': temperature.toJson(),
      'quality_score': qualityScore,
      'duration_seconds': durationSeconds,
      'collected_at': collectedAt.toIso8601String(),
    };
  }
  
  @override
  String toString() => 'BaselineData(quality: $qualityScore%, HR: ${heartRate.mean.toInt()} BPM)';
}
