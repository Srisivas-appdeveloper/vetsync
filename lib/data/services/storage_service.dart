import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../core/constants/app_config.dart';

/// Secure storage service for sensitive data
class StorageService extends GetxService {
  late FlutterSecureStorage _storage;

  /// Initialize the service
  Future<StorageService> init() async {
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    );
    return this;
  }

  // ============================================================
  // Generic methods
  // ============================================================

  /// Write a string value
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Read a string value
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  /// Delete a value
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// Check if key exists
  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  /// Delete all stored values
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  // ============================================================
  // Auth tokens
  // ============================================================

  /// Store access token
  Future<void> setAccessToken(String token) async {
    await write(StorageKeys.accessToken, token);
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return await read(StorageKeys.accessToken);
  }

  /// Store refresh token
  Future<void> setRefreshToken(String token) async {
    await write(StorageKeys.refreshToken, token);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await read(StorageKeys.refreshToken);
  }

  /// Store token expiry
  Future<void> setTokenExpiry(DateTime expiry) async {
    await write(StorageKeys.tokenExpiry, expiry.toIso8601String());
  }

  /// Get token expiry
  Future<DateTime?> getTokenExpiry() async {
    final value = await read(StorageKeys.tokenExpiry);
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  /// Clear all auth data
  Future<void> clearAuth() async {
    await delete(StorageKeys.accessToken);
    await delete(StorageKeys.refreshToken);
    await delete(StorageKeys.tokenExpiry);
    await delete(StorageKeys.observerId);
    await delete(StorageKeys.observerName);
    await delete(StorageKeys.clinicId);
    await delete(StorageKeys.clinicName);
  }

  // ============================================================
  // Observer info
  // ============================================================

  /// Store observer ID
  Future<void> setObserverId(String id) async {
    await write(StorageKeys.observerId, id);
  }

  /// Get observer ID
  Future<String?> getObserverId() async {
    return await read(StorageKeys.observerId);
  }

  /// Store observer name
  Future<void> setObserverName(String name) async {
    await write(StorageKeys.observerName, name);
  }

  /// Get observer name
  Future<String?> getObserverName() async {
    return await read(StorageKeys.observerName);
  }

  /// Store clinic ID
  Future<void> setClinicId(String id) async {
    await write(StorageKeys.clinicId, id);
  }

  /// Get clinic ID
  Future<String?> getClinicId() async {
    return await read(StorageKeys.clinicId);
  }

  /// Store clinic name
  Future<void> setClinicName(String name) async {
    await write(StorageKeys.clinicName, name);
  }

  /// Get clinic name
  Future<String?> getClinicName() async {
    return await read(StorageKeys.clinicName);
  }

  // ============================================================
  // Session
  // ============================================================

  /// Store active session ID
  Future<void> setActiveSessionId(String? id) async {
    if (id == null) {
      await delete(StorageKeys.activeSessionId);
    } else {
      await write(StorageKeys.activeSessionId, id);
    }
  }

  /// Get active session ID
  Future<String?> getActiveSessionId() async {
    return await read(StorageKeys.activeSessionId);
  }

  /// Store last collar ID
  Future<void> setLastCollarId(String id) async {
    await write(StorageKeys.lastCollarId, id);
  }

  /// Get last collar ID
  Future<String?> getLastCollarId() async {
    return await read(StorageKeys.lastCollarId);
  }

  // ============================================================
  // Preferences
  // ============================================================

  /// Store biometrics enabled preference
  Future<void> setBiometricsEnabled(bool enabled) async {
    await write(StorageKeys.biometricsEnabled, enabled.toString());
  }

  /// Get biometrics enabled preference
  Future<bool> getBiometricsEnabled() async {
    final value = await read(StorageKeys.biometricsEnabled);
    return value == 'true';
  }

  /// Store voice note mode (audio_and_text, text_only)
  Future<void> setVoiceNoteMode(String mode) async {
    await write(StorageKeys.voiceNoteMode, mode);
  }

  /// Get voice note mode
  Future<String> getVoiceNoteMode() async {
    return await read(StorageKeys.voiceNoteMode) ?? 'audio_and_text';
  }

  /// Store dark mode preference
  Future<void> setDarkMode(bool enabled) async {
    await write(StorageKeys.darkMode, enabled.toString());
  }

  /// Get dark mode preference
  Future<bool> getDarkMode() async {
    final value = await read(StorageKeys.darkMode);
    return value == 'true';
  }

  // ============================================================
  // Device
  // ============================================================

  /// Store device ID
  Future<void> setDeviceId(String id) async {
    await write(StorageKeys.deviceId, id);
  }

  /// Get device ID (generates one if not exists)
  Future<String> getDeviceId() async {
    var id = await read(StorageKeys.deviceId);
    if (id == null) {
      id = _generateDeviceId();
      await setDeviceId(id);
    }
    return id;
  }

  String _generateDeviceId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp.hashCode.abs();
    return 'DEV-$timestamp-$random';
  }

  /// Store FCM token
  Future<void> setFcmToken(String? token) async {
    if (token == null) {
      await delete(StorageKeys.fcmToken);
    } else {
      await write(StorageKeys.fcmToken, token);
    }
  }

  /// Get FCM token
  Future<String?> getFcmToken() async {
    return await read(StorageKeys.fcmToken);
  }

  // ============================================================
  // JSON objects
  // ============================================================

  /// Store a JSON object
  Future<void> writeJson(String key, Map<String, dynamic> value) async {
    await write(key, jsonEncode(value));
  }

  /// Read a JSON object
  Future<Map<String, dynamic>?> readJson(String key) async {
    final value = await read(key);
    if (value == null) return null;
    try {
      return jsonDecode(value) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
}
