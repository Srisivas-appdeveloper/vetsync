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
  bool get isCollarConnected => _bleService.isConnected;
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

    // Listen to connection state
    ever(_bleService.connectionState, _handleConnectionChange);
  }

  /// Handle BLE connection state changes
  void _handleConnectionChange(BleConnectionState state) {
    if (state == BleConnectionState.disconnected &&
        currentSession.value != null) {
      // Reconnection is handled automatically by BleService
      // Just show a notification
      Get.snackbar(
        'Connection Lost',
        'Attempting to reconnect to collar...',
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Check battery and show warnings
  void _checkBatteryWarning(int battery) {
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
    String? notes,
  }) async {
    try {
      final session = await _sessionRepo.createSession(
        animalId: animal.id,
        collarId: collar.id,
        observerId: observerId,
        clinicId: clinicId,
        initialPosition: position,
        initialAnxiety: anxiety,
        initialNotes: notes,
        collarPhotoPath: collarPhotoPath,
      );

      currentSession.value = session;
      currentAnimal.value = animal;
      currentCollar.value = collar;
      sessionStartTime.value = DateTime.now();

      // Store active session ID
      await _storage.setActiveSessionId(session.id);
      await _storage.setLastCollarId(collar.id);

      // Start duration timer
      _startDurationTimer();

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to create session');
      return false;
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

    try {
      // Update session with surgery details
      await _sessionRepo.updateSurgeryDetails(
        sessionId: currentSession.value!.id,
        surgeryType: surgeryType,
        surgeryReason: surgeryReason,
        asaStatus: asaStatus,
      );

      // Transition to surgery phase
      await _sessionRepo.updatePhase(
        currentSession.value!.id,
        SessionPhase.surgery,
      );

      // Switch collar to raw mode for calibration
      await _bleService.switchMode(
        FirmwareMode.raw,
        sessionId: currentSession.value!.id.hashCode,
      );

      // Update local session state
      currentSession.value = currentSession.value!.copyWith(
        currentPhase: SessionPhase.surgery,
        surgeryType: surgeryType,
        surgeryReason: surgeryReason,
        asaStatus: asaStatus,
      );
      surgeryStartTime.value = DateTime.now();

      // Add annotation
      _addSystemAnnotation('Surgery started: $surgeryType');

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to start surgery phase');
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
}
