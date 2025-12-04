import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_typography.dart';
import '../../../app/themes/app_theme.dart';
import '../../../data/models/models.dart';
import '../../controllers/dashboard_controller.dart';
import '../../widgets/common_widgets.dart';

/// Main dashboard screen
class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Obx(() => RefreshIndicator(
        onRefresh: controller.loadDashboard,
        child: controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(),
      )),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
  
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Text(
            '${controller.greeting}, ${controller.observerName}',
            style: AppTypography.titleMedium,
          )),
          Obx(() => Text(
            controller.clinicName,
            style: AppTypography.bodySmall,
          )),
        ],
      ),
      actions: [
        // Sync indicator
        Obx(() {
          if (controller.pendingUploads > 0) {
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    controller.isSyncing 
                        ? Icons.sync 
                        : Icons.cloud_upload_outlined,
                  ),
                  onPressed: controller.syncNow,
                ),
                if (!controller.isSyncing)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${controller.pendingUploads}',
                        style: AppTypography.badge,
                      ),
                    ),
                  ),
              ],
            );
          }
          return const SizedBox.shrink();
        }),
        
        // Settings
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: controller.openSettings,
        ),
      ],
    );
  }
  
  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Connection status
          _buildConnectionStatus(),
          const SizedBox(height: 16),
          
          // Quick stats
          _buildQuickStats(),
          const SizedBox(height: 24),
          
          // Today's sessions
          _buildTodaySessions(),
          const SizedBox(height: 24),
          
          // Available collars
          _buildAvailableCollars(),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }
  
  Widget _buildConnectionStatus() {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: controller.isOnline 
            ? AppColors.successSurface 
            : AppColors.errorSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            controller.isOnline ? Icons.cloud_done : Icons.cloud_off,
            size: 16,
            color: controller.isOnline ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 8),
          Text(
            controller.isOnline 
                ? 'Online - ${controller.connectivityStatus}'
                : 'Offline - Data saved locally',
            style: AppTypography.labelSmall.copyWith(
              color: controller.isOnline 
                  ? AppColors.successDark 
                  : AppColors.errorDark,
            ),
          ),
        ],
      ),
    ));
  }
  
  Widget _buildQuickStats() {
    return Obx(() {
      final stats = controller.stats.value;
      
      return Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'Today',
              value: stats?.todaySessionCount.toString() ?? '-',
              icon: Icons.today,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: 'This Week',
              value: stats?.weekSessionCount.toString() ?? '-',
              icon: Icons.date_range,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: 'Calibrated',
              value: stats?.calibratedSessions.toString() ?? '-',
              icon: Icons.check_circle,
              color: AppColors.success,
            ),
          ),
        ],
      );
    });
  }
  
  Widget _buildTodaySessions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Sessions",
          style: AppTypography.titleMedium,
        ),
        const SizedBox(height: 12),
        
        Obx(() {
          if (controller.todaySessions.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const EmptyState(
                icon: Icons.assignment_outlined,
                title: 'No sessions today',
                subtitle: 'Start a new session to begin collecting data',
              ),
            );
          }
          
          return Column(
            children: controller.todaySessions.map((session) {
              return _SessionCard(
                session: session,
                onTap: () => controller.resumeSession(session),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
  
  Widget _buildAvailableCollars() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Collars',
          style: AppTypography.titleMedium,
        ),
        const SizedBox(height: 12),
        
        Obx(() {
          if (controller.availableCollars.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.bluetooth_disabled,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'No collars available',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }
          
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.availableCollars.map((collar) {
              return Chip(
                avatar: Icon(
                  Icons.pets,
                  size: 16,
                  color: AppColors.getBatteryColor(collar.batteryPercent),
                ),
                label: Text(collar.serialNumber),
                backgroundColor: AppColors.surface,
                side: BorderSide(color: AppColors.border),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
  
  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: controller.startNewSession,
      icon: const Icon(Icons.add),
      label: const Text('New Session'),
    );
  }
}

/// Stat card widget
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.headlineSmall.copyWith(
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }
}

/// Session card widget
class _SessionCard extends StatelessWidget {
  final Session session;
  final VoidCallback onTap;
  
  const _SessionCard({
    required this.session,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Phase indicator
              Container(
                width: 8,
                height: 48,
                decoration: BoxDecoration(
                  color: _getPhaseColor(),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 16),
              
              // Session info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Session ${session.sessionCode}',
                      style: AppTypography.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${session.currentPhase.displayName} • ${session.formattedDuration}',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              
              // Status chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPhaseColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  session.isActive ? 'Active' : 'Complete',
                  style: AppTypography.labelSmall.copyWith(
                    color: _getPhaseColor(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              // Arrow
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getPhaseColor() {
    switch (session.currentPhase) {
      case SessionPhase.preSurgery:
        return AppColors.info;
      case SessionPhase.surgery:
        return AppColors.surgeryRed;
      case SessionPhase.calibration:
        return AppColors.warning;
      case SessionPhase.recovery:
        return AppColors.success;
      case SessionPhase.completed:
        return AppColors.textSecondary;
    }
  }
}
