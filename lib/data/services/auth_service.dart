import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/constants/app_config.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// Authentication service
class AuthService extends GetxService {
  final ApiService _api = Get.find<ApiService>();
  final StorageService _storage = Get.find<StorageService>();
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Current observer (logged in user)
  final Rxn<Observer> currentObserver = Rxn<Observer>();

  /// Whether user is authenticated
  final RxBool isAuthenticated = false.obs;

  /// Whether biometrics are available
  final RxBool biometricsAvailable = false.obs;

  /// Whether biometrics are enabled by user
  final RxBool biometricsEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkBiometrics();
  }

  /// Check if biometrics are available on device
  Future<void> _checkBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      biometricsAvailable.value = canCheck && isSupported;

      if (biometricsAvailable.value) {
        biometricsEnabled.value = await _storage.getBiometricsEnabled();
      }
    } catch (e) {
      biometricsAvailable.value = false;
    }
  }

  /// Check if user has valid session
  Future<bool> checkAuthStatus() async {
    final token = await _storage.getAccessToken();
    if (token == null) {
      isAuthenticated.value = false;
      return false;
    }

    final expiry = await _storage.getTokenExpiry();
    if (expiry != null && DateTime.now().isAfter(expiry)) {
      // Token expired - try to refresh
      final refreshed = await _refreshToken();
      if (!refreshed) {
        isAuthenticated.value = false;
        return false;
      }
    }

    // Load observer info
    await _loadObserverInfo();
    isAuthenticated.value = currentObserver.value != null;
    return isAuthenticated.value;
  }

  /// Load observer info from storage
  Future<void> _loadObserverInfo() async {
    final observerId = await _storage.getObserverId();
    final observerName = await _storage.getObserverName();
    final clinicId = await _storage.getClinicId();
    final clinicName = await _storage.getClinicName();

    if (observerId != null &&
        observerName != null &&
        clinicId != null &&
        clinicName != null) {
      currentObserver.value = Observer(
        id: observerId,
        name: observerName,
        email: '', // Not stored locally
        clinicId: clinicId,
        clinicName: clinicName,
        createdAt: DateTime.now(),
      );
    }
  }

  /// Login with credentials
  Future<AuthResult> login({
    required String observerId,
    required String password,
  }) async {
    try {
      // ✅ FIXED: Send 'email' instead of 'observer_id'
      print('🚀 Attempting login with email: $observerId');

      final response = await _api.post(
        ApiEndpoints.login,
        data: {
          'email': observerId, // Changed from 'observer_id' to 'email'
          'password': password,
        },
      );

      print('📥 Response Status Code: ${response.statusCode}');
      print('📦 Full Response Body:');
      print(response.data);
      print('=' * 50);

      if (response.statusCode == 200) {
        // ✅ FIXED: Parse the nested response structure
        final responseBody = response.data as Map<String, dynamic>;

        print('✅ Login API returned 200');
        print('📋 Success: ${responseBody['success']}');
        print('💬 Message: ${responseBody['message']}');

        // Check if the API returned success
        if (responseBody['success'] != true) {
          print('❌ API returned success=false');
          return AuthResult.failure(responseBody['message'] ?? 'Login failed');
        }

        // Get the actual data from the nested structure
        final data = responseBody['data'] as Map<String, dynamic>;
        final user = data['user'] as Map<String, dynamic>;

        print('🔑 Extracting user data...');
        print('👤 User ID: ${user['id']}');
        print('👤 Username: ${user['username']}');
        print('📧 Email: ${user['email']}');
        print('🎫 Token Type: ${data['token_type']}');

        // Extract tokens
        final accessToken = data['access_token'] as String;
        final tokenType = data['token_type'] as String;

        print('💾 Storing tokens and user info...');

        // Store access token
        await _storage.setAccessToken(accessToken);

        // ⚠️ Your API doesn't return refresh_token or expires_in
        // You may need to set a default expiry or update your API
        final expiry = DateTime.now().add(const Duration(hours: 8));
        await _storage.setTokenExpiry(expiry);

        print('⏰ Token expiry set to: $expiry');

        // Store observer info from user object
        await _storage.setObserverId(user['id'].toString());
        await _storage.setObserverName(user['username'] as String);

        // ⚠️ Your API doesn't return clinic info
        // You may need to make a separate call or update your API
        await _storage.setClinicId('1'); // Placeholder
        await _storage.setClinicName('Default Clinic'); // Placeholder

        print('✅ User info stored successfully');

        // Create observer object
        currentObserver.value = Observer(
          id: user['id'].toString(),
          name: user['username'] as String,
          email: user['email'] as String,
          clinicId: '1', // Placeholder
          clinicName: 'Default Clinic', // Placeholder
          createdAt: DateTime.parse(user['created_at'] as String),
        );

        isAuthenticated.value = true;

        print('🎉 Login successful!');
        print('=' * 50);

        return AuthResult.success();
      }

      print('❌ Login failed with status code: ${response.statusCode}');
      return AuthResult.failure('Login failed');
    } catch (e) {
      print('💥 Exception during login:');
      print('Error Type: ${e.runtimeType}');
      print('Error Message: $e');
      print('=' * 50);

      if (e is ApiException) {
        return AuthResult.failure(e.message);
      }
      return AuthResult.failure('Login failed: ${e.toString()}');
    }
  }

  /// Authenticate with biometrics
  Future<AuthResult> authenticateWithBiometrics() async {
    if (!biometricsAvailable.value || !biometricsEnabled.value) {
      return AuthResult.failure('Biometrics not available');
    }

    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access VetSync',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        // Check if we have valid tokens
        final hasValidSession = await checkAuthStatus();
        if (hasValidSession) {
          return AuthResult.success();
        }
        return AuthResult.failure('Session expired. Please login again.');
      }

      return AuthResult.failure('Biometric authentication failed');
    } catch (e) {
      return AuthResult.failure('Biometric error: ${e.toString()}');
    }
  }

  /// Enable biometrics for future logins
  Future<void> enableBiometrics(bool enabled) async {
    await _storage.setBiometricsEnabled(enabled);
    biometricsEnabled.value = enabled;
  }

  /// Refresh access token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _api.post(
        ApiEndpoints.refresh,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        await _storage.setAccessToken(data['access_token'] as String);

        if (data['refresh_token'] != null) {
          await _storage.setRefreshToken(data['refresh_token'] as String);
        }

        if (data['expires_in'] != null) {
          final expiry = DateTime.now().add(
            Duration(seconds: data['expires_in'] as int),
          );
          await _storage.setTokenExpiry(expiry);
        }

        return true;
      }
    } catch (e) {
      print('Token refresh error: $e');
    }
    return false;
  }

  /// Logout
  Future<void> logout() async {
    try {
      // Notify server (best effort)
      await _api.post(ApiEndpoints.logout);
    } catch (e) {
      // Ignore errors
    }

    // Clear local auth data
    await _storage.clearAuth();
    currentObserver.value = null;
    isAuthenticated.value = false;
  }

  /// Get current observer ID
  String? get observerId => currentObserver.value?.id;

  /// Get current clinic ID
  String? get clinicId => currentObserver.value?.clinicId;

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    if (!biometricsAvailable.value) return [];
    return await _localAuth.getAvailableBiometrics();
  }

  /// Get biometric type display name
  String getBiometricTypeName(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) {
      return 'Face ID';
    }
    if (types.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    }
    if (types.contains(BiometricType.iris)) {
      return 'Iris';
    }
    return 'Biometrics';
  }

  /// Get device information
  Future<Map<String, String>> getDeviceInfo(dynamic deviceInfo) async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String deviceId = await _storage.getDeviceId();

    final info = <String, String>{
      'App Version': '${packageInfo.version} (${packageInfo.buildNumber})',
      'Device ID': deviceId,
    };

    try {
      if (GetPlatform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        info['Device'] = '${androidInfo.manufacturer} ${androidInfo.model}';
        info['OS'] = 'Android ${androidInfo.version.release}';
      } else if (GetPlatform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        info['Device'] = iosInfo.model;
        info['OS'] = '${iosInfo.systemName} ${iosInfo.systemVersion}';
      }
    } catch (e) {
      info['Device'] = 'Unknown';
      info['OS'] = 'Unknown';
    }

    return info;
  }
}

/// Auth result wrapper
class AuthResult {
  final bool success;
  final String? errorMessage;

  AuthResult._({required this.success, this.errorMessage});

  factory AuthResult.success() => AuthResult._(success: true);

  factory AuthResult.failure(String message) =>
      AuthResult._(success: false, errorMessage: message);
}
