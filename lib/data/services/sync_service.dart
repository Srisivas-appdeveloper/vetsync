import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:get/get.dart' hide Value;

import '../../core/constants/app_config.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'connectivity_service.dart';
import 'database_service.dart';

/// Sync service for offline data synchronization
class SyncService extends GetxService {
  final ApiService _api = Get.find<ApiService>();
  final ConnectivityService _connectivity = Get.find<ConnectivityService>();
  final DatabaseService _database = Get.find<DatabaseService>();

  /// Whether sync is in progress
  final RxBool isSyncing = false.obs;

  /// Number of items pending sync
  final RxInt pendingCount = 0.obs;

  /// Last sync time
  final Rxn<DateTime> lastSyncTime = Rxn<DateTime>();

  /// Sync errors
  final RxList<String> syncErrors = <String>[].obs;

  Timer? _autoSyncTimer;
  bool _isInitialized = false;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    // Wait for database to be ready
    await Future.delayed(const Duration(milliseconds: 500));
    _isInitialized = true;

    // Update pending count
    await _updatePendingCount();

    // Listen for connectivity changes
    ever(_connectivity.isOnline, (bool online) {
      if (online) {
        // Auto-sync when coming online
        syncAll();
      }
    });

    // Start auto-sync timer
    _startAutoSyncTimer();
  }

  void _startAutoSyncTimer() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = Timer.periodic(AppConfig.autoSyncInterval, (_) {
      if (_connectivity.isOnline.value && !isSyncing.value) {
        syncAll();
      }
    });
  }

  /// Update pending count
  Future<void> _updatePendingCount() async {
    if (!_isInitialized) return;

    try {
      final count = await _database.db.getSyncQueueCount();
      pendingCount.value = count;
    } catch (e) {
      print('Error getting sync count: $e');
    }
  }

  /// Sync all pending data
  Future<SyncResult> syncAll() async {
    if (!_connectivity.isOnline.value) {
      return SyncResult(success: false, message: 'No internet connection');
    }

    if (isSyncing.value) {
      return SyncResult(success: false, message: 'Sync already in progress');
    }

    isSyncing.value = true;
    syncErrors.clear();

    int syncedCount = 0;
    int failedCount = 0;

    try {
      // Sync sessions first (highest priority)
      final sessionsResult = await _syncSessions();
      syncedCount += sessionsResult.synced;
      failedCount += sessionsResult.failed;

      // Sync annotations
      final annotationsResult = await _syncAnnotations();
      syncedCount += annotationsResult.synced;
      failedCount += annotationsResult.failed;

      // Sync vitals in batches
      final vitalsResult = await _syncVitals();
      syncedCount += vitalsResult.synced;
      failedCount += vitalsResult.failed;

      // Process sync queue
      final queueResult = await _processSyncQueue();
      syncedCount += queueResult.synced;
      failedCount += queueResult.failed;

      lastSyncTime.value = DateTime.now();
      await _updatePendingCount();

      return SyncResult(
        success: failedCount == 0,
        message: failedCount == 0
            ? 'Synced $syncedCount items'
            : 'Synced $syncedCount items, $failedCount failed',
        syncedCount: syncedCount,
        failedCount: failedCount,
      );
    } catch (e) {
      syncErrors.add(e.toString());
      return SyncResult(success: false, message: 'Sync error: ${e.toString()}');
    } finally {
      isSyncing.value = false;
    }
  }

  /// Sync pending data (alias for syncAll)
  Future<SyncResult> syncPending() => syncAll();

  /// Sync pending sessions
  Future<_SyncBatchResult> _syncSessions() async {
    int synced = 0;
    int failed = 0;

    try {
      final sessions = await _database.db.getPendingSessions();

      for (final session in sessions) {
        try {
          // Convert to API format
          final sessionData = _sessionToJson(session);

          // Send to API
          await _api.post(ApiEndpoints.sessions, data: sessionData);

          // Mark as synced
          await _database.db.updateSessionSyncStatus(session.id, 'synced');
          synced++;
        } catch (e) {
          failed++;
          syncErrors.add('Session ${session.sessionCode}: ${e.toString()}');
          await _database.db.updateSessionSyncStatus(session.id, 'failed');
        }
      }
    } catch (e) {
      syncErrors.add('Session sync error: ${e.toString()}');
    }

    return _SyncBatchResult(synced: synced, failed: failed);
  }

  /// Sync pending annotations
  Future<_SyncBatchResult> _syncAnnotations() async {
    int synced = 0;
    int failed = 0;

    try {
      final annotations = await _database.db.getPendingAnnotations();

      for (final annotation in annotations) {
        try {
          // Convert to API format
          final annotationData = _annotationToJson(annotation);

          // Send to API
          await _api.post(
            ApiEndpoints.sessionAnnotations(annotation.sessionId),
            data: annotationData,
          );

          // Mark as synced
          await _database.db.updateAnnotationSyncStatus(
            annotation.id,
            'synced',
          );
          synced++;
        } catch (e) {
          failed++;
          syncErrors.add('Annotation ${annotation.type}: ${e.toString()}');
        }
      }
    } catch (e) {
      syncErrors.add('Annotation sync error: ${e.toString()}');
    }

    return _SyncBatchResult(synced: synced, failed: failed);
  }

  /// Sync pending vitals in batches
  Future<_SyncBatchResult> _syncVitals() async {
    int synced = 0;
    int failed = 0;

    try {
      while (true) {
        final vitals = await _database.db.getPendingVitals(
          limit: AppConfig.syncBatchSize,
        );
        if (vitals.isEmpty) break;

        // Group by session
        final bySession = <String, List<LocalVital>>{};
        for (final v in vitals) {
          bySession.putIfAbsent(v.sessionId, () => []).add(v);
        }

        for (final entry in bySession.entries) {
          try {
            // Convert to API format
            final vitalsData = entry.value
                .map(
                  (v) => {
                    'timestamp_utc': v.timestampUtc.toIso8601String(),
                    'heart_rate_bpm': v.heartRateBpm,
                    'respiratory_rate_bpm': v.respiratoryRateBpm,
                    'temperature_c': v.temperatureC,
                    'signal_quality': v.signalQuality,
                  },
                )
                .toList();

            // Send batch to API
            await _api.post(
              ApiEndpoints.sessionVitalsBatch(entry.key),
              data: {'vitals': vitalsData},
            );

            // Mark as synced
            await _database.db.markVitalsSynced(
              entry.value.map((v) => v.id).toList(),
            );
            synced += entry.value.length;
          } catch (e) {
            failed += entry.value.length;
            syncErrors.add('Vitals batch: ${e.toString()}');
          }
        }
      }
    } catch (e) {
      syncErrors.add('Vitals sync error: ${e.toString()}');
    }

    return _SyncBatchResult(synced: synced, failed: failed);
  }

  /// Process sync queue
  Future<_SyncBatchResult> _processSyncQueue() async {
    int synced = 0;
    int failed = 0;

    try {
      while (true) {
        final items = await _database.db.getNextSyncItems(limit: 10);
        if (items.isEmpty) break;

        for (final item in items) {
          try {
            final data = jsonDecode(item.dataJson) as Map<String, dynamic>;

            switch (item.action) {
              case 'create':
                await _api.post(_getEndpoint(item.entityType), data: data);
                break;
              case 'update':
                await _api.put(
                  _getEndpoint(item.entityType, item.entityId),
                  data: data,
                );
                break;
              case 'delete':
                await _api.delete(_getEndpoint(item.entityType, item.entityId));
                break;
            }

            await _database.db.removeSyncItem(item.id);
            synced++;
          } catch (e) {
            failed++;

            if (item.retryCount >= AppConfig.maxSyncRetries) {
              await _database.db.removeSyncItem(item.id);
              syncErrors.add(
                'Max retries: ${item.entityType} ${item.entityId}',
              );
            } else {
              await _database.db.updateSyncItemRetry(item.id, e.toString());
            }
          }
        }
      }
    } catch (e) {
      syncErrors.add('Queue sync error: ${e.toString()}');
    }

    return _SyncBatchResult(synced: synced, failed: failed);
  }

  String _getEndpoint(String entityType, [String? id]) {
    switch (entityType) {
      case 'session':
        return id != null ? ApiEndpoints.session(id) : ApiEndpoints.sessions;
      case 'annotation':
        return id != null
            ? ApiEndpoints.annotation(id)
            : ApiEndpoints.annotations;
      default:
        throw Exception('Unknown entity type: $entityType');
    }
  }

  Map<String, dynamic> _sessionToJson(LocalSession session) {
    return {
      'session_id': session.id,
      'session_code': session.sessionCode,
      'animal_id': session.animalId,
      'collar_id': session.collarId,
      'observer_id': session.observerId,
      'clinic_id': session.clinicId,
      'current_phase': session.currentPhase,
      'surgery_type': session.surgeryType,
      'surgery_reason': session.surgeryReason,
      'asa_status': session.asaStatus,
      'baseline_data': session.baselineDataJson != null
          ? jsonDecode(session.baselineDataJson!)
          : null,
      'baseline_quality': session.baselineQuality,
      'is_calibrated': session.isCalibrated,
      'calibration_status': session.calibrationStatus,
      'calibration_error_bpm': session.calibrationErrorBpm,
      'calibration_correlation': session.calibrationCorrelation,
      'started_at': session.startedAt.toIso8601String(),
      'surgery_started_at': session.surgeryStartedAt?.toIso8601String(),
      'surgery_ended_at': session.surgeryEndedAt?.toIso8601String(),
      'ended_at': session.endedAt?.toIso8601String(),
      'initial_position': session.initialPosition,
      'initial_anxiety': session.initialAnxiety,
      'initial_notes': session.initialNotes,
    };
  }

  Map<String, dynamic> _annotationToJson(LocalAnnotation annotation) {
    return {
      'annotation_id': annotation.id,
      'session_id': annotation.sessionId,
      'timestamp_utc': annotation.timestampUtc.toIso8601String(),
      'elapsed_ms': annotation.elapsedMs,
      'phase': annotation.phase,
      'category': annotation.category,
      'type': annotation.type,
      'description': annotation.description,
      'severity': annotation.severity,
      'structured_data': annotation.structuredDataJson != null
          ? jsonDecode(annotation.structuredDataJson!)
          : null,
      'voice_note_path': annotation.voiceNotePath,
      'voice_transcription': annotation.voiceTranscription,
      'annotator_user_id': annotation.annotatorUserId,
      'is_auto_generated': annotation.isAutoGenerated,
    };
  }

  /// Add item to sync queue
  Future<void> queueForSync({
    required String entityType,
    required String entityId,
    required String action,
    required Map<String, dynamic> data,
    int priority = 5,
  }) async {
    await _database.db.addToSyncQueue(
      SyncQueueCompanion(
        entityType: Value(entityType),
        entityId: Value(entityId),
        action: Value(action),
        dataJson: Value(jsonEncode(data)),
        priority: Value(priority),
      ),
    );
    await _updatePendingCount();
  }

  /// Clean up old synced data
  Future<void> cleanupOldData() async {
    await _database.db.deleteOldSyncedVitals();
    await _database.db.clearOldCache();
  }

  @override
  void onClose() {
    _autoSyncTimer?.cancel();
    super.onClose();
  }
}

/// Sync result
class SyncResult {
  final bool success;
  final String message;
  final int syncedCount;
  final int failedCount;

  SyncResult({
    required this.success,
    required this.message,
    this.syncedCount = 0,
    this.failedCount = 0,
  });
}

class _SyncBatchResult {
  final int synced;
  final int failed;

  _SyncBatchResult({required this.synced, required this.failed});
}
