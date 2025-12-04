import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../app/themes/app_colors.dart';
import '../../app/themes/app_typography.dart';
import '../../app/themes/app_theme.dart';
import '../../data/models/models.dart';

/// Session status bar widget - shows collar info, connection, battery
class SessionStatusBar extends StatelessWidget {
  final String? collarId;
  final bool isConnected;
  final int batteryPercent;
  final int signalQuality;
  final VoidCallback? onTap;

  const SessionStatusBar({
    super.key,
    this.collarId,
    this.isConnected = false,
    this.batteryPercent = 100,
    this.signalQuality = 100,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: Row(
          children: [
            // Collar ID
            _buildCollarChip(),
            const SizedBox(width: 12),

            // Connection status
            _buildConnectionIndicator(),
            const Spacer(),

            // Signal quality
            _buildSignalIndicator(),
            const SizedBox(width: 16),

            // Battery
            _buildBatteryIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildCollarChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.pets,
            size: 16,
            color: isConnected ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            collarId ?? 'No Collar',
            style: AppTypography.labelMedium.copyWith(
              color: isConnected
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isConnected ? AppColors.connected : AppColors.disconnected,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          isConnected ? 'Connected' : 'Disconnected',
          style: AppTypography.labelSmall.copyWith(
            color: isConnected ? AppColors.connected : AppColors.disconnected,
          ),
        ),
      ],
    );
  }

  Widget _buildSignalIndicator() {
    final color = AppColors.getQualityColor(signalQuality);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.signal_cellular_alt, size: 18, color: color),
        const SizedBox(width: 4),
        Text(
          '$signalQuality%',
          style: AppTypography.labelSmall.copyWith(color: color),
        ),
      ],
    );
  }

  Widget _buildBatteryIndicator() {
    final color = AppColors.getBatteryColor(batteryPercent);
    IconData icon;

    if (batteryPercent > 80) {
      icon = Icons.battery_full;
    } else if (batteryPercent > 50) {
      icon = Icons.battery_5_bar;
    } else if (batteryPercent > 20) {
      icon = Icons.battery_3_bar;
    } else {
      icon = Icons.battery_alert;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 4),
        Text(
          '$batteryPercent%',
          style: AppTypography.labelSmall.copyWith(color: color),
        ),
      ],
    );
  }
}

/// Vital card widget - displays a single vital with range indicator
class VitalCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final VitalRange? range;
  final double? currentValue;
  final Color? color;
  final IconData? icon;
  final bool compact;

  const VitalCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    this.range,
    this.currentValue,
    this.color,
    this.icon,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayColor = _getColor();

    if (compact) {
      return _buildCompact(displayColor);
    }

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
          // Label row
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
              ],
              Text(label, style: AppTypography.labelSmall),
            ],
          ),
          const SizedBox(height: 8),

          // Value
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppTypography.vitalValue.copyWith(color: displayColor),
              ),
              const SizedBox(width: 4),
              Text(unit, style: AppTypography.vitalUnit),
            ],
          ),

          // Range indicator
          if (range != null && currentValue != null) ...[
            const SizedBox(height: 12),
            _buildRangeIndicator(displayColor),
          ],
        ],
      ),
    );
  }

  Widget _buildCompact(Color displayColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: displayColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: displayColor),
            const SizedBox(width: 6),
          ],
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(color: displayColor),
          ),
          const SizedBox(width: 4),
          Text(
            unit,
            style: AppTypography.bodySmall.copyWith(color: displayColor),
          ),
        ],
      ),
    );
  }

  Widget _buildRangeIndicator(Color indicatorColor) {
    if (range == null || currentValue == null) return const SizedBox.shrink();

    // Calculate position (0.0 to 1.0) within extended range
    final extendedMin = range!.min - (range!.max - range!.min) * 0.2;
    final extendedMax = range!.max + (range!.max - range!.min) * 0.2;
    final position =
        (currentValue! - extendedMin) / (extendedMax - extendedMin);
    final clampedPosition = position.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Range bar
        Container(
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: LinearGradient(
              colors: [
                AppColors.error.withOpacity(0.3),
                AppColors.success.withOpacity(0.3),
                AppColors.success.withOpacity(0.3),
                AppColors.error.withOpacity(0.3),
              ],
              stops: const [0.0, 0.2, 0.8, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Normal range highlight
              Positioned(
                left: 20,
                right: 20,
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Current value indicator
              Positioned(
                // left: clampedPosition * (MediaQuery.of(Get.context!).size.width - 100) - 4,
                top: -2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: indicatorColor,
                    border: Border.all(color: AppColors.white, width: 2),
                    boxShadow: AppShadows.small,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),

        // Range labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(range!.min.toInt().toString(), style: AppTypography.caption),
            Text(
              'Normal: ${range!.displayString}',
              style: AppTypography.caption,
            ),
            Text(range!.max.toInt().toString(), style: AppTypography.caption),
          ],
        ),
      ],
    );
  }

  Color _getColor() {
    if (color != null) return color!;
    if (range == null || currentValue == null) return AppColors.textPrimary;

    if (range!.isInRange(currentValue!)) {
      return AppColors.success;
    } else {
      return AppColors.warning;
    }
  }
}

/// Quick annotation button
class QuickAnnotationButton extends StatelessWidget {
  final String label;
  final String emoji;
  final VoidCallback onPressed;
  final bool isEmergency;
  final bool isSelected;

  const QuickAnnotationButton({
    super.key,
    required this.label,
    required this.emoji,
    required this.onPressed,
    this.isEmergency = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isEmergency
                ? AppColors.errorSurface
                : isSelected
                ? AppColors.primarySurface
                : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isEmergency
                  ? AppColors.error
                  : isSelected
                  ? AppColors.primary
                  : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: isEmergency ? AppColors.error : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Phase banner widget
class PhaseBanner extends StatelessWidget {
  final SessionPhase phase;
  final String duration;

  const PhaseBanner({super.key, required this.phase, required this.duration});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (phase) {
      case SessionPhase.preSurgery:
        bgColor = AppColors.infoSurface;
        textColor = AppColors.infoDark;
        icon = Icons.access_time;
        break;
      case SessionPhase.surgery:
        bgColor = AppColors.surgeryBanner;
        textColor = AppColors.surgeryText;
        icon = Icons.healing;
        break;
      case SessionPhase.calibration:
        bgColor = AppColors.warningSurface;
        textColor = AppColors.warningDark;
        icon = Icons.tune;
        break;
      case SessionPhase.recovery:
        bgColor = AppColors.recoveryBanner;
        textColor = AppColors.recoveryGreen;
        icon = Icons.favorite;
        break;
      case SessionPhase.completed:
        bgColor = AppColors.successSurface;
        textColor = AppColors.successDark;
        icon = Icons.check_circle;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: bgColor),
      child: Row(
        children: [
          Icon(icon, size: 20, color: textColor),
          const SizedBox(width: 8),
          Text(
            phase.displayName.toUpperCase(),
            style: AppTypography.labelMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            duration,
            style: AppTypography.timerSmall.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}

/// Loading overlay widget
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final String? message;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    this.message,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(message!, style: AppTypography.bodyMedium),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Empty state widget
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.textDisabled),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTypography.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: AppTypography.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}
