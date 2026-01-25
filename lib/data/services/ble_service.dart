import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../../core/constants/app_config.dart';
import '../../services/bcg_service.dart';
import '../../services/dual_upload_service.dart';
import '../models/models.dart';
import '../models/collar_protocol.dart';
import 'collar_stream_parser.dart';
import 'websocket_service.dart';

/// BLE service for collar communication
class BleService extends GetxService {
  // Connection state
  // Raw BLE Connection state
  final Rx<BleConnectionState> connectionState =
      BleConnectionState.disconnected.obs;

  // Composite Connection State (BLE + Data)
  final RxBool isConnected = false.obs;
  final RxBool isDataStreaming = false.obs;

  // Connected device
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _dataCharacteristic; // TX (Notify)
  BluetoothCharacteristic? _commandCharacteristic; // RX (Write)

  // Current collar info
  final Rxn<DiscoveredCollar> connectedCollar = Rxn<DiscoveredCollar>();

  // Data streams
  final _dataController = StreamController<CollarDataPacket>.broadcast();
  Stream<CollarDataPacket> get dataStream => _dataController.stream;

  // Vitals stream (processed from data packets)
  final _vitalsController = StreamController<Vitals>.broadcast();
  Stream<Vitals> get vitalsStream => _vitalsController.stream;

  // Battery updates with smoothing
  final RxInt batteryPercent = 100.obs;
  double _smoothedBattery = 100.0; // For EMA smoothing
  static const double _batteryAlpha =
      0.1; // Smoothing factor (0-1, lower = smoother) - reduced from 0.2
  DateTime? _lastBatteryUpdate; // Throttle battery updates
  static const Duration _batteryUpdateInterval = Duration(
    seconds: 5,
  ); // Min time between updates

  // Signal quality
  final RxInt signalQuality = 100.obs;

  // Current mode
  final Rx<FirmwareMode> currentMode = FirmwareMode.filtered.obs;

  // Latest collar timestamp (for Phase-1 safety FIX 2)
  final RxInt latestCollarTimestampMs = 0.obs;

  // Packet sequence counter (for Phase-1 safety FIX 3)
  int _packetSequenceNumber = 0;
  int _lastSequenceNumber = -1; // Track last sequence to detect gaps (FIX 3.4)
  int _totalPacketLoss = 0; // Track total packet loss for session (FIX 3.4)

  // Collar boot time tracking (for Phase-1 safety FIX 4)
  bool _hasRecordedBootTime = false;
  int? _collarBootTimeUtcMs;

  // Callback for collar boot time calculation
  Function({
    required int collarBootTimeUtcMs,
    required int firstPacketCollarTs,
    required int firstPacketMobileUtc,
  })? onCollarBootTimeCalculated;

  // Reconnection
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  bool _shouldReconnect = false;
  String? _lastCollarId;

  // Keep-alive mechanism
  Timer? _keepAliveTimer;
  DateTime? _lastDataReceived;
  DateTime? _connectionTime; // Track when we connected
  int _keepAliveFailureCount = 0; // Track consecutive failures
  int _packetCount = 0; // Track received packets for debugging
  static const int _maxKeepAliveFailures = 3;
  static const Duration _keepAliveInterval = Duration(seconds: 10);
  static const Duration _dataTimeout = Duration(
    seconds: 30,
  ); // Increased from 10 to 30 seconds
  static const Duration _initialConnectionGracePeriod = Duration(
    seconds: 5,
  ); // Grace period after connect

  // Connection quality metrics
  final RxInt mtuSize = 23.obs; // Current MTU size
  final RxInt connectionRssi = 0.obs; // Connection signal strength
  int _crcErrorCount = 0; // Track CRC errors for connection quality
  int _totalPacketCount = 0;

  // Scan results
  final RxList<DiscoveredCollar> discoveredCollars = <DiscoveredCollar>[].obs;
  final RxBool isScanning = false.obs;

  // Device-specific scan optimizations
  bool _isProblematicDevice = false;
  String? _deviceManufacturer;
  String? _deviceModel;

  // Stream subscriptions
  StreamSubscription? _scanSubscription;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _dataSubscription;

  // Algorithm instance for data processing refactored to Service
  // Use BcgService to handle buffering, mode switching and processing
  final BcgService _bcgService = BcgService();
  BcgService get bcgService => _bcgService; // Expose for UI access

  // Stream parser for handling BLE packet reassembly and array frames
  final CollarStreamParser _streamParser = CollarStreamParser();

  // WebSocket service for streaming data to laptop/backend
  WebSocketService? _wsService;

  // Dual upload service for batch uploads to cloud
  DualUploadService? _dualUploadService;

  // Debug counter for vitals emission
  int _vitalCount = 0;

  @override
  void onInit() {
    super.onInit();
    _initBle();
  }

  Future<void> _initBle() async {
    // Detect device manufacturer for BLE workarounds
    await _detectDevice();

    // Initialize WebSocket service reference (lazy - may not exist if not started yet)
    try {
      _wsService = Get.find<WebSocketService>();
    } catch (e) {
      debugPrint('[BLE] WebSocket service not available yet');
    }

    // Initialize DualUploadService reference
    try {
      _dualUploadService = Get.find<DualUploadService>();
    } catch (e) {
      debugPrint('[BLE] DualUploadService not available yet');
    }

    // Listen to adapter state
    FlutterBluePlus.adapterState.listen((state) {
      if (state != BluetoothAdapterState.on) {
        connectionState.value = BleConnectionState.disconnected;
        _connectedDevice = null;
        _bcgService.reset();
      }
    });

    // Listen to BCG service updates for Vitals
    _bcgService.addListener(_onBcgUpdate);

    // Monitor raw connection and data streaming to update composite state
    ever(connectionState, (_) => _checkCompositeConnectionState());
    ever(isDataStreaming, (_) => _checkCompositeConnectionState());
  }

  /// Detect device manufacturer and model for BLE workarounds
  Future<void> _detectDevice() async {
    if (!Platform.isAndroid) return;

    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      _deviceManufacturer = androidInfo.manufacturer.toLowerCase();
      _deviceModel = androidInfo.model.toLowerCase();

      // List of manufacturers with known BLE scanning issues
      final problematicManufacturers = [
        'oneplus',
        'oppo',
        'realme',
        'vivo',
        'xiaomi',
        'redmi',
        'poco',
        'samsung', // Some Samsung devices also have issues
      ];

      _isProblematicDevice = problematicManufacturers.any(
        (manufacturer) => _deviceManufacturer?.contains(manufacturer) ?? false,
      );

      if (_isProblematicDevice) {
        print(
          '[BLE] 🔧 Problematic device detected: $_deviceManufacturer $_deviceModel',
        );
        print('[BLE] Using enhanced scan mode for better compatibility');
      }
    } catch (e) {
      print('[BLE] ⚠️ Failed to detect device info: $e');
      // Assume problematic device on error to be safe
      _isProblematicDevice = true;
    }
  }

  void _checkCompositeConnectionState() {
    final bool rawConnected =
        connectionState.value == BleConnectionState.connected;
    final bool streaming = isDataStreaming.value;
    final bool composite = rawConnected && streaming;

    if (isConnected.value != composite) {
      isConnected.value = composite;
      final statusIcon = composite ? '✅' : '⚠️';
      print(
        '$statusIcon [BLE] Connection state: ${composite ? 'CONNECTED' : 'PARTIAL'} '
        '(BLE: ${rawConnected ? 'connected' : 'disconnected'}, '
        'Data: ${streaming ? 'streaming' : 'not streaming'})',
      );
    }
  }

  /// Update battery with exponential moving average smoothing
  void _updateBatterySmoothed(int newValue, {String source = 'unknown'}) {
    // Validate battery value range
    if (newValue < 0 || newValue > 100) {
      print(
        '❌ [BLE] Invalid battery value: $newValue% (source: $source) - IGNORING',
      );
      return;
    }

    // Throttle updates - ignore if too soon (except for command responses which are more reliable)
    final now = DateTime.now();
    final isCommandSource = source == 'battery_cmd' || source == 'device_info';
    if (_lastBatteryUpdate != null && !isCommandSource) {
      final timeSinceLastUpdate = now.difference(_lastBatteryUpdate!);
      if (timeSinceLastUpdate < _batteryUpdateInterval) {
        // Skip this update - too frequent
        return;
      }
    }

    final previousSmoothed = _smoothedBattery;
    final previousDisplay = batteryPercent.value;

    // Initialize smoothed value on first update
    if (_smoothedBattery == 100.0 && newValue < 100) {
      _smoothedBattery = newValue.toDouble();
      _lastBatteryUpdate = now;
      print('[BLE] 🔋 Battery initialized: $newValue% (source: $source)');
    } else {
      // EMA: smoothed = alpha * new + (1 - alpha) * smoothed
      _smoothedBattery =
          _batteryAlpha * newValue + (1 - _batteryAlpha) * _smoothedBattery;

      // Detect large jumps (might indicate parsing error)
      final rawDelta = (newValue - previousDisplay).abs();
      if (rawDelta > 20) {
        print(
          '⚠️ [BLE] Large battery jump detected! '
          'Raw: $newValue%, Previous: $previousDisplay%, Delta: $rawDelta% '
          '(source: $source)',
        );
      }
    }

    // Update observable with rounded value (only if changed)
    final rounded = _smoothedBattery.round();
    if (batteryPercent.value != rounded) {
      final smoothedDelta = (rounded - batteryPercent.value).abs();
      batteryPercent.value = rounded;
      _lastBatteryUpdate = now;

      // Log battery changes for debugging
      if (smoothedDelta > 0) {
        print(
          '[BLE] 🔋 Battery: $rounded% (raw: $newValue%, smoothed from ${previousSmoothed.round()}%, source: $source)',
        );
      }
    }
  }

  /// Handle BCG Service updates
  void _onBcgUpdate() {
    final result = _bcgService.latestResult;
    if (result == null) return;

    // Create vitals from BCG result with confidence values for gating
    final vitals = Vitals(
      heartRateBpm: result.heartRateBpm,
      respiratoryRateBpm: result.respiratoryRateBpm,
      temperatureC: _bcgService.temperatureCelsius,
      signalQuality: result.signalQuality,
      timestamp: DateTime.now().toUtc(),
      // Pass confidence scores for display gating
      hrConfidence: result.hrConfidence,
      rrConfidence: result.rrConfidence,
      // Note: breed ranges will be set by session controller if needed
    );

    // Update local state helpers - ALWAYS update signal quality, not just when valid
    // This ensures the UI shows real-time signal quality even when vitals aren't valid yet
    signalQuality.value = result.signalQuality;

    // Debug log occasionally to verify vitals are being emitted
    _vitalCount++;
    if (_vitalCount % 20 == 0) {
      // debugPrint(
      //   '[BLE] Emitting vital #$_vitalCount: HR=${vitals.heartRateBpm}, RR=${vitals.respiratoryRateBpm}, Q=${vitals.signalQuality}%, Valid=${result.isValid}',
      // );
    }

    // Emit vitals
    _vitalsController.add(vitals);
  }

  /// Request BLE permissions
  Future<bool> requestPermissions() async {
    // Request location permission (required for BLE scanning)
    final locationStatus = await Permission.locationWhenInUse.request();
    if (!locationStatus.isGranted) {
      return false;
    }

    // Request Bluetooth permissions (Android 12+)
    final bluetoothScan = await Permission.bluetoothScan.request();
    final bluetoothConnect = await Permission.bluetoothConnect.request();

    return bluetoothScan.isGranted && bluetoothConnect.isGranted;
  }

  /// Check if Bluetooth is available and enabled
  Future<bool> isBluetoothEnabled() async {
    final state = await FlutterBluePlus.adapterState.first;
    return state == BluetoothAdapterState.on;
  }

  /// Check if location services are enabled (required for BLE scanning on Android)
  Future<bool> isLocationServiceEnabled() async {
    if (!Platform.isAndroid) {
      return true; // Not required on iOS
    }
    final serviceStatus = await Permission.location.serviceStatus;
    return serviceStatus.isEnabled;
  }

  /// Start scanning for collars
  ///
  /// [forceAggressiveScan] - Force aggressive scan mode even on non-problematic devices
  /// Use this if normal scan is not finding devices
  Future<void> startScan({bool forceAggressiveScan = false}) async {
    if (isScanning.value) return;

    // Check permissions
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      throw BleException('Bluetooth permissions not granted');
    }

    // Check if Bluetooth is on
    final isEnabled = await isBluetoothEnabled();
    if (!isEnabled) {
      throw BleException('Bluetooth is not enabled');
    }

    // Check if location services are enabled (Android requirement)
    final isLocationEnabled = await isLocationServiceEnabled();
    if (!isLocationEnabled) {
      throw BleException(
        'Location services must be turned ON to scan for Bluetooth devices. '
        'Please enable location in your device settings.',
      );
    }

    // Clear previous results
    discoveredCollars.clear();
    isScanning.value = true;
    connectionState.value = BleConnectionState.scanning;

    // OnePlus/Problematic device workaround: Use aggressive multi-strategy scan
    if (_isProblematicDevice || forceAggressiveScan) {
      if (forceAggressiveScan && !_isProblematicDevice) {
        print('[BLE] 🔧 Forced aggressive scan mode by user');
      }
      await _startAggressiveScan();
    } else {
      await _startNormalScan();
    }
  }

  /// Check if device is known to have BLE scanning issues
  bool get isProblematicDevice => _isProblematicDevice;

  /// Get device info for debugging
  String get deviceInfo => '$_deviceManufacturer $_deviceModel';

  /// Normal scan for well-behaved devices
  Future<void> _startNormalScan() async {
    print('[BLE] 🔍 Starting NORMAL scan (low latency mode)');

    // Listen to scan results
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (final result in results) {
        _processDiscoveredDevice(result);
      }
    });

    // Start scan with service filter
    await FlutterBluePlus.startScan(
      timeout: AppConfig.bleScanTimeout,
      withServices: [Guid(AppConfig.collarServiceUuid)],
      androidScanMode: AndroidScanMode.lowLatency,
    );

    // Auto-stop after timeout
    Future.delayed(AppConfig.bleScanTimeout, () {
      stopScan();
    });
  }

  /// Aggressive scan strategy for OnePlus/problematic devices
  Future<void> _startAggressiveScan() async {
    print('[BLE] 🔍 Starting AGGRESSIVE scan for problematic device');
    print('[BLE] Device: $_deviceManufacturer $_deviceModel');

    int vetsyncDeviceCount = 0;
    int totalDeviceCount = 0;

    // Listen to scan results with detailed logging
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      // Process all results at once (batch)
      for (final result in results) {
        final name = result.device.platformName;
        final rssi = result.rssi;

        // Count all devices with names
        if (name.isNotEmpty) {
          totalDeviceCount++;
          print('[BLE] 📱 Found device: "$name" (RSSI: $rssi dBm)');
        }

        // Process VetSync devices
        if (name.startsWith('VetSync_')) {
          vetsyncDeviceCount++;
          print('[BLE] 🎯 VetSync collar detected: $name');
          _processDiscoveredDevice(result);
        }
      }
    });

    try {
      // STRATEGY 1: Scan without ANY filters (most aggressive)
      print('[BLE] Strategy 1: Scanning without ANY filters (7 seconds)...');
      print('[BLE] This will find ALL nearby BLE devices...');

      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 7),
        androidScanMode: AndroidScanMode.lowLatency,
        // No withServices, no androidUsesFineLocation
      );

      await Future.delayed(const Duration(seconds: 7));
      await FlutterBluePlus.stopScan();

      print(
        '[BLE] Strategy 1 complete: Found $totalDeviceCount total devices, $vetsyncDeviceCount VetSync collars',
      );

      if (vetsyncDeviceCount > 0) {
        print('[BLE] ✅ SUCCESS with Strategy 1');
        print('[BLE] 📋 Collars in UI list: ${discoveredCollars.length}');
        // Don't change states - let UI show results
        isScanning.value = false;
        return;
      }

      // Reset counters for next strategy
      totalDeviceCount = 0;

      // STRATEGY 2: Scan with service filter but VERY long timeout
      print('[BLE] Strategy 2: Scanning WITH service filter (10 seconds)...');

      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        withServices: [Guid(AppConfig.collarServiceUuid)],
        androidScanMode: AndroidScanMode.lowLatency,
      );

      await Future.delayed(const Duration(seconds: 10));
      await FlutterBluePlus.stopScan();

      print(
        '[BLE] Strategy 2 complete: Found $totalDeviceCount total devices, $vetsyncDeviceCount VetSync collars',
      );

      if (vetsyncDeviceCount > 0) {
        print('[BLE] ✅ SUCCESS with Strategy 2');
        print('[BLE] 📋 Collars in UI list: ${discoveredCollars.length}');
        isScanning.value = false;
        return;
      }

      // Reset counters for next strategy
      totalDeviceCount = 0;

      // STRATEGY 3: Balanced mode (less aggressive power-wise)
      print('[BLE] Strategy 3: Scanning with BALANCED mode (7 seconds)...');

      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 7),
        androidScanMode: AndroidScanMode.balanced,
      );

      await Future.delayed(const Duration(seconds: 7));
      await FlutterBluePlus.stopScan();

      print(
        '[BLE] Strategy 3 complete: Found $totalDeviceCount total devices, $vetsyncDeviceCount VetSync collars',
      );

      if (vetsyncDeviceCount > 0) {
        print('[BLE] ✅ SUCCESS with Strategy 3');
        print('[BLE] 📋 Collars in UI list: ${discoveredCollars.length}');
      } else {
        print('[BLE] ❌ FAILED: No VetSync collars found after all strategies');
        print(
          '[BLE] Total BLE devices seen across all strategies: $totalDeviceCount',
        );
        if (totalDeviceCount == 0) {
          print('[BLE] ⚠️ NO BLE devices found at all - possible issues:');
          print('[BLE]    1. Bluetooth permissions not granted properly');
          print(
            '[BLE]    2. Location services disabled (required for BLE on Android)',
          );
          print(
            '[BLE]    3. Device BLE stack issue - try airplane mode toggle',
          );
          print('[BLE]    4. OxygenOS battery optimization blocking BLE');
        }
      }
    } catch (e) {
      print('[BLE] ❌ Error during aggressive scan: $e');
    } finally {
      isScanning.value = false;
      // Don't change connection state - let it stay as is
    }
  }

  /// Stop scanning
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    _scanSubscription?.cancel();
    isScanning.value = false;

    if (connectionState.value == BleConnectionState.scanning) {
      connectionState.value = BleConnectionState.disconnected;
    }
  }

  /// Process discovered device
  void _processDiscoveredDevice(ScanResult result) {
    print(
      '[BLE] 🔍 _processDiscoveredDevice called for: ${result.device.platformName}',
    );

    // Extract collar ID from advertisement data or device name
    final deviceName = result.device.platformName;
    if (!deviceName.startsWith('VetSync_')) {
      print('[BLE] ⏭️ Skipping non-VetSync device: $deviceName');
      return;
    }

    final collarId = deviceName.replaceFirst('VetSync_', '');
    print('[BLE] 🔄 Processing VetSync collar: $collarId');

    // Extract battery from manufacturer data if available
    int? batteryPercent;
    final manufacturerData = result.advertisementData.manufacturerData;
    if (manufacturerData.isNotEmpty) {
      final data = manufacturerData.values.first;
      if (data.length >= 1) {
        batteryPercent = data[0];
      }
    }

    final discovered = DiscoveredCollar(
      device: result.device,
      rssi: result.rssi,
      collarId: collarId,
      batteryPercent: batteryPercent,
    );

    // Update or add to list
    final existingIndex = discoveredCollars.indexWhere(
      (c) => c.collarId == collarId,
    );

    if (existingIndex >= 0) {
      print('[BLE] ✏️ Updated collar $collarId in list (RSSI: ${result.rssi})');
      discoveredCollars[existingIndex] = discovered;
    } else {
      print('[BLE] ➕ Added collar $collarId to list (RSSI: ${result.rssi})');
      discoveredCollars.add(discovered);
    }

    print('[BLE] 📋 Total collars in list: ${discoveredCollars.length}');

    // Sort by signal strength
    discoveredCollars.sort((a, b) => b.rssi.compareTo(a.rssi));
  }

  /// Connect to a collar
  Future<void> connect(DiscoveredCollar collar) async {
    if (connectionState.value == BleConnectionState.connected) {
      await disconnect();
    }

    connectionState.value = BleConnectionState.connecting;
    _shouldReconnect = true;
    _lastCollarId = collar.collarId;

    try {
      // Connect to device with platform-specific optimizations
      await collar.device.connect(
        timeout: AppConfig.bleConnectionTimeout,
        autoConnect: false, // Direct connection for faster pairing
        mtu: null, // Will negotiate after connection
      );

      print('[BLE] Platform: ${Platform.operatingSystem}');

      _connectedDevice = collar.device;

      // Discover services
      final services = await collar.device.discoverServices();

      // Find VetSync service (Nordic UART)
      final service = services.firstWhere(
        (s) =>
            s.uuid.toString().toLowerCase() ==
            AppConfig.collarServiceUuid.toLowerCase(),
        orElse: () => throw BleException('VetSync service not found'),
      );

      // Find characteristics
      for (final char in service.characteristics) {
        final uuid = char.uuid.toString().toLowerCase();
        if (uuid == AppConfig.dataCharUuid.toLowerCase()) {
          _dataCharacteristic = char; // TX (Notify)
        } else if (uuid == AppConfig.commandCharUuid.toLowerCase()) {
          _commandCharacteristic = char; // RX (Write)
        }
      }

      if (_dataCharacteristic == null || _commandCharacteristic == null) {
        throw BleException('Required characteristics not found');
      }

      // Subscribe to data/response notifications
      await _dataCharacteristic!.setNotifyValue(true);
      _dataSubscription = _dataCharacteristic!.onValueReceived.listen(
        _onDataReceived,
        onError: (error) {
          print('BLE data stream error: $error');
          // Attempt to recover from stream errors
          _onDisconnected();
        },
        cancelOnError: false,
      );

      // Listen for disconnection
      _connectionSubscription = collar.device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _onDisconnected();
        }
      });

      connectedCollar.value = collar;
      connectionState.value = BleConnectionState.connected;
      _reconnectAttempts = 0;
      print('✅ [BLE] Connected to collar: ${collar.collarId}');

      // Reset connection metrics
      _crcErrorCount = 0;
      _totalPacketCount = 0;

      // Reset algorithm state on new connection
      _bcgService.reset();

      // Reset stream parser
      _streamParser.reset();

      // === CONNECTIVITY OPTIMIZATIONS ===

      // 1. Request larger MTU for better throughput
      await _requestOptimalMtu(collar.device);

      // 2. Request connection priority for low latency
      await _requestConnectionPriority(collar.device);

      // 3. Monitor RSSI for connection quality
      _startRssiMonitoring(collar.device);

      // Start keep-alive timer (with grace period)
      _startKeepAlive();

      // Request initial status
      await requestStatus();

      // Small delay to let connection stabilize
      await Future.delayed(const Duration(milliseconds: 500));

      // Start data streaming from collar
      await sendCommand(CollarCommand.startStream());
      print('[BLE] 📡 Requested data stream start');

      // Don't set isDataStreaming optimistically - let first packet do it
      // The grace period will prevent false timeouts during initial setup
      _checkCompositeConnectionState();
    } catch (e) {
      connectionState.value = BleConnectionState.error;
      _connectedDevice = null;
      throw BleException('Failed to connect: ${e.toString()}');
    }
  }

  /// Start keep-alive timer to maintain connection (Watchdog)
  void _startKeepAlive() {
    _keepAliveTimer?.cancel();
    _lastDataReceived = DateTime.now();
    _connectionTime = DateTime.now();

    _keepAliveTimer = Timer.periodic(_keepAliveInterval, (timer) async {
      // If raw BLE is disconnected, stop logic
      if (connectionState.value != BleConnectionState.connected) {
        timer.cancel();
        return;
      }

      final now = DateTime.now();
      final timeSinceLastData = now.difference(_lastDataReceived!);
      final timeSinceConnection = now.difference(_connectionTime!);

      // Apply grace period - don't timeout during initial connection
      final isInGracePeriod =
          timeSinceConnection < _initialConnectionGracePeriod;

      // Check for data timeout (Data Watchdog)
      if (timeSinceLastData > _dataTimeout && !isInGracePeriod) {
        if (isDataStreaming.value) {
          print(
            '[BLE] Data timeout detected (${timeSinceLastData.inSeconds}s). No data received.',
          );
          isDataStreaming.value = false;
          _checkCompositeConnectionState();

          // Attempt recovery instead of immediate disconnect
          _attemptDataRecovery();
        }
        return;
      } else {
        // Data is flowing, ensure state is correct
        if (!isDataStreaming.value && !isInGracePeriod) {
          print(
            '[BLE] Data stream resumed after ${timeSinceLastData.inSeconds}s',
          );
          isDataStreaming.value = true;
          _checkCompositeConnectionState();
        }
      }

      // Send keep-alive status request (less frequently)
      // Only request battery if we're not getting regular data packets
      if (timeSinceLastData > const Duration(seconds: 5)) {
        try {
          await requestBattery();
          _keepAliveFailureCount = 0; // Reset on success
          // Only log occasionally to reduce spam
          if (DateTime.now().second % 60 == 0) {
            print('[BLE] Keep-alive OK');
          }
        } catch (e) {
          // Don't count keep-alive failures if data is still flowing
          if (timeSinceLastData < const Duration(seconds: 15)) {
            // Data is flowing, ignore battery request failure
            print(
              '[BLE] Battery request failed but data is flowing - ignoring',
            );
            _keepAliveFailureCount = 0;
          } else {
            _keepAliveFailureCount++;
            print(
              '[BLE] ⚠️ Keep-alive failed ($_keepAliveFailureCount/$_maxKeepAliveFailures): $e',
            );

            // If keep-alive fails repeatedly AND no data, trigger recovery
            if (_keepAliveFailureCount >= _maxKeepAliveFailures) {
              print(
                '[BLE] ❌ Keep-alive failed $_maxKeepAliveFailures times, attempting recovery...',
              );
              _keepAliveFailureCount = 0;
              await _attemptDataRecovery();
            }
          }
        }
      } else {
        // Data is flowing regularly, no need for battery requests
        _keepAliveFailureCount = 0;
      }
    });
  }

  /// Attempt data recovery without full disconnection
  Future<void> _attemptDataRecovery() async {
    print('[BLE] Attempting data recovery...');
    try {
      // Try re-enabling notifications
      if (_dataCharacteristic != null) {
        await _dataCharacteristic!.setNotifyValue(false);
        await Future.delayed(const Duration(milliseconds: 500));
        await _dataCharacteristic!.setNotifyValue(true);
        print('[BLE] Notifications re-enabled');

        // Resend start stream command
        await sendCommand(CollarCommand.startStream());
      }
    } catch (e) {
      print('[BLE] Data recovery failed: $e');
      // If recovery fails, trigger full reconnection logic
      _onDisconnected();
    }
  }

  /// Stop keep-alive timer
  void _stopKeepAlive() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = null;
    _lastDataReceived = null;
    _connectionTime = null;
    _keepAliveFailureCount = 0;
  }

  // ============================================================================
  // CONNECTIVITY OPTIMIZATION METHODS
  // ============================================================================

  /// Request optimal MTU size for better data throughput
  Future<void> _requestOptimalMtu(BluetoothDevice device) async {
    try {
      // Request optimal MTU based on config
      // iOS auto-negotiates, Android allows up to 517
      final mtu = await device.requestMtu(AppConfig.targetMtuSize);
      mtuSize.value = mtu;
      print(
        '[BLE] 📶 MTU negotiated: $mtu bytes (target: ${AppConfig.targetMtuSize})',
      );

      if (mtu < 100) {
        print('[BLE] ⚠️ MTU is low ($mtu bytes). Connection may be slower.');
      } else if (mtu >= AppConfig.targetMtuSize) {
        print('[BLE] ✅ Optimal MTU achieved for high-speed data transfer');
      }
    } catch (e) {
      print('[BLE] ⚠️ MTU request failed (using default): $e');
      // Not critical - connection will work with default MTU (23 bytes)
    }
  }

  /// Request high connection priority for low latency
  Future<void> _requestConnectionPriority(BluetoothDevice device) async {
    try {
      // Request high priority connection parameters
      // This reduces connection interval and latency (Android only, iOS ignores)
      await device.requestConnectionPriority(
        connectionPriorityRequest: ConnectionPriority.high,
      );
      print('[BLE] 🚀 Requested HIGH connection priority (low latency mode)');
    } catch (e) {
      print('[BLE] ⚠️ Connection priority request failed: $e');
      // Not critical - connection will work with default priority
    }
  }

  /// Monitor RSSI (signal strength) periodically
  Timer? _rssiTimer;
  void _startRssiMonitoring(BluetoothDevice device) {
    _rssiTimer?.cancel();

    // Read RSSI periodically to monitor connection quality
    _rssiTimer = Timer.periodic(AppConfig.rssiMonitorInterval, (timer) async {
      if (connectionState.value != BleConnectionState.connected) {
        timer.cancel();
        return;
      }

      try {
        final rssi = await device.readRssi();
        connectionRssi.value = rssi;

        // Log connection quality warnings based on thresholds
        if (rssi < AppConfig.minAcceptableRssi) {
          print(
            '[BLE] ⚠️ Weak signal: ${rssi}dBm (connection may be unstable)',
          );
        } else if (rssi > -70 && DateTime.now().second % 30 == 0) {
          // Log good signal occasionally
          print('[BLE] 📶 Signal strength: ${rssi}dBm (good)');
        }
      } catch (e) {
        // RSSI read can fail if connection is unstable
        print('[BLE] ⚠️ RSSI read failed: $e');
      }
    });
  }

  /// Stop RSSI monitoring
  void _stopRssiMonitoring() {
    _rssiTimer?.cancel();
    _rssiTimer = null;
    connectionRssi.value = 0;
  }

  /// Get connection quality percentage based on metrics
  int get connectionQuality {
    // Calculate quality from RSSI, CRC errors, and packet success rate
    int quality = 100;

    // RSSI component (0-50 points)
    final rssi = connectionRssi.value;
    if (rssi != 0) {
      if (rssi >= -70) {
        quality -= 0; // Excellent signal
      } else if (rssi >= -80) {
        quality -= 15; // Good signal
      } else if (rssi >= -90) {
        quality -= 30; // Fair signal
      } else {
        quality -= 50; // Poor signal
      }
    }

    // CRC error rate component (0-50 points)
    if (_totalPacketCount > 100) {
      final errorRate = _crcErrorCount / _totalPacketCount;
      if (errorRate > 0.1) {
        quality -= 50; // >10% errors = very poor
      } else if (errorRate > 0.05) {
        quality -= 30; // >5% errors = poor
      } else if (errorRate > 0.01) {
        quality -= 15; // >1% errors = fair
      }
    }

    return quality.clamp(0, 100);
  }

  /// Disconnect from current collar
  Future<void> disconnect() async {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _stopKeepAlive();
    _stopRssiMonitoring();

    await _dataSubscription?.cancel();
    await _connectionSubscription?.cancel();

    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.disconnect();
      } catch (e) {
        // Ignore disconnect errors
      }
    }

    _connectedDevice = null;
    _dataCharacteristic = null;
    _commandCharacteristic = null;
    connectedCollar.value = null;

    // Reset boot time tracking on disconnect (FIX 4)
    _hasRecordedBootTime = false;
    _collarBootTimeUtcMs = null;

    // Reset sequence tracking on disconnect (FIX 3.4)
    if (_totalPacketLoss > 0) {
      print('[BLE] 📊 Session packet loss summary: $_totalPacketLoss packets lost');
    }
    _packetSequenceNumber = 0;
    _lastSequenceNumber = -1;
    _totalPacketLoss = 0;

    connectionState.value = BleConnectionState.disconnected;
    isDataStreaming.value = false;

    // Reset battery smoothing
    _smoothedBattery = 100.0;
    _lastBatteryUpdate = null;
    batteryPercent.value = 100;

    // Reset stream parser
    _streamParser.reset();
  }

  /// Handle disconnection
  void _onDisconnected() {
    print('🔌 Disconnected from collar');
    connectionState.value = BleConnectionState.disconnected;
    _connectedDevice = null;

    if (_shouldReconnect &&
        _reconnectAttempts < AppConfig.maxReconnectAttempts) {
      print(
        '🔄 Starting reconnection attempt ${_reconnectAttempts + 1}/${AppConfig.maxReconnectAttempts}',
      );
      _startReconnect();
    } else if (_reconnectAttempts >= AppConfig.maxReconnectAttempts) {
      print('❌ Maximum reconnection attempts reached');
    }
  }

  /// Start reconnection attempts
  void _startReconnect() {
    connectionState.value = BleConnectionState.reconnecting;
    _reconnectAttempts++;

    _reconnectTimer = Timer(AppConfig.reconnectInterval, () async {
      if (!_shouldReconnect) return;

      try {
        // Try to find the collar again
        await startScan();
        await Future.delayed(const Duration(seconds: 3));
        await stopScan();

        final collar = discoveredCollars.firstWhereOrNull(
          (c) => c.collarId == _lastCollarId,
        );

        if (collar != null) {
          await connect(collar);
        } else if (_reconnectAttempts < AppConfig.maxReconnectAttempts) {
          _startReconnect();
        } else {
          connectionState.value = BleConnectionState.error;
        }
      } catch (e) {
        if (_reconnectAttempts < AppConfig.maxReconnectAttempts) {
          _startReconnect();
        } else {
          connectionState.value = BleConnectionState.error;
        }
      }
    });
  }

  /// Cancel reconnection
  void cancelReconnect() {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _reconnectAttempts = 0;
    connectionState.value = BleConnectionState.disconnected;
  }

  /// Get remaining reconnect attempts
  int get remainingReconnectAttempts {
    return AppConfig.maxReconnectAttempts - _reconnectAttempts;
  }

  /// Handle received data (Responses or Stream Packets)
  void _onDataReceived(List<int> data) {
    if (data.isEmpty) return;

    // Update last data received timestamp
    final now = DateTime.now();
    final timeSinceLastData = _lastDataReceived != null
        ? now.difference(_lastDataReceived!).inMilliseconds
        : 0;
    _lastDataReceived = now;

    // Mark data as streaming
    if (!isDataStreaming.value) {
      print(
        '[BLE] ✅ Data stream started/resumed (gap: ${timeSinceLastData}ms)',
      );
      isDataStreaming.value = true;
      _checkCompositeConnectionState();
    }

    // 🔥 NEW: Use stream parser to handle reassembly and array frames
    final parseResult = _streamParser.processData(data);

    // Log parser stats occasionally
    if (_packetCount % 100 == 0 && _packetCount > 0) {
      final stats = _streamParser.statistics;
      // debugPrint('[BLE] Parser stats: $stats');
    }

    // Handle responses
    for (final response in parseResult.responses) {
      _handleResponse(response);
    }

    // Handle data packets
    for (final packet in parseResult.packets) {
      // Track packet statistics for connection quality
      _totalPacketCount++;

      if (!packet.crcValid) {
        _crcErrorCount++;
        final errorRate = (_crcErrorCount / _totalPacketCount * 100)
            .toStringAsFixed(1);
        print(
          '⚠️ [BLE] CRC Error in packet (ts: ${packet.timestampUs}us) - Error rate: $errorRate%',
        );

        // Warn if error rate exceeds threshold
        if (_totalPacketCount > 50 &&
            _crcErrorCount / _totalPacketCount > AppConfig.maxCrcErrorRate) {
          print(
            '❌ [BLE] HIGH CRC error rate ($errorRate%) - connection quality degraded',
          );
        }
        continue; // Skip this packet
      }

      // Log first few packets for debugging
      _packetCount++;
      if (_packetCount <= 3) {
        print('[BLE] 📦 Packet #$_packetCount: ${packet.toString()}');
      }

      // Update local state with smoothing
      _updateBatterySmoothed(packet.batteryPercent, source: 'data_packet');

      // Feed to BCG Service
      _bcgService.onPacketReceived(packet);

      // Use BCG algorithm's signal quality (mode-independent) or packet quality as fallback
      // Note: packet.quality is 0 in HIGH-RES mode, so prefer BCG result
      final effectiveSignalQuality =
          _bcgService.latestResult?.signalQuality ??
          (packet.isStandardMode
              ? packet.quality
              : 50); // Default to 50 in HIGH-RES

      // Create legacy CollarDataPacket if needed for dataStream
      // We map the validated packet to the legacy DTO structure
      // FIX 3: Generate sequence number for Phase-1 safety packet loss detection
      _packetSequenceNumber++;

      // FIX 3.4: Detect sequence gaps for packet loss logging
      if (_lastSequenceNumber >= 0) {
        final expectedSequence = _lastSequenceNumber + 1;
        if (_packetSequenceNumber != expectedSequence) {
          final gap = _packetSequenceNumber - expectedSequence;
          _totalPacketLoss += gap;
          print('[BLE] ⚠️ Sequence gap detected! Expected: $expectedSequence, Got: $_packetSequenceNumber, Lost: $gap packets');
          print('[BLE] 📊 Total packet loss this session: $_totalPacketLoss');
        }
      }
      _lastSequenceNumber = _packetSequenceNumber;

      final legacyPacket = CollarDataPacket(
        packetType: packet.packetType,
        sequenceNumber: _packetSequenceNumber,
        timestampMs:
            packet.timestampUs ~/
            1000, // Convert us to ms for legacy compatibility
        heartRateBpm: _bcgService.latestResult?.heartRateBpm ?? 0,
        respiratoryRateBpm: _bcgService.latestResult?.respiratoryRateBpm ?? 0,
        temperatureC: packet.temperatureCelsius,
        batteryPercent: packet.batteryPercent,
        signalQuality: effectiveSignalQuality,
        pressureFiltered: packet.pressure,
        pressureRaw: packet.isHighResMode ? packet.pressure : null,
        // statusFlags: packet.statusFlags, // Not in legacy model
        // crc16: packet.crc16, // Not in legacy model constructor
        imuAccel: [packet.accelX, packet.accelY, packet.accelZ],
        imuGyro: [packet.gyroX, packet.gyroY, packet.gyroZ],
        receivedAt: packet.receivedAt,
      );

      // Track latest collar timestamp (FIX 2: Phase-1 safety)
      latestCollarTimestampMs.value = legacyPacket.timestampMs;

      // FIX 4: Capture collar boot time on first packet (Phase-1 safety)
      if (!_hasRecordedBootTime && legacyPacket.timestampMs > 0) {
        final now = DateTime.now();
        _collarBootTimeUtcMs = now.millisecondsSinceEpoch - legacyPacket.timestampMs;
        _hasRecordedBootTime = true;

        print('[BLE] 🕐 Collar boot time captured:');
        print('[BLE]   - First packet collar_ts: ${legacyPacket.timestampMs} ms');
        print('[BLE]   - Mobile UTC: ${now.millisecondsSinceEpoch} ms');
        print('[BLE]   - Calculated boot time: $_collarBootTimeUtcMs ms');

        // Notify listeners about boot time (will be picked up by session controller)
        onCollarBootTimeCalculated?.call(
          collarBootTimeUtcMs: _collarBootTimeUtcMs!,
          firstPacketCollarTs: legacyPacket.timestampMs,
          firstPacketMobileUtc: now.millisecondsSinceEpoch,
        );
      }

      // Emit raw packet to stream
      _dataController.add(legacyPacket);

      // 🔥 Send to websocket if connected (for laptop/backend streaming)
      if (_wsService?.isConnected == true) {
        _wsService!.sendCollarData(legacyPacket);
      }

      // 🔥 Send to dual upload service for batch cloud upload
      if (_dualUploadService != null) {
        _dualUploadService!.addCollarData(legacyPacket);
      }
    }
  }

  /// Handle parsed command response
  void _handleResponse(CollarResponse response) {
    if (response is DeviceInfoResponse) {
      print(
        '📱 Device Info: ${response.deviceId}, FW: ${response.firmwareVersion}, Battery: ${response.batteryPercent}%',
      );
      _updateBatterySmoothed(response.batteryPercent, source: 'device_info');
      // Update firmware version in connected collar object if possible
    } else if (response is BatteryResponse) {
      print(
        '🔋 Battery (raw response): ${response.batteryPercent}% ${response.isCharging ? "(Charging)" : ""}',
      );
      _updateBatterySmoothed(response.batteryPercent, source: 'battery_cmd');
    } else if (response is ModeSwitchResponse) {
      if (response.success) {
        print(
          '✅ Mode switched to: 0x${response.currentMode.toRadixString(16)}',
        );
        // Update local mode state
        // Note: Mode from response is 0x01/0x02, FirmwareMode enum need mapping
      } else {
        print('❌ Mode switch failed');
      }
    } else if (response is AckResponse) {
      print('✓ ACK received');
    }
  }

  /// Send command to collar
  Future<void> sendCommand(
    CollarCommand command, {
    Duration timeout = const Duration(seconds: 5),
    bool waitForResponse = false,
  }) async {
    if (_commandCharacteristic == null) {
      throw BleException(
        'Not connected or command characteristic not available',
      );
    }

    try {
      print(
        '[BLE] 📤 Sending command (timeout: ${timeout.inSeconds}s, waitForResponse: $waitForResponse)...',
      );

      if (waitForResponse) {
        // Wait for acknowledgment with timeout
        await _commandCharacteristic!
            .write(command.toBytes(), withoutResponse: false)
            .timeout(
              timeout,
              onTimeout: () {
                throw BleException(
                  'Command write timeout after ${timeout.inSeconds}s',
                );
              },
            );
      } else {
        // Fire-and-forget - don't wait for ACK
        await _commandCharacteristic!.write(
          command.toBytes(),
          withoutResponse: true,
        );
      }

      print('[BLE] ✅ Command sent successfully');
    } catch (e) {
      print('[BLE] ❌ Command send failed: $e');
      rethrow;
    }
  }

  /// Switch firmware mode
  Future<void> switchMode(FirmwareMode targetMode, {int sessionId = 0}) async {
    // Notify BCG service about mode change
    // Map enum to protocol value (0x01 = STANDARD, 0x02 = HIGH-RES/RAW)
    final modeValue = targetMode == FirmwareMode.raw ? 0x02 : 0x01;

    print(
      '[BLE] 🔄 Switching mode to: ${targetMode == FirmwareMode.raw ? "RAW/HIGH-RES" : "STANDARD"}',
    );

    _bcgService.onModeChange(modeValue);

    final command = CollarCommand.switchMode(targetMode: modeValue);

    // Mode switch: collar doesn't send ACK, so use fire-and-forget
    // We'll verify success by monitoring data stream for mode change
    await sendCommand(command, waitForResponse: false);

    // Optimistically update mode
    currentMode.value = targetMode;
    print('[BLE] ✅ Mode switch command sent (fire-and-forget)');
  }

  /// Request status from collar
  Future<void> requestStatus() async {
    await sendCommand(CollarCommand.getInfo());
  }

  /// Request battery status
  Future<void> requestBattery() async {
    try {
      await sendCommand(CollarCommand.getBattery());
    } catch (e) {
      // Only rethrow if it's a critical connection error
      // Battery info will be updated from data packets anyway
      if (connectionState.value != BleConnectionState.connected) {
        rethrow; // Connection lost, propagate error
      }
      // Otherwise, log but don't fail - battery updates come from data packets
      debugPrint('[BLE] Battery request error (non-critical): $e');
    }
  }

  /// Sync time with collar (Not supported in new protocol yet, placeholder)
  Future<void> syncTime() async {
    // final command = CollarCommand.setTime();
    // await sendCommand(command);
  }

  /// Check if fully connected (Legacy getter replacement)
  // bool get isConnected => connectionState.value == BleConnectionState.connected;
  // Use the observable `isConnected` directly for composite state

  /// Get connected collar ID
  String? get connectedCollarId => connectedCollar.value?.collarId;

  @override
  void onClose() {
    _dataController.close();
    _vitalsController.close();
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    _dataSubscription?.cancel();
    _reconnectTimer?.cancel();
    _stopKeepAlive();
    disconnect();
    super.onClose();
  }
}

/// BLE exception
class BleException implements Exception {
  final String message;
  BleException(this.message);

  @override
  String toString() => message;
}
