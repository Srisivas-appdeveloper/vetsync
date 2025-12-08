import 'package:get/get.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../../core/constants/app_config.dart';

/// Auth repository
class AuthRepository {
  final ApiService _api = Get.find<ApiService>();
  final AuthService _auth = Get.find<AuthService>();

  /// Login with credentials
  Future<AuthResult> login({
    required String observerId,
    required String password,
  }) async {
    return _auth.login(observerId: observerId, password: password);
  }

  /// Authenticate with biometrics
  Future<AuthResult> authenticateWithBiometrics() async {
    return _auth.authenticateWithBiometrics();
  }

  /// Check if user is authenticated
  Future<bool> checkAuth() async {
    return _auth.checkAuthStatus();
  }

  /// Logout
  Future<void> logout() async {
    return _auth.logout();
  }

  /// Get current observer
  Observer? get currentObserver => _auth.currentObserver.value;

  /// Get observer ID
  String? get observerId => _auth.observerId;

  /// Get clinic ID
  String? get clinicId => _auth.clinicId;

  /// Check if biometrics available
  bool get biometricsAvailable => _auth.biometricsAvailable.value;

  /// Check if biometrics enabled
  bool get biometricsEnabled => _auth.biometricsEnabled.value;

  /// Enable/disable biometrics
  Future<void> enableBiometrics(bool enabled) async {
    return _auth.enableBiometrics(enabled);
  }

  /// Get profile from API
  Future<Observer> getProfile() async {
    final response = await _api.get(ApiEndpoints.profile);
    final responseData = response.data as Map<String, dynamic>;

    final userData =
        responseData['data'] as Map<String, dynamic>? ?? responseData;

    return Observer.fromJson(userData);
  }
}
