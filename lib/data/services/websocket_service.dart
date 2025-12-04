import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../core/constants/app_config.dart';
import '../models/models.dart';
import 'storage_service.dart';

/// WebSocket service for real-time communication with laptop
class WebSocketService extends GetxService {
  final StorageService _storage = Get.find<StorageService>();
  
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  
  // Connection state
  final Rx<WebSocketState> connectionState = WebSocketState.disconnected.obs;
  
  // Session info
  String? _sessionId;
  String? _laptopUrl;
  
  // Message streams
  final _messageController = StreamController<WebSocketMessage>.broadcast();
  Stream<WebSocketMessage> get messageStream => _messageController.stream;
  
  // Callbacks
  Function(String)? onCalibrationProgress;
  Function(Map<String, dynamic>)? onCalibrationComplete;
  Function(String)? onLaptopCommand;
  
  /// Connect to cloud relay server
  Future<void> connectToRelay({
    required String sessionId,
  }) async {
    if (connectionState.value == WebSocketState.connected) {
      await disconnect();
    }
    
    _sessionId = sessionId;
    connectionState.value = WebSocketState.connecting;
    
    try {
      final token = await _storage.getAccessToken();
      
      // Connect to cloud relay WebSocket
      final uri = Uri.parse('${AppConfig.wsUrl}/session/$sessionId');
      
      _channel = WebSocketChannel.connect(
        uri,
        protocols: ['vetsync-v1'],
      );
      
      // Send auth message
      _sendJson({
        'type': 'auth',
        'token': token,
        'client_type': 'mobile',
      });
      
      // Listen for messages
      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );
      
      // Start ping timer
      _startPingTimer();
      
      connectionState.value = WebSocketState.connected;
      
    } catch (e) {
      connectionState.value = WebSocketState.error;
      throw WebSocketException('Failed to connect: ${e.toString()}');
    }
  }
  
  /// Connect directly to laptop (local network)
  Future<void> connectToLaptop({
    required String laptopUrl,
    required String sessionId,
  }) async {
    if (connectionState.value == WebSocketState.connected) {
      await disconnect();
    }
    
    _sessionId = sessionId;
    _laptopUrl = laptopUrl;
    connectionState.value = WebSocketState.connecting;
    
    try {
      final uri = Uri.parse('$laptopUrl/ws/session/$sessionId');
      
      _channel = WebSocketChannel.connect(uri);
      
      // Listen for messages
      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );
      
      // Start ping timer
      _startPingTimer();
      
      connectionState.value = WebSocketState.connected;
      
    } catch (e) {
      connectionState.value = WebSocketState.error;
      throw WebSocketException('Failed to connect to laptop: ${e.toString()}');
    }
  }
  
  /// Disconnect
  Future<void> disconnect() async {
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    await _subscription?.cancel();
    await _channel?.sink.close();
    
    _channel = null;
    _sessionId = null;
    _laptopUrl = null;
    connectionState.value = WebSocketState.disconnected;
  }
  
  /// Handle incoming message
  void _onMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      final type = data['type'] as String?;
      
      final wsMessage = WebSocketMessage.fromJson(data);
      _messageController.add(wsMessage);
      
      switch (type) {
        case 'calibration_progress':
          final progress = data['progress'] as String? ?? '';
          onCalibrationProgress?.call(progress);
          break;
          
        case 'calibration_complete':
          onCalibrationComplete?.call(data);
          break;
          
        case 'command':
          final command = data['command'] as String? ?? '';
          onLaptopCommand?.call(command);
          break;
          
        case 'pong':
          // Keep-alive response
          break;
          
        case 'error':
          print('WebSocket error: ${data['message']}');
          break;
      }
    } catch (e) {
      print('Error parsing WebSocket message: $e');
    }
  }
  
  /// Handle error
  void _onError(dynamic error) {
    print('WebSocket error: $error');
    connectionState.value = WebSocketState.error;
    _startReconnect();
  }
  
  /// Handle connection closed
  void _onDone() {
    connectionState.value = WebSocketState.disconnected;
    _pingTimer?.cancel();
    
    // Attempt reconnect if we have session info
    if (_sessionId != null) {
      _startReconnect();
    }
  }
  
  /// Start ping timer
  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (connectionState.value == WebSocketState.connected) {
        _sendJson({'type': 'ping'});
      }
    });
  }
  
  /// Start reconnection
  void _startReconnect() {
    if (connectionState.value == WebSocketState.reconnecting) return;
    
    connectionState.value = WebSocketState.reconnecting;
    
    _reconnectTimer = Timer(const Duration(seconds: 5), () async {
      try {
        if (_laptopUrl != null) {
          await connectToLaptop(
            laptopUrl: _laptopUrl!,
            sessionId: _sessionId!,
          );
        } else if (_sessionId != null) {
          await connectToRelay(sessionId: _sessionId!);
        }
      } catch (e) {
        _startReconnect();
      }
    });
  }
  
  /// Send JSON message
  void _sendJson(Map<String, dynamic> data) {
    if (_channel == null) return;
    _channel!.sink.add(jsonEncode(data));
  }
  
  /// Send collar data to laptop
  void sendCollarData(CollarDataPacket packet) {
    if (connectionState.value != WebSocketState.connected) return;
    
    _sendJson({
      'type': 'collar_data',
      'session_id': _sessionId,
      'timestamp': DateTime.now().toIso8601String(),
      'packet_type': packet.packetType,
      'sequence': packet.sequenceNumber,
      'timestamp_ms': packet.timestampMs,
      'pressure_raw': packet.pressureRaw,
      'pressure_filtered': packet.pressureFiltered,
      'temperature_c': packet.temperatureC,
      'battery_percent': packet.batteryPercent,
      'signal_quality': packet.signalQuality,
      'imu_accel': packet.imuAccel,
      'imu_gyro': packet.imuGyro,
    });
  }
  
  /// Send session phase change
  void sendPhaseChange(SessionPhase phase) {
    if (connectionState.value != WebSocketState.connected) return;
    
    _sendJson({
      'type': 'phase_change',
      'session_id': _sessionId,
      'phase': phase.value,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  /// Send annotation
  void sendAnnotation(Annotation annotation) {
    if (connectionState.value != WebSocketState.connected) return;
    
    _sendJson({
      'type': 'annotation',
      'session_id': _sessionId,
      ...annotation.toJson(),
    });
  }
  
  /// Request calibration start
  void requestCalibrationStart() {
    if (connectionState.value != WebSocketState.connected) return;
    
    _sendJson({
      'type': 'calibration_request',
      'action': 'start',
      'session_id': _sessionId,
    });
  }
  
  /// Check if connected
  bool get isConnected => connectionState.value == WebSocketState.connected;
  
  @override
  void onClose() {
    _messageController.close();
    disconnect();
    super.onClose();
  }
}

/// WebSocket message model
class WebSocketMessage {
  final String type;
  final Map<String, dynamic> data;
  final DateTime receivedAt;
  
  WebSocketMessage({
    required this.type,
    required this.data,
    DateTime? receivedAt,
  }) : receivedAt = receivedAt ?? DateTime.now();
  
  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketMessage(
      type: json['type'] as String? ?? 'unknown',
      data: json,
    );
  }
}

/// WebSocket exception
class WebSocketException implements Exception {
  final String message;
  WebSocketException(this.message);
  
  @override
  String toString() => message;
}
