import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/constants/app_config.dart';
import '../../services/bcg_service.dart';
import '../models/models.dart';
import '../models/collar_protocol.dart';

import '../models/collar_packet_validated.dart' as validated;

/// BLE service for collar communication
class BleService extends GetxService {
  // Connection state
  final Rx<BleConnectionState> connectionState =
      BleConnectionState.disconnected.obs;

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

  // Battery updates
  final RxInt batteryPercent = 100.obs;

  // Signal quality
  final RxInt signalQuality = 100.obs;

  // Current mode
  final Rx<FirmwareMode> currentMode = FirmwareMode.filtered.obs;

  // Reconnection
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  bool _shouldReconnect = false;
  String? _lastCollarId;

  // Keep-alive mechanism
  Timer? _keepAliveTimer;
  DateTime? _lastDataReceived;
  static const Duration _keepAliveInterval = Duration(seconds: 15);
  static const Duration _dataTimeout = Duration(seconds: 10);

  // Scan results
  final RxList<DiscoveredCollar> discoveredCollars = <DiscoveredCollar>[].obs;
  final RxBool isScanning = false.obs;

  // Stream subscriptions
  StreamSubscription? _scanSubscription;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _dataSubscription;

  // Algorithm instance for data processing refactored to Service
  // Use BcgService to handle buffering, mode switching and processing
  final BcgService _bcgService = BcgService();
  BcgService get bcgService => _bcgService; // Expose for UI access

  @override
  void onInit() {
    super.onInit();
    _initBle();
  }

  Future<void> _initBle() async {
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
  }

  /// Handle BCG Service updates
  void _onBcgUpdate() {
    final result = _bcgService.latestResult;
    if (result == null) return;

    // Create vitals from BCG result
    final vitals = Vitals(
      heartRateBpm: result.heartRateBpm,
      respiratoryRateBpm: result.respiratoryRateBpm,
      temperatureC: _bcgService.temperatureCelsius,
      signalQuality: result.signalQuality,
      timestamp: DateTime.now().toUtc(),
    );

    // Update local state helpers
    if (result.isValid) {
      signalQuality.value = result.signalQuality;
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

  /// Start scanning for collars
  Future<void> startScan() async {
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

    // Clear previous results
    discoveredCollars.clear();
    isScanning.value = true;
    connectionState.value = BleConnectionState.scanning;

    // Start scan
    await FlutterBluePlus.startScan(
      timeout: AppConfig.bleScanTimeout,
      withServices: [Guid(AppConfig.collarServiceUuid)],
    );

    // Listen to scan results
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (final result in results) {
        _processDiscoveredDevice(result);
      }
    });

    // Auto-stop after timeout
    Future.delayed(AppConfig.bleScanTimeout, () {
      stopScan();
    });
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
    // Extract collar ID from advertisement data or device name
    final deviceName = result.device.platformName;
    if (!deviceName.startsWith('VetSync_')) return;

    final collarId = deviceName.replaceFirst('VetSync_', '');

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
      discoveredCollars[existingIndex] = discovered;
    } else {
      discoveredCollars.add(discovered);
    }

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
      // Connect to device
      await collar.device.connect(
        timeout: AppConfig.bleConnectionTimeout,
        autoConnect: false,
      );

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
      print('✅ Connected to collar: ${collar.collarId}');

      // Reset algorithm state on new connection
      _bcgService.reset();

      // Request initial status
      await requestStatus();

      // Start data streaming from collar
      await sendCommand(CollarCommand.startStream());
      print('Started data streaming from collar');

      // Start keep-alive timer
      _startKeepAlive();
    } catch (e) {
      connectionState.value = BleConnectionState.error;
      _connectedDevice = null;
      throw BleException('Failed to connect: ${e.toString()}');
    }
  }

  /// Start keep-alive timer to maintain connection
  void _startKeepAlive() {
    _keepAliveTimer?.cancel();
    _lastDataReceived = DateTime.now();

    _keepAliveTimer = Timer.periodic(_keepAliveInterval, (timer) async {
      if (!isConnected) {
        timer.cancel();
        return;
      }

      final timeSinceLastData = DateTime.now().difference(_lastDataReceived!);

      // Check for data timeout
      if (timeSinceLastData > _dataTimeout) {
        print(
          'Data timeout detected (${timeSinceLastData.inSeconds}s). No data received.',
        );
        // Connection might be stale, trigger reconnection
        _onDisconnected();
        return;
      }

      // Send keep-alive status request
      try {
        await requestBattery();
        print(
          'Keep-alive ping sent (last data: ${timeSinceLastData.inSeconds}s ago)',
        );
      } catch (e) {
        print('Keep-alive failed: $e');
        _onDisconnected();
      }
    });
  }

  /// Stop keep-alive timer
  void _stopKeepAlive() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = null;
    _lastDataReceived = null;
  }

  /// Disconnect from current collar
  Future<void> disconnect() async {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _stopKeepAlive();

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
    connectionState.value = BleConnectionState.disconnected;
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
    _lastDataReceived = DateTime.now();

    final bytes = Uint8List.fromList(data);

    // Try to parse as a command response first
    final response = CollarResponse.fromBytes(bytes);
    if (response != null) {
      _handleResponse(response);
      return;
    }

    // If not a response, assume it's a data packet
    try {
      // Parse with validated packet parser
      // Don't throw on CRC error here to prevent crashing stream, just ignore
      // In production you might want to log this
      final packet = validated.CollarPacket.fromBytes(
        bytes,
        throwOnCrcError: false,
      );

      if (!packet.crcValid) {
        print(
          '⚠️ CRC Error detected in data packet (timestamp: ${packet.timestampMs})',
        );
        // Track CRC error rate to detect connection quality issues
        return;
      }

      // Update local state
      batteryPercent.value = packet.batteryPercent;

      // Feed to BCG Service
      _bcgService.onPacketReceived(packet);

      // Create legacy CollarDataPacket if needed for dataStream
      // We map the validated packet to the legacy DTO structure
      final legacyPacket = CollarDataPacket(
        packetType: packet.packetType,
        sequenceNumber:
            0, // Not available in new validated packet structure yet
        timestampMs: packet.timestampMs,
        heartRateBpm: _bcgService.latestResult?.heartRateBpm ?? 0,
        respiratoryRateBpm: _bcgService.latestResult?.respiratoryRateBpm ?? 0,
        temperatureC: packet.temperatureCelsius,
        batteryPercent: packet.batteryPercent,
        signalQuality: packet.quality,
        pressureFiltered: packet.pressure,
        pressureRaw: packet.isHighResMode ? packet.pressure : null,
        // statusFlags: packet.statusFlags, // Not in legacy model
        // crc16: packet.crc16, // Not in legacy model constructor
        imuAccel: [packet.accelX, packet.accelY, packet.accelZ],
        imuGyro: [packet.gyroX, packet.gyroY, packet.gyroZ],
        receivedAt: packet.receivedAt,
      );

      // Emit raw packet to stream
      _dataController.add(legacyPacket);
    } catch (e) {
      print('⚠️ Error parsing data packet: $e');
      print(
        '   Raw bytes: ${bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
      );
    }
  }

  /// Handle parsed command response
  void _handleResponse(CollarResponse response) {
    if (response is DeviceInfoResponse) {
      print(
        '📱 Device Info: ${response.deviceId}, FW: ${response.firmwareVersion}, Battery: ${response.batteryPercent}%',
      );
      batteryPercent.value = response.batteryPercent;
      // Update firmware version in connected collar object if possible
    } else if (response is BatteryResponse) {
      print(
        '🔋 Battery: ${response.batteryPercent}% ${response.isCharging ? "(Charging)" : ""}',
      );
      batteryPercent.value = response.batteryPercent;
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
  Future<void> sendCommand(CollarCommand command) async {
    if (_commandCharacteristic == null) {
      throw BleException(
        'Not connected or command characteristic not available',
      );
    }

    await _commandCharacteristic!.write(
      command.toBytes(),
      withoutResponse: false,
    );
  }

  /// Switch firmware mode
  Future<void> switchMode(FirmwareMode targetMode, {int sessionId = 0}) async {
    // Notify BCG service about mode change
    // Map enum to protocol value (0x01 = STANDARD, 0x02 = HIGH-RES/RAW)
    final modeValue = targetMode == FirmwareMode.raw ? 0x02 : 0x01;

    _bcgService.onModeChange(modeValue);

    final command = CollarCommand.switchMode(targetMode: modeValue);
    await sendCommand(command);

    // Optimistically update mode
    currentMode.value = targetMode;
  }

  /// Request status from collar
  Future<void> requestStatus() async {
    await sendCommand(CollarCommand.getInfo());
  }

  /// Request battery status
  Future<void> requestBattery() async {
    await sendCommand(CollarCommand.getBattery());
  }

  /// Sync time with collar (Not supported in new protocol yet, placeholder)
  Future<void> syncTime() async {
    // final command = CollarCommand.setTime();
    // await sendCommand(command);
  }

  /// Check if connected
  bool get isConnected => connectionState.value == BleConnectionState.connected;

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
