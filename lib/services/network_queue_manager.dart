/// Network queue manager for offline upload retry
/// File: lib/services/network_queue_manager.dart

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data'; // Added for Uint8List
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart'; // For Colors in snackbar
import 'package:get/get.dart';

// Import our new SQLite service
import '../database/sqlite_service.dart';
import '../database/schema_v3_2_0.dart'; // import extension

// Assuming ApiService and models exist
import '../data/services/api_service.dart';
import '../data/models/vitals.dart';

class NetworkQueueManager extends GetxService {
  final SQLiteService _db = Get.find();
  final ApiService _apiService = Get.find();

  // Network state
  final isOnline = false.obs;
  final isProcessingQueue = false.obs;

  // Queue statistics
  final pendingVitalsCount = 0.obs;
  final pendingRawDataCount = 0.obs;

  Timer? _syncTimer;
  StreamSubscription<List<ConnectivityResult>>?
  _connectivitySubscription; // Updated for newer connectivity_plus

  @override
  void onInit() {
    super.onInit();
    _startNetworkMonitoring();
    _startPeriodicSync();
  }

  @override
  void onClose() {
    _syncTimer?.cancel();
    _connectivitySubscription?.cancel();
    super.onClose();
  }

  /// Start monitoring network connectivity
  void _startNetworkMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      // Updated signature for connectivity_plus v5+
      final result = results.isNotEmpty
          ? results.first
          : ConnectivityResult.none;
      final wasOffline = !isOnline.value;
      isOnline.value = result != ConnectivityResult.none;

      if (wasOffline && isOnline.value) {
        print('[QueueManager] Network restored, processing queue...');
        processQueue();
      }
    });

    // Check initial state
    Connectivity().checkConnectivity().then((results) {
      final result = results.isNotEmpty
          ? results.first
          : ConnectivityResult.none;
      isOnline.value = result != ConnectivityResult.none;
    });
  }

  /// Start periodic queue sync (every 30 seconds when online)
  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(Duration(seconds: 30), (_) {
      if (isOnline.value && !isProcessingQueue.value) {
        processQueue();
      }
    });
  }

  /// Process upload queue
  Future<void> processQueue() async {
    if (isProcessingQueue.value || !isOnline.value) {
      return;
    }

    isProcessingQueue.value = true;

    try {
      // Update queue counts
      await _updateQueueCounts();

      // Process vitals queue
      await _processVitalsQueue();

      // Process raw data queue
      await _processRawDataQueue();

      // Update counts again
      await _updateQueueCounts();

      print('[QueueManager] Queue processing complete');
    } catch (e) {
      print('[QueueManager] Queue processing error: $e');
    } finally {
      isProcessingQueue.value = false;
    }
  }

  /// Process vitals upload queue
  Future<void> _processVitalsQueue() async {
    final pending = await _db.getPendingSyncQueue(
      tableName: 'vitals_sync_queue',
      maxRetries: 5,
    );

    for (final item in pending) {
      try {
        final sessionId = item['session_id'] as String;
        final vitalsJson = item['vitals_json'] as String;
        final queueId = item['queue_id'] as int;

        final vitalsData = jsonDecode(vitalsJson) as List;

        // Upload to backend
        await _apiService.uploadVitalsBatch(
          sessionId,
          vitalsData.map((v) => VitalSigns.fromJson(v)).toList(),
        );

        // Mark as uploaded
        await _db.markSyncItemUploaded('vitals_sync_queue', queueId);

        print('[QueueManager] Uploaded queued vitals batch: $queueId');
      } catch (e) {
        print('[QueueManager] Failed to upload vitals: $e');

        // Increment retry count
        await _db.incrementSyncRetryCount(
          'vitals_sync_queue',
          item['queue_id'] as int,
          e.toString(),
        );
      }
    }
  }

  /// Process raw data upload queue
  Future<void> _processRawDataQueue() async {
    final pending = await _db.getPendingSyncQueue(
      tableName: 'raw_data_sync_queue',
      maxRetries: 5,
    );

    for (final item in pending) {
      try {
        final sessionId = item['session_id'] as String;
        final chunkData = item['chunk_data'] as Uint8List;
        final headersJson = item['headers_json'] as String;
        final queueId = item['queue_id'] as int;

        final headers = Map<String, String>.from(jsonDecode(headersJson));

        // Upload to backend
        await _apiService.uploadRawDataChunk(
          sessionId: sessionId,
          headers: headers,
          data: chunkData,
        );

        // Mark as uploaded
        await _db.markSyncItemUploaded('raw_data_sync_queue', queueId);

        print('[QueueManager] Uploaded queued raw data chunk: $queueId');
      } catch (e) {
        print('[QueueManager] Failed to upload raw data: $e');

        // Increment retry count
        await _db.incrementSyncRetryCount(
          'raw_data_sync_queue',
          item['queue_id'] as int,
          e.toString(),
        );
      }
    }
  }

  /// Update queue counts
  Future<void> _updateQueueCounts() async {
    final vitals = await _db.getPendingSyncQueue(
      tableName: 'vitals_sync_queue',
      maxRetries: 5,
    );

    final rawData = await _db.getPendingSyncQueue(
      tableName: 'raw_data_sync_queue',
      maxRetries: 5,
    );

    pendingVitalsCount.value = vitals.length;
    pendingRawDataCount.value = rawData.length;
  }

  /// Force queue processing (called by user action)
  Future<void> forceSync() async {
    if (!isOnline.value) {
      Get.snackbar(
        'Offline',
        'Cannot sync while offline. Data will be uploaded when network returns.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.snackbar(
      'Syncing',
      'Processing upload queue...',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );

    await processQueue();

    if (pendingVitalsCount.value == 0 && pendingRawDataCount.value == 0) {
      Get.snackbar(
        'Success',
        'All data synced successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
      );
    } else {
      Get.snackbar(
        'Partial Sync',
        'Some items still pending: ${pendingVitalsCount.value + pendingRawDataCount.value} remaining',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
