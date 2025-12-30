import 'algorithm_package.dart';

class Calibration {
  final String calibrationId;
  final String sessionId;
  final String animalId;
  final String collarId;
  final AlgorithmPackage algorithmPackage;
  final Map<String, dynamic> qualityMetrics;
  final DateTime createdAt;
  final DateTime? validUntil;
  final String? reportUrl;

  Calibration({
    required this.calibrationId,
    required this.sessionId,
    required this.animalId,
    required this.collarId,
    required this.algorithmPackage,
    required this.qualityMetrics,
    required this.createdAt,
    this.validUntil,
    this.reportUrl,
  });
}
