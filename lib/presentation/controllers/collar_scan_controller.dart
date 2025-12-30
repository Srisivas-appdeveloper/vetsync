import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../app/routes/app_pages.dart';
import '../../core/constants/app_config.dart';
import '../../data/models/models.dart';
import '../../data/services/ble_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/repositories/collar_repository.dart';
import 'session_controller.dart';

/// Controller for collar BLE scanning
class CollarScanController extends GetxController {
  final BleService _bleService = Get.find<BleService>();
  final CollarRepository _collarRepo = Get.find<CollarRepository>();
  final SessionController _sessionController = Get.find<SessionController>();

  // Scan state
  final RxBool isScanning = false.obs;
  final RxBool isConnecting = false.obs;
  final RxBool hasPermission = false.obs;
  final RxList<DiscoveredCollar> discoveredCollars = <DiscoveredCollar>[].obs;
  final Rx<DiscoveredCollar?> selectedCollar = Rx<DiscoveredCollar?>(null);

  // Connection state
  final Rx<BleConnectionState> connectionState =
      BleConnectionState.disconnected.obs;
  final RxString connectionError = ''.obs;

  // Last used collar ID
  String? _lastCollarId;

  @override
  void onInit() {
    super.onInit();
    _loadLastCollar();
    _checkPermissions();

    // Listen to BLE connection state
    ever(_bleService.connectionState, (state) {
      connectionState.value = state;
    });
  }

  @override
  void onClose() {
    stopScan();
    super.onClose();
  }

  /// Load last used collar ID
  Future<void> _loadLastCollar() async {
    _lastCollarId = await Get.find<StorageService>().getLastCollarId();
  }

  /// Check and request BLE permissions
  Future<void> _checkPermissions() async {
    final bluetoothScan = await Permission.bluetoothScan.request();
    final bluetoothConnect = await Permission.bluetoothConnect.request();
    final location = await Permission.locationWhenInUse.request();

    hasPermission.value =
        bluetoothScan.isGranted &&
        bluetoothConnect.isGranted &&
        location.isGranted;

    if (hasPermission.value) {
      startScan();
    }
  }

  /// Request permissions
  Future<void> requestPermissions() async {
    await _checkPermissions();

    if (!hasPermission.value) {
      Get.snackbar(
        'Permissions Required',
        'Bluetooth and location permissions are required to scan for collars',
        duration: const Duration(seconds: 5),
        mainButton: TextButton(
          onPressed: () => openAppSettings(),
          child: const Text('Settings'),
        ),
      );
    }
  }

  /// Start BLE scan
  Future<void> startScan() async {
    if (!hasPermission.value) {
      await requestPermissions();
      return;
    }

    if (isScanning.value) return;

    isScanning.value = true;
    discoveredCollars.clear();
    connectionError.value = '';

    try {
      // Start scan - BleService handles device discovery internally
      await _bleService.startScan();

      // Listen to discovered collars from BleService
      ever(_bleService.discoveredCollars, (List<DiscoveredCollar> collars) {
        discoveredCollars.value = collars;

        // Highlight last used collar by moving to top
        if (_lastCollarId != null) {
          final lastUsedIndex = discoveredCollars.indexWhere(
            (c) => c.collarId == _lastCollarId,
          );
          if (lastUsedIndex > 0) {
            final lastUsed = discoveredCollars.removeAt(lastUsedIndex);
            discoveredCollars.insert(0, lastUsed);
          }
        }
      });
    } catch (e) {
      connectionError.value = 'Scan failed: ${e.toString()}';
    }
  }

  /// Stop BLE scan
  void stopScan() {
    _bleService.stopScan();
    isScanning.value = false;
  }

  /// Connect to a collar
  Future<void> connectToCollar(DiscoveredCollar collar) async {
    if (isConnecting.value) return;

    stopScan();
    selectedCollar.value = collar;
    isConnecting.value = true;
    connectionError.value = '';

    try {
      // Connect via BLE - pass the DiscoveredCollar object
      await _bleService.connect(collar);

      if (!_bleService.isConnected.value) {
        throw Exception('Connection failed');
      }

      // Verify collar in backend
      Collar? backendCollar;
      try {
        backendCollar = await _collarRepo.getCollar(collar.collarId);
      } catch (e) {
        // Collar not registered in backend - that's okay for now
        // Create a local collar object
        backendCollar = Collar(
          id: collar.collarId,
          serialNumber: collar.collarId,
          firmwareVersion: collar.firmwareVersion,
          batteryPercent: collar.batteryPercent ?? 100,
          status: CollarStatus.available,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }

      // Check if collar is available
      if (backendCollar.status != CollarStatus.available &&
          backendCollar.currentSessionId != null) {
        Get.snackbar(
          'Collar In Use',
          'This collar is currently in use by another session',
          snackPosition: SnackPosition.BOTTOM,
        );
        await _bleService.disconnect();
        isConnecting.value = false;
        return;
      }

      // Check battery
      if ((collar.batteryPercent ?? 100) < AppConfig.batteryCritical) {
        final proceed = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Low Battery'),
            content: Text(
              'This collar has ${collar.batteryPercent}% battery. '
              'It may not last through the entire session. Continue anyway?',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Choose Another'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Continue'),
              ),
            ],
          ),
        );

        if (proceed != true) {
          await _bleService.disconnect();
          isConnecting.value = false;
          startScan();
          return;
        }
      }

      // Save last used collar
      await Get.find<StorageService>().setLastCollarId(collar.collarId);

      // Set current collar
      _sessionController.currentCollar.value = backendCollar;

      // Navigate to session setup
      Get.toNamed(Routes.sessionSetup);
    } catch (e) {
      connectionError.value = 'Failed to connect: ${e.toString()}';
      await _bleService.disconnect();
    } finally {
      isConnecting.value = false;
    }
  }

  /// Get display status for a collar
  String getCollarStatus(DiscoveredCollar collar) {
    if (_lastCollarId == collar.collarId) {
      return 'Last Used';
    }
    return collar.signalStrength.displayName;
  }

  /// Check if collar is last used
  bool isLastUsed(DiscoveredCollar collar) {
    return _lastCollarId == collar.collarId;
  }

  /// Get battery warning for a collar
  String? getBatteryWarning(DiscoveredCollar collar) {
    final battery = collar.batteryPercent;
    if (battery == null) return null;

    if (battery <= AppConfig.batteryEmergency) {
      return 'Critical - Replace immediately';
    }
    if (battery <= AppConfig.batteryCritical) {
      return 'Very low battery';
    }
    if (battery <= AppConfig.batteryLow) {
      return 'Low battery';
    }
    if (battery <= AppConfig.batteryWarning) {
      return 'May not last full session';
    }
    return null;
  }
}
