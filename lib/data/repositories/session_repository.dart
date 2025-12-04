import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:get/get.dart' hide Value;
import 'package:uuid/uuid.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../services/connectivity_service.dart';
import '../services/storage_service.dart';
import '../services/sync_service.dart';
import '../../core/constants/app_config.dart';

/// Session repository
class SessionRepository {
  final ApiService _api = Get.find<ApiService>();
  final DatabaseService _database = Get.find<DatabaseService>();
  final ConnectivityService _connectivity = Get.find<ConnectivityService>();
  final StorageService _storage = Get.find<StorageService>();
  final SyncService _sync = Get.find<SyncService>();
  final Uuid _uuid = const Uuid();

  /// Create new session
  Future<Session> createSession({
    required String animalId,
    required String collarId,
    required String observerId,
    required String clinicId,
    PetPosition? initialPosition,
    AnxietyLevel? initialAnxiety,
    String? initialNotes,
    String? collarPhotoPath,
  }) async {
    final sessionId = _uuid.v4();
    final sessionCode = _generateSessionCode();
    final now = DateTime.now();

    final session = Session(
      id: sessionId,
      sessionCode: sessionCode,
      animalId: animalId,
      collarId: collarId,
      observerId: observerId,
      clinicId: clinicId,
      currentPhase: SessionPhase.preSurgery,
      startedAt: now,
      initialPosition: initialPosition,
      initialAnxiety: initialAnxiety,
      initialNotes: initialNotes,
      collarPhotoKey: collarPhotoPath,
    );

    // Save to local database
    await _database.db.insertSession(
      LocalSessionsCompanion(
        id: Value(sessionId),
        sessionCode: Value(sessionCode),
        animalId: Value(animalId),
        collarId: Value(collarId),
        observerId: Value(observerId),
        clinicId: Value(clinicId),
        currentPhase: Value(SessionPhase.preSurgery.value),
        startedAt: Value(now),
        initialPosition: Value(initialPosition?.value),
        initialAnxiety: Value(initialAnxiety?.value),
        initialNotes: Value(initialNotes),
        collarPhotoPath: Value(collarPhotoPath),
        syncStatus: const Value('pending'),
      ),
    );

    // Store active session
    await _storage.setActiveSessionId(sessionId);

    // Try to sync to server
    if (_connectivity.isOnline.value) {
      try {
        final response = await _api.post(
          ApiEndpoints.sessions,
          data: session.toJson(),
        );
        await _database.db.updateSessionSyncStatus(sessionId, 'synced');
        return Session.fromJson(response.data as Map<String, dynamic>);
      } catch (e) {
        // Will sync later
        print('Session sync failed, will retry: $e');
      }
    }

    return session;
  }

  /// Get session by ID
  Future<Session?> getSession(String id) async {
    if (_connectivity.isOnline.value) {
      try {
        final response = await _api.get(ApiEndpoints.session(id));
        return Session.fromJson(response.data as Map<String, dynamic>);
      } catch (e) {
        return _getLocalSession(id);
      }
    }
    return _getLocalSession(id);
  }

  Future<Session?> _getLocalSession(String id) async {
    final local = await _database.db.getSession(id);
    if (local == null) return null;
    return _localToSession(local);
  }

  /// Get active session
  Future<Session?> getActiveSession() async {
    final activeId = await _storage.getActiveSessionId();
    if (activeId == null) return null;
    return getSession(activeId);
  }

  /// Update session phase
  Future<void> updatePhase(String sessionId, SessionPhase phase) async {
    // Update local
    await _database.db.updateSessionPhase(sessionId, phase.value);

    // Update server
    if (_connectivity.isOnline.value) {
      try {
        await _api.patch(
          ApiEndpoints.sessionPhase(sessionId),
          data: {
            'phase': phase.value,
            if (phase == SessionPhase.surgery)
              'surgery_started_at': DateTime.now().toIso8601String(),
            if (phase == SessionPhase.recovery)
              'surgery_ended_at': DateTime.now().toIso8601String(),
            if (phase == SessionPhase.completed)
              'ended_at': DateTime.now().toIso8601String(),
          },
        );
      } catch (e) {
        await _sync.queueForSync(
          entityType: 'session',
          entityId: sessionId,
          action: 'update',
          data: {'phase': phase.value},
          priority: 1,
        );
      }
    }
  }

  /// Update surgery details
  Future<void> updateSurgeryDetails({
    required String sessionId,
    required String surgeryType,
    required String surgeryReason,
    required ASAStatus asaStatus,
  }) async {
    final data = {
      'surgery_type': surgeryType,
      'surgery_reason': surgeryReason,
      'asa_status': asaStatus.value,
    };

    // Update local using AppDatabase method
    await _database.db.updateSurgeryDetails(
      sessionId: sessionId,
      surgeryType: surgeryType,
      surgeryReason: surgeryReason,
      asaStatus: asaStatus.value,
    );

    // Sync to server
    if (_connectivity.isOnline.value) {
      try {
        await _api.patch(ApiEndpoints.session(sessionId), data: data);
      } catch (e) {
        await _sync.queueForSync(
          entityType: 'session',
          entityId: sessionId,
          action: 'update',
          data: data,
          priority: 2,
        );
      }
    }
  }

  /// Save baseline data
  Future<void> saveBaseline({
    required String sessionId,
    required BaselineData baseline,
  }) async {
    final baselineJson = jsonEncode(baseline.toJson());

    // Update local using AppDatabase method
    await _database.db.updateSessionBaseline(
      sessionId: sessionId,
      baselineJson: baselineJson,
      qualityScore: baseline.qualityScore,
    );

    // Sync to server
    if (_connectivity.isOnline.value) {
      try {
        await _api.patch(
          ApiEndpoints.sessionBaseline(sessionId),
          data: baseline.toJson(),
        );
      } catch (e) {
        await _sync.queueForSync(
          entityType: 'session',
          entityId: sessionId,
          action: 'update',
          data: {'baseline_data': baseline.toJson()},
          priority: 2,
        );
      }
    }
  }

  /// Update calibration results
  Future<void> updateCalibration({
    required String sessionId,
    required CalibrationStatus status,
    double? errorBpm,
    double? correlation,
  }) async {
    final data = {
      'calibration_status': status.value,
      'is_calibrated': status.isSuccess,
      if (errorBpm != null) 'calibration_error_bpm': errorBpm,
      if (correlation != null) 'calibration_correlation': correlation,
    };

    // Update local using AppDatabase method
    await _database.db.updateSessionCalibration(
      sessionId: sessionId,
      isCalibrated: status.isSuccess,
      calibrationStatus: status.value,
      errorBpm: errorBpm,
      correlation: correlation,
    );

    // Sync to server
    if (_connectivity.isOnline.value) {
      try {
        await _api.patch(ApiEndpoints.session(sessionId), data: data);
      } catch (e) {
        await _sync.queueForSync(
          entityType: 'session',
          entityId: sessionId,
          action: 'update',
          data: data,
          priority: 2,
        );
      }
    }
  }

  /// End session
  Future<void> endSession(String sessionId) async {
    await updatePhase(sessionId, SessionPhase.completed);
    await _storage.setActiveSessionId(null);
  }

  /// Change collar mid-session
  Future<void> changeCollar({
    required String sessionId,
    required String newCollarId,
    required String reason,
  }) async {
    if (_connectivity.isOnline.value) {
      await _api.patch(
        ApiEndpoints.sessionCollar(sessionId),
        data: {
          'collar_id': newCollarId,
          'change_reason': reason,
          'changed_at': DateTime.now().toIso8601String(),
        },
      );
    }

    // Update local using AppDatabase method
    await _database.db.updateSessionCollar(sessionId, newCollarId);
  }

  /// Generate join code for multi-observer
  Future<JoinCode> generateJoinCode(String sessionId) async {
    final response = await _api.get(ApiEndpoints.sessionJoinCode(sessionId));
    return JoinCode.fromJson(response.data as Map<String, dynamic>);
  }

  /// Join session with code
  Future<Session> joinSession(String code) async {
    final response = await _api.post(
      ApiEndpoints.joinSession,
      data: {'code': code},
    );
    return Session.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get today's sessions
  Future<List<Session>> getTodaySessions() async {
    final response = await _api.get(ApiEndpoints.dashboardToday);
    return (response.data['sessions'] as List)
        .map((json) => Session.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get dashboard stats
  Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await _api.get(ApiEndpoints.dashboardStats);
    return response.data as Map<String, dynamic>;
  }

  String _generateSessionCode() {
    final now = DateTime.now();
    final random = DateTime.now().microsecond % 1000;
    return 'VS${now.year % 100}${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}-$random';
  }

  Session _localToSession(LocalSession local) {
    return Session(
      id: local.id,
      sessionCode: local.sessionCode,
      animalId: local.animalId,
      collarId: local.collarId,
      observerId: local.observerId,
      clinicId: local.clinicId,
      currentPhase: SessionPhase.fromString(local.currentPhase),
      surgeryType: local.surgeryType,
      surgeryReason: local.surgeryReason,
      asaStatus: local.asaStatus != null
          ? ASAStatus.fromString(local.asaStatus!)
          : null,
      baselineData: local.baselineDataJson != null
          ? BaselineData.fromJson(
              jsonDecode(local.baselineDataJson!) as Map<String, dynamic>,
            )
          : null,
      baselineQuality: local.baselineQuality,
      isCalibrated: local.isCalibrated,
      calibrationStatus: local.calibrationStatus != null
          ? CalibrationStatus.fromString(local.calibrationStatus!)
          : null,
      calibrationErrorBpm: local.calibrationErrorBpm,
      calibrationCorrelation: local.calibrationCorrelation,
      startedAt: local.startedAt,
      surgeryStartedAt: local.surgeryStartedAt,
      surgeryEndedAt: local.surgeryEndedAt,
      endedAt: local.endedAt,
      collarPhotoKey: local.collarPhotoPath,
      initialPosition: local.initialPosition != null
          ? PetPosition.fromString(local.initialPosition!)
          : null,
      initialAnxiety: local.initialAnxiety != null
          ? AnxietyLevel.fromString(local.initialAnxiety!)
          : null,
      initialNotes: local.initialNotes,
    );
  }
}
