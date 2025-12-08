/// Application configuration constants
class AppConfig {
  AppConfig._();

  // App Info
  static const String appName = 'VetSync Clinical';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  // API Configuration

  static const String baseUrl = 'https://api.snoots.in';
  static const String wsUrl = 'wss://api.vetsync.com/ws';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;

  // BLE Configuration
  static const String collarServiceUuid =
      '6E400001-B5A3-F393-E0A9-E50E24DCCA9E';
  static const String commandCharUuid =
      '6E400002-B5A3-F393-E0A9-E50E24DCCA9E'; // RX (Write)
  static const String dataCharUuid =
      '6E400003-B5A3-F393-E0A9-E50E24DCCA9E'; // TX (Notify)

  // BLE Scan Configuration
  static const Duration bleScanTimeout = Duration(seconds: 10);
  static const Duration bleConnectionTimeout = Duration(seconds: 15);

  // Reconnection Configuration
  static const int maxReconnectAttempts = 12;
  static const Duration reconnectInterval = Duration(seconds: 5);

  // Session Configuration
  static const Duration sessionTimeout = Duration(hours: 8);
  static const int baselineDurationSeconds = 300; // 5 minutes
  static const int minimumBaselineQuality = 60;

  // Data Collection
  static const int filteredSampleRate = 100; // Hz
  static const int rawSampleRate = 128; // Hz
  static const int ecgSampleRate = 1000; // Hz
  static const int waveformBufferSeconds = 60;

  // Quality Thresholds
  static const int qualityExcellent = 75;
  static const int qualityFair = 50;
  static const int qualityPoor = 25;

  // Battery Thresholds
  static const int batteryWarning = 35;
  static const int batteryLow = 20;
  static const int batteryCritical = 10;
  static const int batteryEmergency = 5;

  // Photo/Media
  static const int maxPhotosPerSession = 50;
  static const int maxVoiceNoteDuration = 120; // seconds
  static const int photoMaxWidth = 1920;
  static const int photoQuality = 85;

  // Offline/Sync
  static const Duration autoSyncInterval = Duration(minutes: 5);
  static const int maxSyncRetries = 5;
  static const int syncBatchSize = 100;

  // Cache
  static const Duration cacheExpiry = Duration(hours: 24);
  static const int maxRecentAnimals = 10;
}

/// Storage keys for secure storage and preferences
class StorageKeys {
  StorageKeys._();

  // Auth
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String tokenExpiry = 'token_expiry';
  static const String observerId = 'observer_id';
  static const String observerName = 'observer_name';
  static const String clinicId = 'clinic_id';
  static const String clinicName = 'clinic_name';

  // Session
  static const String activeSessionId = 'active_session_id';
  static const String lastCollarId = 'last_collar_id';

  // Preferences
  static const String biometricsEnabled = 'biometrics_enabled';
  static const String voiceNoteMode = 'voice_note_mode';
  static const String darkMode = 'dark_mode';

  // Device
  static const String deviceId = 'device_id';
  static const String fcmToken = 'fcm_token';
}

/// API endpoint paths
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refresh = '/auth/refresh';
  static const String profile = '/auth/profile';

  // Animals
  static const String animals = '/animal/';
  static String animal(String id) => '/animal/$id';
  static const String searchAnimals = '/animal/search';
  static const String recentAnimals = '/animal/';

  // Collars
  static const String collars = '/collars';
  static String collar(String id) => '/collars/$id';
  static String collarStatus(String id) => '/collars/$id/status';

  // Sessions
  static const String sessions = '/sessions';
  static String session(String id) => '/sessions/$id';
  static String sessionPhase(String id) => '/sessions/$id/phase';
  static String sessionBaseline(String id) => '/sessions/$id/baseline';
  static String sessionAnnotations(String id) => '/sessions/$id/annotations';
  static String sessionVitals(String id) => '/sessions/$id/vitals';
  static String sessionVitalsBatch(String id) => '/sessions/$id/vitals/batch';
  static String sessionJoinCode(String id) => '/sessions/$id/join-code';
  static String sessionCollar(String id) => '/sessions/$id/collar';
  static const String joinSession = '/sessions/join';

  // Annotations
  static const String annotations = '/annotations';
  static String annotation(String id) => '/annotations/$id';

  // Calibration
  static const String calibrations = '/calibrations';
  static String calibration(String id) => '/calibrations/$id';

  // Upload
  static const String uploadPresigned = '/upload/presigned';
  static const String uploadPhoto = '/upload/photo';
  static const String uploadVoiceNote = '/upload/voice-note';

  // Dashboard
  static const String dashboardStats = '/dashboard/stats';
  static const String dashboardToday = '/dashboard/today';

  // ============ ADD THESE MISSING ENDPOINTS ============

  /// Get vitals with time range query
  /// Usage: GET /sessions/{id}/vitals?start=...&end=...&downsample=10s
  static String sessionVitalsRange(String id) => '/sessions/$id/vitals';

  /// Get latest vitals for session
  static String sessionVitalsLatest(String id) => '/sessions/$id/vitals/latest';

  /// End session
  static String sessionEnd(String id) => '/sessions/$id/end';

  /// Download calibration package
  static String calibrationPackage(String id) => '/calibrations/$id/package';

  /// Deploy calibration to devices
  static String calibrationDeploy(String id) => '/calibrations/$id/deploy';

  /// Get session QR code
  static String sessionQrCode(String id) => '/sessions/$id/qr';
}
