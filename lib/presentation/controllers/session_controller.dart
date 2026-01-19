import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_pages.dart';
import '../../data/models/models.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/ble_service.dart';
import '../../data/services/websocket_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/repositories/annotation_repository.dart';

/// Main controller for session lifecycle
/// Persists throughout entire session flow
class SessionController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final BleService _bleService = Get.find<BleService>();
  final WebSocketService _wsService = Get.find<WebSocketService>();
  final StorageService _storage = Get.find<StorageService>();
  final SessionRepository _sessionRepo = Get.find<SessionRepository>();
  final AnnotationRepository _annotationRepo = Get.find<AnnotationRepository>();

  // Current session state
  final Rx<Session?> currentSession = Rx<Session?>(null);
  final Rx<Animal?> currentAnimal = Rx<Animal?>(null);
  final Rx<Collar?> currentCollar = Rx<Collar?>(null);

  // Baseline data (stored separately for easy reactive access)
  final Rx<BaselineData?> baselineData = Rx<BaselineData?>(null);

  // Session state
  final RxBool sessionPaused = false.obs;
  // Helper to distinguish between ended vs paused
  bool get isSessionActive =>
      currentSession.value != null && currentSession.value!.endedAt == null;

  // Phase timing
  final Rx<DateTime?> sessionStartTime = Rx<DateTime?>(null);
  final Rx<DateTime?> surgeryStartTime = Rx<DateTime?>(null);
  final Rx<DateTime?> surgeryEndTime = Rx<DateTime?>(null);

  // Real-time vitals
  final Rx<Vitals?> latestVitals = Rx<Vitals?>(null);
  final RxInt signalQuality = 0.obs;
  final RxInt batteryPercent = 100.obs;

  // Annotations
  final RxList<Annotation> sessionAnnotations = <Annotation>[].obs;

  // Session duration timer
  Timer? _durationTimer;
  final RxString sessionDuration = '00:00:00'.obs;
  final RxString phaseDuration = '00:00:00'.obs;

  // Connection states
  bool get isCollarConnected =>
      _bleService.isConnected.value; // Use composite value

  bool get isLaptopConnected =>
      _wsService.connectionState.value == WebSocketState.connected;
  BleConnectionState get bleState => _bleService.connectionState.value;

  // Current phase
  SessionPhase get currentPhase =>
      currentSession.value?.currentPhase ?? SessionPhase.preSurgery;

  // Observer info
  String get observerId => _authService.currentObserver.value?.id ?? '';
  String get clinicId => _authService.currentObserver.value?.clinicId ?? '';

  @override
  void onInit() {
    super.onInit();
    _setupBleListeners();
  }

  @override
  void onClose() {
    _durationTimer?.cancel();
    super.onClose();
  }

  /// Setup BLE data listeners
  void _setupBleListeners() {
    // Listen to vitals stream
    _bleService.vitalsStream.listen((vitals) {
      latestVitals.value = vitals;
      signalQuality.value = vitals.signalQuality;
    });

    // Listen to battery updates from the reactive value
    ever(_bleService.batteryPercent, (int battery) {
      batteryPercent.value = battery;
      _checkBatteryWarning(battery);
    });

    // Listen to COMPOSITE connection state
    ever(_bleService.isConnected, _handleConnectionChange);
  }

  /// Handle BLE connection state changes (Composite)
  void _handleConnectionChange(bool connected) {
    if (!isSessionActive) return;

    if (!connected) {
      // Disconnected: Show warning and start auto-pause timer
      Get.snackbar(
        'Connection Lost',
        'Attempting to reconnect to collar...',
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.orange[100],
        colorText: Colors.black,
        icon: const Icon(Icons.warning, color: Colors.orange),
      );

      // Auto-pause after 60 seconds if not reconnected
      Future.delayed(const Duration(seconds: 60), () {
        if (!_bleService.isConnected.value && isSessionActive) {
          print('[Session] Auto-pausing session due to extended disconnection');
          pauseSession();

          Get.snackbar(
            'Session Paused',
            'Session paused due to collar disconnection',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange[100],
            duration: const Duration(seconds: 5),
            icon: const Icon(Icons.pause, color: Colors.orange),
          );
        }
      });
    } else {
      // Connected: Resume if needed
      if (sessionPaused.value) {
        resumeSession();
        Get.snackbar(
          'Session Resumed',
          'Monitoring resumed after reconnection',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green[100],
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle, color: Colors.green),
        );
      }
    }
  }

  /// Check battery and show warnings
  void _checkBatteryWarning(int battery) {
    // Don't create annotations during pre-surgery/baseline phase
    if (currentSession.value?.currentPhase == SessionPhase.preSurgery) {
      // Still show snackbar warnings, just no annotations
      if (battery <= 5) {
        Get.snackbar(
          'Battery Emergency',
          'Collar battery at $battery%. Swap collar now!',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 10),
        );
      }
      return;
    }

    if (battery <= 5) {
      _addSystemAnnotation(
        'Battery emergency ($battery%) - Swap collar immediately',
      );
      Get.snackbar(
        'Battery Emergency',
        'Collar battery at $battery%. Swap collar now!',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 10),
      );
    } else if (battery <= 10) {
      _addSystemAnnotation('Battery critical ($battery%)');
    } else if (battery <= 20) {
      _addSystemAnnotation('Battery low ($battery%)');
    }
  }

  // ============================================================
  // Session Lifecycle
  // ============================================================

  /// Initialize a new session
  Future<bool> initializeSession({
    required Animal animal,
    required Collar collar,
    String? collarPhotoPath,
    PetPosition? position,
    AnxietyLevel? anxiety,
    bool verySick = false,
    String? notes,
  }) async {
    try {
      print('[Session] 📝 ========================================');
      print('[Session] 📝 INITIALIZING NEW SESSION');
      print('[Session] 📝 ========================================');
      print('[Session] Animal: ${animal.name} (ID: ${animal.id})');
      print('[Session] Collar: ${collar.serialNumber} (ID: ${collar.id})');
      print('[Session] Observer ID: $observerId');
      print('[Session] Clinic ID: $clinicId');
      print('[Session] Position: ${position?.value ?? 'null'}');
      print('[Session] Anxiety: ${anxiety?.value ?? 'null'}');
      print('[Session] Very Sick: $verySick');
      print('[Session] Notes: ${notes ?? 'null'}');
      print('[Session] Collar Photo: ${collarPhotoPath ?? 'null'}');
      print('[Session] 📝 ========================================');

      final session = await _sessionRepo.createSession(
        animalId: animal.id,
        collarId: collar.id,
        observerId: observerId,
        clinicId: clinicId,
        initialPosition: position,
        initialAnxiety: anxiety,
        verySick: verySick,
        initialNotes: notes,
        collarPhotoPath: collarPhotoPath,
      );

      print('[Session] ✅ Session created with ID: ${session.id}');

      currentSession.value = session;
      currentAnimal.value = animal;
      currentCollar.value = collar;
      sessionStartTime.value = DateTime.now();

      // Store active session ID
      print('[Session] 💾 Storing session ID and collar ID...');
      await _storage.setActiveSessionId(session.id);
      await _storage.setLastCollarId(collar.id);

      // Start duration timer
      print('[Session] ⏱️ Starting duration timer...');
      _startDurationTimer();

      print('[Session] ✅ Session initialization complete');
      print('[Session] 📝 ========================================');
      return true;
    } catch (e, stack) {
      print('[Session] ❌ ========================================');
      print('[Session] ❌ ERROR INITIALIZING SESSION');
      print('[Session] ❌ ========================================');
      print('[Session] Error: $e');
      print('[Session] Stack trace:');
      print('$stack');
      print('[Session] ❌ ========================================');

      Get.snackbar(
        'Error',
        'Failed to create session: ${e.toString()}',
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return false;
    }
  }

  /// Load baseline data for current session
  /// Called when entering pre-surgery phase or when baseline might be missing
  Future<void> loadBaselineData() async {
    if (currentSession.value == null) {
      print('[Session] Cannot load baseline - no active session');
      return;
    }

    final sessionId = currentSession.value!.id;

    // Check if already in memory
    if (baselineData.value != null) {
      print('[Session] Baseline already loaded in memory');
      return;
    }

    // Check if session object has baseline
    if (currentSession.value!.baselineData != null) {
      print('[Session] Loading baseline from session object');
      baselineData.value = currentSession.value!.baselineData;
      return;
    }

    print('[Session] Attempting to load baseline from database...');

    try {
      // Reload session from database to get latest baseline
      final freshSession = await _sessionRepo.getSession(sessionId);

      if (freshSession?.baselineData != null) {
        print('[Session] ✅ Loaded baseline from database');
        baselineData.value = freshSession!.baselineData;

        // Update current session with baseline
        currentSession.value = freshSession;
        return;
      }

      print('[Session] No baseline found in database - this is OK (baseline is optional)');
    } catch (e, stack) {
      print('[Session] ❌ Error loading baseline: $e');
      print('[Session] Stack: $stack');
      // Don't show error to user - missing baseline is acceptable
    }
  }

  /// Start duration timer
  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateDurations();
    });
  }

  void _updateDurations() {
    // Session duration
    if (sessionStartTime.value != null) {
      final elapsed = DateTime.now().difference(sessionStartTime.value!);
      sessionDuration.value = _formatDuration(elapsed);
    }

    // Phase duration
    DateTime? phaseStart;
    switch (currentPhase) {
      case SessionPhase.preSurgery:
        phaseStart = sessionStartTime.value;
        break;
      case SessionPhase.surgery:
        phaseStart = surgeryStartTime.value;
        break;
      case SessionPhase.recovery:
        phaseStart = surgeryEndTime.value;
        break;
      default:
        break;
    }

    if (phaseStart != null) {
      final elapsed = DateTime.now().difference(phaseStart);
      phaseDuration.value = _formatDuration(elapsed);
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  // ============================================================
  // Phase Transitions
  // ============================================================

  /// Transition to surgery phase
  Future<bool> startSurgery({
    required String surgeryType,
    required String surgeryReason,
    required ASAStatus asaStatus,
  }) async {
    if (currentSession.value == null) return false;

    print('[Session] 🚀 Starting surgery sequence...');

    try {
      // Update session with surgery details
      print('[Session] 📝 Updating surgery details...');
      await _sessionRepo.updateSurgeryDetails(
        sessionId: currentSession.value!.id,
        surgeryType: surgeryType,
        surgeryReason: surgeryReason,
        asaStatus: asaStatus,
      );

      // Transition to surgery phase
      print('[Session] 🔄 Updating session phase to SURGERY...');
      await _sessionRepo.updatePhase(
        currentSession.value!.id,
        SessionPhase.surgery,
      );

      // 🔥 NEW: Connect to websocket for real-time data streaming
      try {
        print('[Session] 🔌 Connecting to WebSocket...');
        await _wsService.connectToRelay(sessionId: currentSession.value!.id);
        print('[Session] 📡 WebSocket connected for surgery monitoring');
      } catch (e, stackTrace) {
        print('[Session] ⚠️ WebSocket connection failed (non-fatal): $e');
        print('[Session] ✓ Continuing without WebSocket (offline mode)');
        // Continue anyway - websocket is optional for offline mode
      }

      // Switch collar to raw mode for calibration
      print('[Session] 📡 Switching collar to RAW mode...');
      try {
        await _bleService.switchMode(
          FirmwareMode.raw,
          sessionId: currentSession.value!.id.hashCode,
        );
        print('[Session] ⏳ Waiting for mode switch to stabilize...');

        // Give the collar time to stabilize in new mode before proceeding
        await Future.delayed(const Duration(milliseconds: 1500));

        print('[Session] ✅ Collar switched to RAW mode');
      } catch (e) {
        print('[Session] ❌ Failed to switch collar mode: $e');
        // Decide if this is fatal. Usually yes, as surgery needs high-res data.
        // For now we rethrow to hit the main catch block and show error.
        rethrow;
      }

      // Update local session state
      print('[Session] 💾 Updating local session state...');
      currentSession.value = currentSession.value!.copyWith(
        currentPhase: SessionPhase.surgery,
        surgeryType: surgeryType,
        surgeryReason: surgeryReason,
        asaStatus: asaStatus,
      );
      surgeryStartTime.value = DateTime.now();

      // Add annotation
      _addSystemAnnotation('Surgery started: $surgeryType');

      print('[Session] ✅ Surgery start sequence COMPLETE');
      return true;
    } catch (e, stack) {
      print('[Session] ❌ ERROR starting surgery: $e');
      print(stack);
      Get.snackbar(
        'Error',
        'Failed to start surgery: ${e.toString()}',
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return false;
    }
  }

  /// End surgery and start calibration
  Future<bool> endSurgery() async {
    if (currentSession.value == null) return false;

    try {
      await _sessionRepo.updatePhase(
        currentSession.value!.id,
        SessionPhase.calibration,
      );

      // Update local session state
      currentSession.value = currentSession.value!.copyWith(
        currentPhase: SessionPhase.calibration,
      );
      surgeryEndTime.value = DateTime.now();

      _addSystemAnnotation('Surgery ended');

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to end surgery');
      return false;
    }
  }

  /// Complete calibration and start recovery
  Future<bool> startRecovery({
    bool calibrationSuccess = false,
    double? calibrationCorrelation,
    double? calibrationErrorBpm,
  }) async {
    if (currentSession.value == null) return false;

    try {
      // Switch collar back to filtered mode
      await _bleService.switchMode(FirmwareMode.filtered);

      await _sessionRepo.updatePhase(
        currentSession.value!.id,
        SessionPhase.recovery,
      );

      // Update local session state
      currentSession.value = currentSession.value!.copyWith(
        currentPhase: SessionPhase.recovery,
      );

      _addSystemAnnotation('Recovery phase started');

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to start recovery');
      return false;
    }
  }

  /// End session
  Future<bool> endSession() async {
    if (currentSession.value == null) return false;

    try {
      // endSession takes positional argument
      await _sessionRepo.endSession(currentSession.value!.id);

      // Disconnect websocket
      await _wsService.disconnect();

      // Disconnect collar
      await _bleService.disconnect();

      // Clear active session
      await _storage.setActiveSessionId(null);

      // Stop timer
      _durationTimer?.cancel();

      // Update local session state
      currentSession.value = currentSession.value!.copyWith(
        currentPhase: SessionPhase.completed,
        endedAt: DateTime.now(),
      );

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to end session');
      return false;
    }
  }

  // ============================================================
  // Annotations
  // ============================================================

  /// Add annotation to current session
  Future<void> addAnnotation({
    required AnnotationCategory category,
    required String type,
    String? description,
    AnnotationSeverity severity = AnnotationSeverity.info,
    Map<String, dynamic>? structuredData,
    String? voiceNotePath,
  }) async {
    if (currentSession.value == null) return;

    final elapsedMs = sessionStartTime.value != null
        ? DateTime.now().difference(sessionStartTime.value!).inMilliseconds
        : 0;

    final annotation = Annotation(
      sessionId: currentSession.value!.id,
      timestampUtc: DateTime.now().toUtc(),
      elapsedMs: elapsedMs,
      phase: currentPhase,
      category: category,
      type: type,
      description: description,
      severity: severity,
      structuredData: structuredData,
      voiceNotePath: voiceNotePath,
      annotatorUserId: observerId,
    );

    try {
      final savedAnnotation = await _annotationRepo.saveAnnotation(annotation);
      sessionAnnotations.add(savedAnnotation);
    } catch (e) {
      // Queue for later sync
      sessionAnnotations.add(annotation);
    }
  }

  /// Add system-generated annotation
  void _addSystemAnnotation(String message) {
    addAnnotation(
      category: AnnotationCategory.system,
      type: 'system_event',
      description: message,
      severity: AnnotationSeverity.info,
    );
  }

  /// Add physiological event annotation
  Future<void> addPhysiologicalEvent({
    required PhysiologicalEventType eventType,
    EventSeverityLevel? severity,
    String? notes,
  }) async {
    await addAnnotation(
      category: AnnotationCategory.physiological,
      type: eventType.value,
      description: notes,
      severity: eventType.isCritical
          ? AnnotationSeverity.critical
          : AnnotationSeverity.info,
      structuredData: {
        'event_type': eventType.value,
        'severity_level': severity?.value,
        'signal_impact': true,
      },
    );
  }

  // ============================================================
  // Collar Management
  // ============================================================

  /// Swap collar mid-session
  Future<bool> swapCollar(
    Collar newCollar, {
    String reason = 'Collar swap',
  }) async {
    if (currentSession.value == null) return false;

    try {
      // Disconnect current collar
      await _bleService.disconnect();

      // Add gap annotation
      _addSystemAnnotation(
        'Collar swap: ${currentCollar.value?.serialNumber} → ${newCollar.serialNumber}',
      );

      // Update session with new collar using changeCollar method
      await _sessionRepo.changeCollar(
        sessionId: currentSession.value!.id,
        newCollarId: newCollar.id,
        reason: reason,
      );

      // Connect to new collar
      // Note: This needs to be done via CollarScanController
      currentCollar.value = newCollar;

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to swap collar');
      return false;
    }
  }

  // ============================================================
  // Cleanup
  // ============================================================

  /// Clear session data (after completion or cancellation)
  void clearSession() {
    currentSession.value = null;
    currentAnimal.value = null;
    currentCollar.value = null;
    sessionStartTime.value = null;
    surgeryStartTime.value = null;
    surgeryEndTime.value = null;
    latestVitals.value = null;
    sessionAnnotations.clear();
    sessionDuration.value = '00:00:00';
    phaseDuration.value = '00:00:00';
    _durationTimer?.cancel();
  }

  /// Cancel session
  Future<void> cancelSession() async {
    if (currentSession.value != null) {
      try {
        // Use endSession to mark as completed (no separate cancel method)
        await _sessionRepo.endSession(currentSession.value!.id);
      } catch (e) {
        // Ignore cancellation errors
      }
    }

    await _bleService.disconnect();
    await _storage.setActiveSessionId(null);
    clearSession();
    Get.offAllNamed(Routes.dashboard);
  }

  void pauseSession() {
    sessionPaused.value = true;
    _durationTimer?.cancel();
    // Add annotation
    _addSystemAnnotation('Session paused (Auto-pause)');
  }

  void resumeSession() {
    sessionPaused.value = false;
    _startDurationTimer();
    _addSystemAnnotation('Session resumed');
  }
}
