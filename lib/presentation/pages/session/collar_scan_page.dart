import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_typography.dart';
import '../../../app/themes/app_theme.dart';
import '../../../data/models/models.dart';
import '../../controllers/collar_scan_controller.dart';
import '../../widgets/common_widgets.dart';

/// Collar BLE scan screen
class CollarScanPage extends GetView<CollarScanController> {
  const CollarScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Connect Collar'),
        actions: [
          Obx(() => IconButton(
            icon: Icon(
              controller.isScanning.value ? Icons.stop : Icons.refresh,
            ),
            onPressed: controller.isScanning.value 
                ? controller.stopScan 
                : controller.startScan,
            tooltip: controller.isScanning.value ? 'Stop Scan' : 'Scan Again',
          )),
        ],
      ),
      body: Obx(() => _buildContent()),
    );
  }
  
  Widget _buildContent() {
    // Permission check
    if (!controller.hasPermission.value) {
      return _buildPermissionRequest();
    }
    
    // Connecting
    if (controller.isConnecting.value) {
      return _buildConnecting();
    }
    
    // Scan results
    return Column(
      children: [
        // Scan status bar
        _buildScanStatus(),
        
        // Error message
        if (controller.connectionError.isNotEmpty) _buildError(),
        
        // Collar list
        Expanded(
          child: controller.discoveredCollars.isEmpty
              ? _buildEmptyState()
              : _buildCollarList(),
        ),
      ],
    );
  }
  
  Widget _buildPermissionRequest() {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.bluetooth_disabled,
              size: 64,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: 24),
            Text(
              'Bluetooth Permission Required',
              style: AppTypography.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'VetSync needs Bluetooth and location permissions to discover and connect to collars.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.requestPermissions,
              icon: const Icon(Icons.settings),
              label: const Text('Grant Permissions'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildConnecting() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Connecting...',
            style: AppTypography.titleMedium,
          ),
          if (controller.selectedCollar.value != null) ...[
            const SizedBox(height: 8),
            Text(
              controller.selectedCollar.value!.collarId,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildScanStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: controller.isScanning.value 
          ? AppColors.primarySurface 
          : AppColors.surface,
      child: Row(
        children: [
          if (controller.isScanning.value) ...[
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            const Text('Scanning for collars...'),
          ] else ...[
            Icon(
              Icons.bluetooth,
              color: AppColors.textSecondary,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              '${controller.discoveredCollars.length} collar(s) found',
              style: AppTypography.bodySmall,
            ),
          ],
          const Spacer(),
          if (!controller.isScanning.value)
            TextButton(
              onPressed: controller.startScan,
              child: const Text('Scan'),
            ),
        ],
      ),
    );
  }
  
  Widget _buildError() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              controller.connectionError.value,
              style: AppTypography.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return EmptyState(
      icon: Icons.bluetooth_searching,
      title: controller.isScanning.value 
          ? 'Searching...' 
          : 'No collars found',
      subtitle: 'Make sure the collar is turned on and within range',
      action: !controller.isScanning.value
          ? ElevatedButton.icon(
              onPressed: controller.startScan,
              icon: const Icon(Icons.refresh),
              label: const Text('Scan Again'),
            )
          : null,
    );
  }
  
  Widget _buildCollarList() {
    return ListView.builder(
      padding: AppSpacing.screenPadding,
      itemCount: controller.discoveredCollars.length,
      itemBuilder: (context, index) {
        final collar = controller.discoveredCollars[index];
        return _CollarCard(
          collar: collar,
          status: controller.getCollarStatus(collar),
          isLastUsed: controller.isLastUsed(collar),
          batteryWarning: controller.getBatteryWarning(collar),
          onTap: () => controller.connectToCollar(collar),
        );
      },
    );
  }
}

/// Collar card widget
class _CollarCard extends StatelessWidget {
  final DiscoveredCollar collar;
  final String status;
  final bool isLastUsed;
  final String? batteryWarning;
  final VoidCallback onTap;
  
  const _CollarCard({
    required this.collar,
    required this.status,
    required this.isLastUsed,
    this.batteryWarning,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isLastUsed ? AppColors.primarySurface : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Collar icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isLastUsed 
                          ? AppColors.primary.withOpacity(0.1) 
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.pets,
                      color: isLastUsed ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Collar info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              collar.collarId,
                              style: AppTypography.titleMedium,
                            ),
                            if (isLastUsed) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8, 
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'LAST USED',
                                  style: AppTypography.badge,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildSignalIndicator(),
                            const SizedBox(width: 16),
                            if (collar.batteryPercent != null)
                              _buildBatteryIndicator(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Connect button
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              
              // Battery warning
              if (batteryWarning != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.warningSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.battery_alert,
                        size: 16,
                        color: AppColors.warningDark,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        batteryWarning!,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.warningDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSignalIndicator() {
    final color = _getSignalColor();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.signal_cellular_alt, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          collar.signalStrength.displayName,
          style: AppTypography.labelSmall.copyWith(color: color),
        ),
      ],
    );
  }
  
  Widget _buildBatteryIndicator() {
    final battery = collar.batteryPercent!;
    final color = AppColors.getBatteryColor(battery);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          battery > 50 ? Icons.battery_full : Icons.battery_3_bar,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          '$battery%',
          style: AppTypography.labelSmall.copyWith(color: color),
        ),
      ],
    );
  }
  
  Color _getSignalColor() {
    switch (collar.signalStrength) {
      case SignalStrength.excellent:
        return AppColors.success;
      case SignalStrength.good:
        return AppColors.primary;
      case SignalStrength.fair:
        return AppColors.warning;
      case SignalStrength.poor:
        return AppColors.error;
    }
  }
}
