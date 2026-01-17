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

  // Auto-stop scan when collar found (configurable)
  final RxBool autoStopOnFound = true.obs;
  Worker? _collarDiscoveryWorker;

  // Location services monitoring
  Timer? _locationCheckTimer;
  final RxBool isLocationServiceEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadLastCollar();
    _checkPermissions();

    // Listen to BLE connection state
    ever(_bleService.connectionState, (state) {
      connectionState.value = state;
    });

    // Start monitoring location services
    _startLocationServiceMonitoring();
  }

  @override
  void onClose() {
    stopScan();
    _collarDiscoveryWorker?.dispose();
    _locationCheckTimer?.cancel();
    super.onClose();
  }

  /// Monitor location services status periodically
  void _startLocationServiceMonitoring() {
    _checkLocationServiceStatus();

    // Check every 3 seconds
    _locationCheckTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _checkLocationServiceStatus(),
    );
  }

  /// Check current location service status
  Future<void> _checkLocationServiceStatus() async {
    if (!hasPermission.value) return;

    final locationServiceStatus = await Permission.location.serviceStatus;
    final wasEnabled = isLocationServiceEnabled.value;
    isLocationServiceEnabled.value = locationServiceStatus.isEnabled;

    // If location was disabled and now enabled, auto-start scan
    if (!wasEnabled && isLocationServiceEnabled.value) {
      print('[SCAN] ✅ Location services enabled - starting scan');
      Get.snackbar(
        'Location Enabled',
        'Location services are now ON. Starting scan...',
        duration: const Duration(seconds: 2),
        backgroundColor: Get.theme.colorScheme.primaryContainer,
      );
      startScan();
    }

    // If location is disabled and we have permissions, show persistent warning
    if (!isLocationServiceEnabled.value && hasPermission.value) {
      _showLocationRequiredDialog();
    }
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
      // Check if location services are enabled
      final locationServiceStatus = await Permission.location.serviceStatus;
      if (!locationServiceStatus.isEnabled) {
        Get.snackbar(
          'Location Services Required',
          'Please turn ON location services in your device settings to scan for Bluetooth devices',
          duration: const Duration(seconds: 8),
          mainButton: TextButton(
            onPressed: () => openAppSettings(),
            child: const Text('Open Settings'),
          ),
        );
      } else {
        startScan();
      }
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

  /// Show dialog prompting user to enable location services
  bool _isShowingLocationDialog = false;

  void _showLocationRequiredDialog() {
    // Prevent multiple dialogs from stacking
    if (_isShowingLocationDialog) return;
    if (Get.isDialogOpen == true) return;

    _isShowingLocationDialog = true;

    Get.dialog(
      PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            _isShowingLocationDialog = false;
          }
        },
        child: AlertDialog(
          title: Row(
            children: [
              Icon(Icons.location_off, color: Get.theme.colorScheme.error),
              const SizedBox(width: 12),
              const Expanded(child: Text('Location Services OFF')),
            ],
          ),
          content: const Text(
            'Location services must be turned ON to scan for Bluetooth devices.\n\n'
            'This is an Android requirement for Bluetooth scanning.\n\n'
            'Please go to Settings → Location and turn it ON.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                _isShowingLocationDialog = false;
                Get.back();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                _isShowingLocationDialog = false;
                Get.back();
                openAppSettings();
              },
              icon: const Icon(Icons.settings),
              label: const Text('Open Settings'),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    ).then((_) {
      _isShowingLocationDialog = false;
    });
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
      // Cancel previous worker if exists
      _collarDiscoveryWorker?.dispose();

      // Listen to discovered collars from BLE Service
      _collarDiscoveryWorker = ever(_bleService.discoveredCollars, (List<DiscoveredCollar> collars) {
        print('[SCAN] 🔄 Worker triggered: ${collars.length} collar(s) received from BLE service');
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

        // Auto-stop scan when first collar is found (if enabled)
        if (autoStopOnFound.value && collars.isNotEmpty && isScanning.value) {
          print('[SCAN] 🎯 Auto-stopping scan - found ${collars.length} collar(s)');
          // Delay stop slightly to allow more collars to be discovered
          Future.delayed(const Duration(milliseconds: 500), () {
            if (isScanning.value) {
              stopScan();
              Get.snackbar(
                'Collar Found',
                'Found ${discoveredCollars.length} collar(s). Tap to connect.',
                duration: const Duration(seconds: 2),
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          });
        }
      });

      // CRITICAL FIX: Sync initial state immediately
      // Worker only fires on FUTURE changes, not current state
      // If BLE service already found collars before Worker setup, we'd miss them
      if (_bleService.discoveredCollars.isNotEmpty) {
        print('[SCAN] 📋 Syncing initial state: ${_bleService.discoveredCollars.length} collar(s) already discovered');
        discoveredCollars.value = List.from(_bleService.discoveredCollars);

        // Apply last used collar sorting
        if (_lastCollarId != null) {
          final lastUsedIndex = discoveredCollars.indexWhere(
            (c) => c.collarId == _lastCollarId,
          );
          if (lastUsedIndex > 0) {
            final lastUsed = discoveredCollars.removeAt(lastUsedIndex);
            discoveredCollars.insert(0, lastUsed);
          }
        }
      }

      // Start scan - BLE Service handles device discovery internally
      await _bleService.startScan();
    } catch (e) {
      connectionError.value = 'Scan failed: ${e.toString()}';

      // Show specific message for location services issue
      if (e.toString().contains('Location services')) {
        Get.snackbar(
          'Location Services Required',
          'Please turn ON location services in your device settings',
          duration: const Duration(seconds: 8),
          backgroundColor: Get.theme.colorScheme.errorContainer,
          colorText: Get.theme.colorScheme.onErrorContainer,
          mainButton: TextButton(
            onPressed: () => openAppSettings(),
            child: const Text('Open Settings'),
          ),
        );
      }
    }
  }

  /// Stop BLE scan
  void stopScan() {
    _bleService.stopScan();
    isScanning.value = false;
    print('[SCAN] 🛑 Scan stopped. Found ${discoveredCollars.length} collar(s)');
  }

  /// Toggle auto-stop on collar discovery
  void toggleAutoStop() {
    autoStopOnFound.value = !autoStopOnFound.value;
    print('[SCAN] Auto-stop ${autoStopOnFound.value ? "enabled" : "disabled"}');
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
          batteryPercent: collar.batteryPercent ?? 0, // 0 indicates unknown until connected
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

      // Check battery (only if battery data is available)
      if (collar.batteryPercent != null &&
          collar.batteryPercent! < AppConfig.batteryCritical) {
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
