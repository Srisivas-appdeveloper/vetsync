import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_pages.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_typography.dart';
import '../../../app/themes/app_theme.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/services/sync_service.dart';

/// Settings page
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final storageService = Get.find<StorageService>();
    final syncService = Get.find<SyncService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          // Account section
          _buildSectionHeader('Account'),
          _buildAccountCard(authService),
          const SizedBox(height: 24),

          // Security section
          _buildSectionHeader('Security'),
          _buildSecuritySettings(authService, storageService),
          const SizedBox(height: 24),

          // Data section
          _buildSectionHeader('Data & Sync'),
          _buildDataSettings(syncService),
          const SizedBox(height: 24),

          // App section
          _buildSectionHeader('App'),
          _buildAppSettings(),
          const SizedBox(height: 24),

          // Device info
          _buildDeviceInfo(authService),
          const SizedBox(height: 32),

          // Logout button
          _buildLogoutButton(authService),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppTypography.labelMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildAccountCard(AuthService authService) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Obx(() {
        final observer = authService.currentObserver.value;

        return Row(
          children: [
            // Avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  observer?.initials ?? '?',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    observer?.name ?? 'Unknown',
                    style: AppTypography.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    observer?.email ?? '',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    observer?.clinicName ?? '',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSecuritySettings(
    AuthService authService,
    StorageService storageService,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Biometrics toggle
          Obx(
            () => SwitchListTile(
              title: const Text('Use Biometrics'),
              subtitle: const Text('Use fingerprint or face to login'),
              value: authService.biometricsEnabled.value,
              onChanged: authService.biometricsAvailable.value
                  ? (value) => authService.enableBiometrics(value)
                  : null,
              secondary: const Icon(Icons.fingerprint),
            ),
          ),

          const Divider(height: 1),

          // Change password
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Get.snackbar(
                'Coming Soon',
                'Password change will be available in a future update',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDataSettings(SyncService syncService) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Pending uploads
          Obx(
            () => ListTile(
              leading: const Icon(Icons.cloud_upload_outlined),
              title: const Text('Pending Uploads'),
              subtitle: Text('${syncService.pendingCount.value} items waiting'),
              trailing: syncService.isSyncing.value
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : TextButton(
                      onPressed: syncService.pendingCount.value > 0
                          ? () => syncService.syncPending()
                          : null,
                      child: const Text('Sync Now'),
                    ),
            ),
          ),

          const Divider(height: 1),

          // Auto sync toggle
          SwitchListTile(
            title: const Text('Auto Sync'),
            subtitle: const Text('Automatically sync when online'),
            value: true, // TODO: Make this a setting
            onChanged: (value) {
              // TODO: Implement auto sync toggle
            },
            secondary: const Icon(Icons.sync),
          ),

          const Divider(height: 1),

          // Clear local data
          ListTile(
            leading: const Icon(Icons.delete_outline, color: AppColors.error),
            title: const Text('Clear Local Data'),
            subtitle: const Text('Remove cached data from device'),
            onTap: () => _showClearDataDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettings() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Voice note mode
          ListTile(
            leading: const Icon(Icons.mic),
            title: const Text('Voice Note Mode'),
            subtitle: const Text('Push-to-talk'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Get.snackbar(
                'Coming Soon',
                'Voice settings will be available in a future update',
              );
            },
          ),

          const Divider(height: 1),

          // Notifications
          SwitchListTile(
            title: const Text('Notifications'),
            subtitle: const Text('Session alerts and reminders'),
            value: true, // TODO: Make this a setting
            onChanged: (value) {
              // TODO: Implement notifications toggle
            },
            secondary: const Icon(Icons.notifications_outlined),
          ),

          const Divider(height: 1),

          // About
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAboutDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceInfo(AuthService authService) {
    return FutureBuilder<Map<String, String>>(
      future: authService.getDeviceInfo(authService),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final info = snapshot.data!;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Device Information',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              ...info.entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key, style: AppTypography.caption),
                      Text(e.value, style: AppTypography.caption),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton(AuthService authService) {
    return OutlinedButton.icon(
      onPressed: () => _showLogoutDialog(authService),
      icon: const Icon(Icons.logout, color: AppColors.error),
      label: const Text('Logout'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.error,
        side: const BorderSide(color: AppColors.error),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  void _showClearDataDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear Local Data?'),
        content: const Text(
          'This will remove all cached data from your device. '
          'Unsynced data will be lost. This cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              // TODO: Implement clear data
              Get.snackbar('Success', 'Local data cleared');
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(AuthService authService) {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout?'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back();
              await authService.logout();
              Get.offAllNamed(Routes.login);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.pets, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('VetSync Clinical'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Version 1.0.0'),
            const SizedBox(height: 8),
            Text(
              'Veterinary surgical monitoring and data collection system.',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 16),
            Text(
              '© 2024 VetSync Medical Devices',
              style: AppTypography.caption,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }
}
