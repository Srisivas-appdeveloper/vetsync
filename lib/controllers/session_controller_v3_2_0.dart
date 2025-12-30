/// Session controller with v3.2.0 dual upload & data router support
/// File: lib/controllers/session_controller_v3_2_0.dart

import 'package:flutter/material.dart'; // Added for Colors, specific UI classes
import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' hide BluetoothDevice;
// Using hide to avoid potential conflicts if any, though not strictly needed unless collision.
// Actually flutter_blue_plus might change API, but user provided code.
// User code: import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../services/dual_upload_service.dart';
import '../services/surgery_data_router.dart';
import '../services/calibration_service.dart';
import '../services/bcg_processor_service.dart';
import '../services/ble_service.dart';

class SessionControllerV3_2_0 extends GetxController {
  // Assuming these are registered in standard GetX DI
  final DualUploadService _dualUpload = Get.find();
  final SurgeryDataRouter _surgeryRouter = Get.find();
  final CalibrationService _calibration = Get.find();
  final BCGProcessorService _bcgProcessor = Get.find();
  final BLEService _bleService = Get.find();

  // Session state
  final currentPhase = 'idle'.obs;
  final sessionId = Rx<String?>(null);

  // Surgery mode state
  final laptopConnected = false.obs;
  final routerActive = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Load saved calibration on start
    _calibration.loadSavedCalibration();
  }

  /// Start pre-surgery monitoring phase
  Future<void> startPreSurgery({
    required String sessionId,
    required String animalId,
    required String collarId,
  }) async {
    print('[SessionController] Starting pre-surgery phase...');

    this.sessionId.value = sessionId;
    currentPhase.value = 'pre_surgery';

    // Start dual upload service in FILTERED mode
    _dualUpload.startSession(sessionId, 'pre_surgery', 'filtered');

    // Enable BCG processor (local processing)
    _bcgProcessor.start();

    // Switch collar to FILTERED mode (100Hz)
    await _bleService.sendCommand(0x01);

    print('[SessionController] Pre-surgery started: Dual upload active');
  }

  /// Transition to surgery phase
  Future<void> startSurgery({
    required String laptopIp,
    int laptopPort = 8765,
  }) async {
    print('[SessionController] Transitioning to surgery phase...');

    if (sessionId.value == null) {
      throw Exception('No active session');
    }

    // Flush pre-surgery upload buffers
    await _dualUpload.flushBuffers();
    await _dualUpload.stopSession();

    currentPhase.value = 'surgery';

    // Switch collar to RAW mode (128Hz pressure, 200Hz IMU)
    await _bleService.sendCommand(0x02);

    // Wait for collar to switch modes
    await Future.delayed(Duration(seconds: 2));

    // Initialize surgery data router
    await _surgeryRouter.initialize(
      sessionId: sessionId.value!,
      laptopIp: laptopIp,
      laptopPort: laptopPort,
      dataCharacteristic: _bleService.dataCharacteristic!,
    );

    // Pause BCG processor (mobile is dumb pipe in surgery mode)
    _bcgProcessor.pause();

    laptopConnected.value = true;
    routerActive.value = true;

    print('[SessionController] Surgery started: Data router active');
  }

  /// Complete surgery and start calibration
  Future<void> completeSurgery() async {
    print('[SessionController] Completing surgery...');

    // Shutdown data router
    await _surgeryRouter.shutdown();

    routerActive.value = false;
    laptopConnected.value = false;
    currentPhase.value = 'calibration_pending';

    // Show calibration pending dialog
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: Text('Calibration in Progress'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Laptop is generating pet-specific algorithm...'),
              SizedBox(height: 8),
              Text(
                'This usually takes 2-5 minutes.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    // Wait for calibration download (triggered by push notification)
    // CalibrationService handles automatic download
    print('[SessionController] Waiting for calibration...');
  }

  /// Start recovery phase with custom algorithm
  Future<void> startRecovery() async {
    print('[SessionController] Starting recovery phase...');

    if (sessionId.value == null) {
      throw Exception('No active session');
    }

    // Download and apply calibration if not already done
    if (!_calibration.hasCustomCalibration) {
      final success = await _calibration.downloadAndApplyCalibration();
      if (!success) {
        Get.snackbar(
          'Warning',
          'Could not download custom algorithm. Using default algorithm.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }

    currentPhase.value = 'recovery';

    // Switch collar back to FILTERED mode (100Hz)
    await _bleService.sendCommand(0x01);

    // Wait for collar to switch modes
    await Future.delayed(Duration(seconds: 2));

    // Resume BCG processor (now with custom algorithm)
    _bcgProcessor.resume();

    // Resume dual upload service
    _dualUpload.startSession(sessionId.value!, 'recovery', 'filtered');

    print('[SessionController] Recovery started: Custom algorithm active');

    // Show success notification
    Get.snackbar(
      'Custom Algorithm Active',
      'Monitoring accuracy improved! Quality: ${_calibration.calibrationQuality?.toStringAsFixed(1)}%',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green[100],
      duration: Duration(seconds: 5),
    );
  }

  /// End session
  Future<void> endSession() async {
    print('[SessionController] Ending session...');

    // Flush all buffers
    await _dualUpload.flushBuffers();
    await _dualUpload.stopSession();

    // Stop BCG processor
    _bcgProcessor.stop();

    // Disconnect collar
    await _bleService.disconnect();

    sessionId.value = null;
    currentPhase.value = 'idle';

    print('[SessionController] Session ended');
  }

  /// Handle calibration download complete
  void onCalibrationDownloaded() {
    // Dismiss calibration pending dialog
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    // Show success dialog
    Get.dialog(
      AlertDialog(
        title: Text('Calibration Complete! ✅'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pet-specific algorithm downloaded successfully.'),
            SizedBox(height: 16),
            Text(
              'Quality Score: ${_calibration.calibrationQuality?.toStringAsFixed(1)}%',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              startRecovery();
            },
            child: Text('Start Recovery Monitoring'),
          ),
        ],
      ),
    );
  }
}
