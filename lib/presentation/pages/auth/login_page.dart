import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_typography.dart';
import '../../../app/themes/app_theme.dart';
import '../../controllers/auth_controller.dart';

/// Login screen
class LoginPage extends GetView<AuthController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),

              // Logo and header
              _buildHeader(),
              const SizedBox(height: 48),

              // Login form
              _buildLoginForm(),
              const SizedBox(height: 24),

              // Biometrics button
              _buildBiometricsButton(),
              const SizedBox(height: 32),

              // Error message
              _buildErrorMessage(),

              // Login button
              _buildLoginButton(),
              const SizedBox(height: 24),

              // Footer
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.pets, size: 40, color: AppColors.white),
        ),
        const SizedBox(height: 16),

        // Title
        Text('VetSync Clinical', style: AppTypography.headlineMedium),
        const SizedBox(height: 8),

        // Subtitle
        Text(
          'Sign in to start collecting data',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email field
          TextFormField(
            controller: controller.observerIdController,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email address',
              prefixIcon: const Icon(Icons.email_outlined),
              filled: true,
              fillColor: AppColors.surface,
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: controller.validateObserverId,
            enabled: !controller.isLoading.value,
          ),
          const SizedBox(height: 16),

          // Password field
          Obx(
            () => TextFormField(
              controller: controller.passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.obscurePassword.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: controller.togglePasswordVisibility,
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
              obscureText: controller.obscurePassword.value,
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.done,
              validator: controller.validatePassword,
              enabled: !controller.isLoading.value,
              onFieldSubmitted: (_) => controller.login(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricsButton() {
    return Obx(() {
      if (!controller.biometricsAvailable || !controller.biometricsEnabled) {
        return const SizedBox.shrink();
      }

      return Center(
        child: TextButton.icon(
          onPressed: controller.isLoading.value
              ? null
              : controller.loginWithBiometrics,
          icon: const Icon(Icons.fingerprint, size: 28),
          label: const Text('Use Biometrics'),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      );
    });
  }

  Widget _buildErrorMessage() {
    return Obx(() {
      if (controller.errorMessage.isEmpty) {
        return const SizedBox(height: 16);
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.errorSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                controller.errorMessage.value,
                style: AppTypography.bodySmall.copyWith(color: AppColors.error),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLoginButton() {
    return Obx(
      () => ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.login,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: controller.isLoading.value
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            : const Text('Sign In'),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text('VetSync Clinical v1.0.0', style: AppTypography.caption),
        const SizedBox(height: 4),
        Text('© 2024 VetSync Medical Devices', style: AppTypography.caption),
      ],
    );
  }
}
