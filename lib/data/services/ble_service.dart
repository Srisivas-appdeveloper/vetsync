import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/constants/app_config.dart';
import '../models/models.dart';

/// BLE service for collar communication
class BleService extends GetxService {
  // Connection state
  final Rx<BleConnectionState> connectionState =
      BleConnectionState.disconnected.obs;

  // Connected device
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _dataCharacteristic;
  BluetoothCharacteristic? _commandCharacteristic;
  BluetoothCharacteristic? _batteryCharacteristic;

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

  // Scan results
  final RxList<DiscoveredCollar> discoveredCollars = <DiscoveredCollar>[].obs;
  final RxBool isScanning = false.obs;

  // Stream subscriptions
  StreamSubscription? _scanSubscription;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _dataSubscription;

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
      }
    });
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
    if (!deviceName.startsWith('VetSync-')) return;

    final collarId = deviceName.replaceFirst('VetSync-', '');

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

      // Find VetSync service
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
          _dataCharacteristic = char;
        } else if (uuid == AppConfig.commandCharUuid.toLowerCase()) {
          _commandCharacteristic = char;
        } else if (uuid == AppConfig.batteryCharUuid.toLowerCase()) {
          _batteryCharacteristic = char;
        }
      }

      if (_dataCharacteristic == null) {
        throw BleException('Data characteristic not found');
      }

      // Subscribe to data notifications
      await _dataCharacteristic!.setNotifyValue(true);
      _dataSubscription = _dataCharacteristic!.lastValueStream.listen(
        _onDataReceived,
      );

      // Subscribe to battery notifications if available
      if (_batteryCharacteristic != null) {
        await _batteryCharacteristic!.setNotifyValue(true);
        _batteryCharacteristic!.lastValueStream.listen(_onBatteryUpdate);
      }

      // Listen for disconnection
      _connectionSubscription = collar.device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _onDisconnected();
        }
      });

      connectedCollar.value = collar;
      connectionState.value = BleConnectionState.connected;
      _reconnectAttempts = 0;

      // Request initial status
      await requestStatus();
    } catch (e) {
      connectionState.value = BleConnectionState.error;
      _connectedDevice = null;
      throw BleException('Failed to connect: ${e.toString()}');
    }
  }

  /// Disconnect from current collar
  Future<void> disconnect() async {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();

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
    _batteryCharacteristic = null;
    connectedCollar.value = null;
    connectionState.value = BleConnectionState.disconnected;
  }

  /// Handle disconnection
  void _onDisconnected() {
    connectionState.value = BleConnectionState.disconnected;
    _connectedDevice = null;

    if (_shouldReconnect &&
        _reconnectAttempts < AppConfig.maxReconnectAttempts) {
      _startReconnect();
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

  /// Handle received data
  void _onDataReceived(List<int> data) {
    if (data.isEmpty) return;

    try {
      final packet = CollarDataPacket.fromBytes(Uint8List.fromList(data));

      // Update local state
      batteryPercent.value = packet.batteryPercent;
      signalQuality.value = packet.signalQuality;
      currentMode.value = packet.mode;

      // Emit raw packet to stream
      _dataController.add(packet);

      // Convert to vitals and emit
      final vitals = Vitals(
        heartRateBpm: packet.heartRateBpm ?? 0,
        respiratoryRateBpm: packet.respiratoryRateBpm ?? 0,
        temperatureC: packet.temperatureC,
        signalQuality: packet.signalQuality,
        timestamp: DateTime.now().toUtc(),
        // source: VitalsSource.collar,
      );
      _vitalsController.add(vitals);
    } catch (e) {
      print('Error parsing packet: $e');
    }
  }

  /// Handle battery update
  void _onBatteryUpdate(List<int> data) {
    if (data.isNotEmpty) {
      batteryPercent.value = data[0];
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
    final command = CollarCommand.switchMode(
      targetMode: targetMode,
      sessionId: sessionId,
    );
    await sendCommand(command);

    // Wait for mode to change
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Request status from collar
  Future<void> requestStatus() async {
    final command = CollarCommand.requestStatus();
    await sendCommand(command);
  }

  /// Sync time with collar
  Future<void> syncTime() async {
    final command = CollarCommand.setTime();
    await sendCommand(command);
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

// class CollarCommand {
//   /// Build mode switch command (9 bytes)
//   static Uint8List switchMode({
//     required int targetMode, // 0x01 = FILTERED, 0x02 = RAW
//     required String sessionId,
//   }) {
//     final bytes = Uint8List(9);
//     final data = ByteData.view(bytes.buffer);
    
//     // Command ID
//     data.setUint8(0, BlePacketTypes.cmdSwitchMode); // 0x10
    
//     // Target mode
//     data.setUint8(1, targetMode);
    
//     // Timestamp (milliseconds since epoch, truncated)
//     final timestamp = DateTime.now().millisecondsSinceEpoch;
//     data.setUint32(2, timestamp & 0xFFFFFFFF, Endian.little);
    
//     // Session ID (first 16 bits of UUID hash)
//     final sessionIdHash = sessionId.hashCode & 0xFFFF;
//     data.setUint16(6, sessionIdHash, Endian.little);
    
//     // XOR checksum
//     int checksum = 0;
//     for (int i = 0; i < 8; i++) {
//       checksum ^= bytes[i];
//     }
//     data.setUint8(8, checksum);
    
//     return bytes;
//   }
// }
