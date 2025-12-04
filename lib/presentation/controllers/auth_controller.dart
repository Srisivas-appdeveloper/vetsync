import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_pages.dart';
import '../../data/models/models.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/storage_service.dart';

/// Controller for authentication flow
class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final StorageService _storage = Get.find<StorageService>();

  // Form controllers
  final observerIdController = TextEditingController();
  final passwordController = TextEditingController();

  // Form state
  final formKey = GlobalKey<FormState>();
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxString errorMessage = ''.obs;

  // Biometrics
  bool get biometricsAvailable => _authService.biometricsAvailable.value;
  bool get biometricsEnabled => _authService.biometricsEnabled.value;

  @override
  void onInit() {
    super.onInit();
    _loadLastObserverId();
  }

  @override
  void onClose() {
    observerIdController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  /// Load last used observer ID (email)
  Future<void> _loadLastObserverId() async {
    final lastId = await _storage.getObserverId();
    if (lastId != null) {
      observerIdController.text = lastId;
    }
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword.toggle();
  }

  /// Login with credentials
  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    errorMessage.value = '';
    isLoading.value = true;

    try {
      final result = await _authService.login(
        observerId: observerIdController.text.trim(),
        password: passwordController.text,
      );

      if (result.success) {
        passwordController.clear();

        // Show success toast
        Get.snackbar(
          'Login Successful',
          'Welcome back!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );

        // Small delay to show toast before navigation
        await Future.delayed(const Duration(milliseconds: 500));

        Get.offAllNamed(Routes.dashboard);
      } else {
        errorMessage.value = result.errorMessage ?? 'Login failed';
      }
    } catch (e) {
      errorMessage.value = 'An error occurred. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Login with biometrics
  Future<void> loginWithBiometrics() async {
    if (!biometricsAvailable || !biometricsEnabled) return;

    errorMessage.value = '';
    isLoading.value = true;

    try {
      final result = await _authService.authenticateWithBiometrics();

      if (result.success) {
        // Show success toast
        Get.snackbar(
          'Authentication Successful',
          'Welcome back!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          icon: const Icon(Icons.fingerprint, color: Colors.white),
        );

        await Future.delayed(const Duration(milliseconds: 500));

        Get.offAllNamed(Routes.dashboard);
      } else {
        errorMessage.value =
            result.errorMessage ?? 'Biometric authentication failed';

        // Show error toast
        Get.snackbar(
          'Authentication Failed',
          errorMessage.value,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }
    } catch (e) {
      errorMessage.value = 'Biometric authentication error';
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ FIXED: Validate email instead of observer ID
  String? validateObserverId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required'; // Changed
    }

    // Basic email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email'; // Changed
    }

    return null;
  }

  /// Validate password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}
