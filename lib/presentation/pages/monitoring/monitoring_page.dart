// lib/presentation/pages/monitoring/monitoring_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/monitoring_controller.dart';
import '../../../widgets/vital_signs_display.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_typography.dart';
import '../../../app/themes/app_theme.dart';
import '../../../widgets/bcg_waveform_widget.dart';

class MonitoringPage extends GetView<MonitoringController> {
  const MonitoringPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is registered
    if (!Get.isRegistered<MonitoringController>()) {
      Get.put(MonitoringController());
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Live Monitoring'),
        actions: [
          // Connection Status Indicator
          Obx(() {
            final isConnected = controller.isConnected;
            return Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Icon(
                isConnected
                    ? Icons.bluetooth_connected
                    : Icons.bluetooth_disabled,
                color: isConnected ? AppColors.success : AppColors.error,
              ),
            );
          }),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            children: [
              // Mode Switcher
              _buildModeSwitcher(),
              const SizedBox(height: 24),

              // Live Vitals Display - Use fixed height instead of Expanded for scrollability
              LayoutBuilder(
                builder: (context, constraints) {
                  // Allocate space for vitals based on screen size
                  final screenHeight = MediaQuery.of(context).size.height;
                  final vitalsHeight = (screenHeight * 0.5).clamp(300.0, 500.0);

                  return SizedBox(
                    height: vitalsHeight,
                    child: GetBuilder<MonitoringController>(
                      // Use GetBuilder for simple updates or Obx
                      id: 'vitals', // Update ID if needed
                      builder: (ctrl) {
                        // We need to listen to the service updates.
                        // Since VitalSignsDisplay takes non-observable values, we wrap it in Obx
                        return Obx(() {
                          // Trigger rebuild when latestResult changes (indirectly via GetxService listener in BleService?
                          // BleService updates its streams.
                          // But controller properties access getters.
                          // We need to make sure UI rebuilds when BCG service updates.

                          // Actually, controller.lastBcgResult is a getter, not observable.
                          // But BleService.bcgService is ChangeNotifier.

                          return ListenableBuilder(
                            listenable: controller.bcgService,
                            builder: (context, _) {
                              return VitalSignsDisplay(
                                bcgResult: controller.lastBcgResult,
                                temperatureCelsius: controller.temperature,
                                signalQuality: controller.signalQuality,
                                onRefresh: controller.resetService,
                              );
                            },
                          );
                        });
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // BCG Waveform Display
              Text("Real-time Pulse Waveform", style: AppTypography.titleSmall),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  // Use 20% of screen height or minimum 150px for waveform
                  final screenHeight = MediaQuery.of(context).size.height;
                  final waveformHeight = (screenHeight * 0.20).clamp(150.0, 250.0);

                  return Container(
                    height: waveformHeight,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: BCGWaveformWidget(controller: controller),
                  );
                },
              ),

              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: Obx(
        () => FloatingActionButton.extended(
          onPressed: controller.switchMode,
          icon: Icon(controller.isStandardMode ? Icons.speed : Icons.analytics),
          label: Text(
            controller.isStandardMode
                ? 'Switch to HIGH-RES'
                : 'Switch to STANDARD',
          ),
          backgroundColor: controller.isStandardMode
              ? AppColors.primary
              : AppColors.secondary,
        ),
      ),
    );
  }

  Widget _buildModeSwitcher() {
    return Obx(() {
      final isStandard = controller.isStandardMode;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Mode', style: AppTypography.caption),
                Text(
                  isStandard ? 'STANDARD (100Hz)' : 'HIGH-RES (128Hz)',
                  style: AppTypography.titleMedium.copyWith(
                    color: isStandard ? AppColors.primary : AppColors.secondary,
                  ),
                ),
              ],
            ),
            if (!controller.isConnected)
              const Chip(label: Text('Disconnected'))
            else
              const Icon(Icons.check_circle_outline, color: AppColors.success),
          ],
        ),
      );
    });
  }
}

// Extension to access private _bleService from builder if needed,
// or better, expose proper listenable in controller.
extension on MonitoringController {
  // We need to access the service to listen to it.
  // In the file above I used _bleService, but it's private.
  // I should expose the listenable.
  // See updated controller below (I can't edit it here, so I will fix access in the code block).
  // Actually, I can rely on GetX to rebuild if I use Rx variables properly.
  // But BcgResult is not Rx.
}
