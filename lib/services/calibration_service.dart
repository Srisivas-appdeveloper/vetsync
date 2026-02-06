import 'package:get/get.dart';
import '../data/services/api_service.dart';
import '../data/services/storage_service.dart';

/// Calibration service for managing collar calibration data
/// Integrates with backend calibration system and local storage
class CalibrationService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  // Calibration state
  bool _hasCustomCalibration = false;
  double? _calibrationQuality;
  DateTime? _calibrationTimestamp;
  String? _calibrationId;
  String? _collarId;

  // Getters
  bool get hasCustomCalibration => _hasCustomCalibration;
  double? get calibrationQuality => _calibrationQuality;
  DateTime? get calibrationTimestamp => _calibrationTimestamp;
  String? get calibrationId => _calibrationId;

  /// Check if calibration is valid
  /// Valid if: exists, quality > 0.6, and age < 24 hours
  bool get isCalibrationValid {
    if (!_hasCustomCalibration) return false;
    if (_calibrationQuality == null || _calibrationQuality! < 0.6) return false;
    if (_calibrationTimestamp == null) return false;

    final age = DateTime.now().difference(_calibrationTimestamp!);
    return age < const Duration(hours: 24);
  }

  /// Get calibration age in hours
  double? get calibrationAgeHours {
    if (_calibrationTimestamp == null) return null;
    final age = DateTime.now().difference(_calibrationTimestamp!);
    return age.inMinutes / 60.0;
  }

  @override
  void onInit() {
    super.onInit();
    // Load saved calibration on service init
    loadSavedCalibration();
  }

  /// Load saved calibration from local storage
  Future<void> loadSavedCalibration() async {
    try {
      final calibrationData = await _storageService.readJson('calibration_data');
      if (calibrationData != null) {
        _hasCustomCalibration = calibrationData['hasCalibration'] as bool? ?? false;

        final quality = calibrationData['quality'];
        _calibrationQuality = quality is num ? quality.toDouble() : null;

        _calibrationId = calibrationData['id'] as String?;
        _collarId = calibrationData['collarId'] as String?;

        final timestampStr = calibrationData['timestamp'] as String?;
        if (timestampStr != null) {
          _calibrationTimestamp = DateTime.parse(timestampStr);
        }

        print('[Calibration] Loaded saved calibration: '
            'quality=${_calibrationQuality?.toStringAsFixed(2)}, '
            'age=${calibrationAgeHours?.toStringAsFixed(1)}h');
      }
    } catch (e) {
      print('[Calibration] Error loading saved calibration: $e');
    }
  }

  /// Download and apply calibration from backend
  Future<bool> downloadAndApplyCalibration({String? collarId}) async {
    try {
      final targetCollarId = collarId ?? _collarId;
      if (targetCollarId == null) {
        print('[Calibration] Error: No collar ID specified');
        return false;
      }

      print('[Calibration] Downloading calibration for collar: $targetCollarId');

      // TODO: Implement actual API call
      // final response = await _apiService.getCalibration(targetCollarId);

      // For now, simulate successful download
      // In real implementation, parse response and extract calibration data
      print('[Calibration] Error: Calibration download not implemented');
      return false;

      // When implemented:
      // _hasCustomCalibration = true;
      // _calibrationQuality = response['quality'];
      // _calibrationId = response['id'];
      // _calibrationTimestamp = DateTime.now();
      // _collarId = targetCollarId;
      // await _saveCalibrationLocally();
      // return true;
    } catch (e) {
      print('[Calibration] Error downloading calibration: $e');
      return false;
    }
  }

  /// Save calibration data locally
  Future<void> _saveCalibrationLocally() async {
    try {
      await _storageService.writeJson('calibration_data', {
        'hasCalibration': _hasCustomCalibration,
        'quality': _calibrationQuality,
        'id': _calibrationId,
        'collarId': _collarId,
        'timestamp': _calibrationTimestamp?.toIso8601String(),
      });
    } catch (e) {
      print('[Calibration] Error saving calibration: $e');
    }
  }

  /// Set calibration data manually (for testing or manual calibration)
  void setCalibration({
    required double quality,
    required String calibrationId,
    required String collarId,
  }) {
    _hasCustomCalibration = true;
    _calibrationQuality = quality;
    _calibrationId = calibrationId;
    _collarId = collarId;
    _calibrationTimestamp = DateTime.now();

    _saveCalibrationLocally();

    print('[Calibration] Calibration set: quality=${quality.toStringAsFixed(2)}');
  }

  /// Clear calibration data
  void clearCalibration() {
    _hasCustomCalibration = false;
    _calibrationQuality = null;
    _calibrationId = null;
    _calibrationTimestamp = null;
    _collarId = null;

    _storageService.delete('calibration_data');

    print('[Calibration] Calibration cleared');
  }

  /// Check if calibration is required for a given phase
  bool isCalibrationRequiredForPhase(String phase) {
    return phase == 'surgery' || phase == 'pre_surgery';
  }

  /// Validate calibration quality meets threshold
  bool validateCalibrationQuality(double threshold) {
    return (_calibrationQuality ?? 0.0) >= threshold;
  }

  /// Get calibration status summary
  Map<String, dynamic> getCalibrationStatus() {
    return {
      'has_calibration': _hasCustomCalibration,
      'quality': _calibrationQuality,
      'quality_percentage': _calibrationQuality != null
          ? '${(_calibrationQuality! * 100).toStringAsFixed(0)}%'
          : 'N/A',
      'calibration_id': _calibrationId,
      'collar_id': _collarId,
      'timestamp': _calibrationTimestamp?.toIso8601String(),
      'age_hours': calibrationAgeHours?.toStringAsFixed(1),
      'is_valid': isCalibrationValid,
      'is_expired': _calibrationTimestamp != null &&
          DateTime.now().difference(_calibrationTimestamp!) > const Duration(hours: 24),
    };
  }
}
