import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../app/routes/app_pages.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_typography.dart';
import '../../../app/themes/app_theme.dart';
import '../../../data/models/models.dart';
import '../../../data/services/ble_service.dart';
import '../../controllers/session_controller.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/annotation_panel.dart';
import '../../widgets/waveform_display.dart';

/// Surgery monitoring page - active during surgical procedure
class SurgeryPage extends StatefulWidget {
  const SurgeryPage({super.key});

  @override
  State<SurgeryPage> createState() => _SurgeryPageState();
}

class _SurgeryPageState extends State<SurgeryPage>
    with TickerProviderStateMixin {
  final SessionController _sessionController = Get.find<SessionController>();
  final BleService _bleService = Get.find<BleService>();

  // Waveform data buffers
  final List<double> _bcgWaveform = [];
  final List<double> _heartRateHistory = [];
  final List<double> _respRateHistory = [];

  // Animation controller for surgery indicator
  late AnimationController _pulseController;

  // Data stream subscription
  StreamSubscription? _dataSubscription;

  // Panel visibility
  final RxBool _showAnnotationPanel = false.obs;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _setupDataStream();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _dataSubscription?.cancel();
    super.dispose();
  }

  void _setupDataStream() {
    _dataSubscription = _bleService.vitalsStream.listen((vitals) {
      setState(() {
        // Add to history (keep last 60 data points for trend)
        _heartRateHistory.add(vitals.heartRateBpm.toDouble());
        _respRateHistory.add(vitals.respiratoryRateBpm.toDouble());

        if (_heartRateHistory.length > 60) _heartRateHistory.removeAt(0);
        if (_respRateHistory.length > 60) _respRateHistory.removeAt(0);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              // Surgery mode header
              _buildSurgeryHeader(),

              // Status bar
              Obx(
                () => SessionStatusBar(
                  collarId:
                      _sessionController.currentCollar.value?.serialNumber,
                  isConnected: _sessionController.isCollarConnected,
                  batteryPercent: _sessionController.batteryPercent.value,
                  signalQuality: _sessionController.signalQuality.value,
                ),
              ),

              // Main content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Real-time vitals
                      _buildVitalsSection(),

                      // Waveform display
                      _buildWaveformSection(),

                      // Trend charts
                      _buildTrendSection(),

                      // Quick annotations
                      _buildQuickAnnotations(),

                      // Recent annotations
                      _buildRecentAnnotations(),

                      const SizedBox(height: 100), // Space for bottom bar
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom action bar
          Positioned(left: 0, right: 0, bottom: 0, child: _buildBottomBar()),

          // Annotation panel overlay
          Obx(
            () => _showAnnotationPanel.value
                ? AnnotationPanel(
                    onClose: () => _showAnnotationPanel.value = false,
                    onAnnotationAdded: _onAnnotationAdded,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildSurgeryHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      decoration: const BoxDecoration(color: AppColors.surgeryRed),
      child: Row(
        children: [
          // Pulse indicator
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(
                    0.5 + (_pulseController.value * 0.5),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 12),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SURGERY IN PROGRESS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Obx(
                  () => Text(
                    'Raw Mode Active • ${_sessionController.phaseDuration.value}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // End surgery button
          TextButton(
            onPressed: _confirmEndSurgery,
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
            ),
            child: const Text('End Surgery'),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Obx(() {
        final vitals = _sessionController.latestVitals.value;
        final animal = _sessionController.currentAnimal.value;
        final ranges = animal?.vitalRanges;

        return Row(
          children: [
            // Heart Rate
            Expanded(
              child: _VitalDisplay(
                label: 'Heart Rate',
                value: vitals?.heartRateBpm ?? 0,
                unit: 'bpm',
                icon: Icons.favorite,
                color: AppColors.error,
                range: ranges?.heartRate,
              ),
            ),
            const SizedBox(width: 12),

            // Respiratory Rate
            Expanded(
              child: _VitalDisplay(
                label: 'Resp Rate',
                value: vitals?.respiratoryRateBpm ?? 0,
                unit: 'brpm',
                icon: Icons.air,
                color: AppColors.info,
                range: ranges?.respiratoryRate,
              ),
            ),
            const SizedBox(width: 12),

            // Temperature
            Expanded(
              child: _VitalDisplay(
                label: 'Temperature',
                value: vitals?.temperatureC ?? 0,
                unit: '°C',
                icon: Icons.thermostat,
                color: AppColors.warning,
                range: ranges?.temperature,
                isDecimal: true,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildWaveformSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 150,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: WaveformDisplay(
        title: 'BCG Waveform (Raw)',
        color: AppColors.surgeryRed,
      ),
    );
  }

  Widget _buildTrendSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          // HR Trend
          Expanded(
            child: _TrendChart(
              title: 'HR Trend',
              data: _heartRateHistory,
              color: AppColors.error,
              minY: 40,
              maxY: 200,
            ),
          ),
          const SizedBox(width: 12),

          // RR Trend
          Expanded(
            child: _TrendChart(
              title: 'RR Trend',
              data: _respRateHistory,
              color: AppColors.info,
              minY: 5,
              maxY: 50,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAnnotations() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Annotations', style: AppTypography.titleSmall),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Anesthesia events
              QuickAnnotationButton(
                label: 'Induction',
                emoji: '💉',
                onPressed: () => _quickAnnotation(
                  AnnotationCategory.anesthesia,
                  'induction',
                ),
              ),
              QuickAnnotationButton(
                label: 'Drug Given',
                emoji: '💊',
                onPressed: () => _quickAnnotation(
                  AnnotationCategory.medication,
                  'drug_administered',
                ),
              ),
              QuickAnnotationButton(
                label: 'Incision',
                emoji: '🔪',
                onPressed: () =>
                    _quickAnnotation(AnnotationCategory.surgical, 'incision'),
              ),
              QuickAnnotationButton(
                label: 'Bleeding',
                emoji: '🩸',
                onPressed: () => _quickAnnotation(
                  AnnotationCategory.surgical,
                  'bleeding_event',
                ),
              ),
              QuickAnnotationButton(
                label: 'Vomiting',
                emoji: '🤮',
                isEmergency: true,
                onPressed: () => _sessionController.addPhysiologicalEvent(
                  eventType: PhysiologicalEventType.vomiting,
                  severity: EventSeverityLevel.severe,
                ),
              ),
              QuickAnnotationButton(
                label: 'Arrhythmia',
                emoji: '💔',
                isEmergency: true,
                onPressed: () => _quickAnnotation(
                  AnnotationCategory.emergency,
                  'arrhythmia',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAnnotations() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Recent Annotations', style: AppTypography.titleSmall),
              const Spacer(),
              TextButton(
                onPressed: () => _showAnnotationPanel.value = true,
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Obx(() {
            final annotations = _sessionController.sessionAnnotations
                .take(3)
                .toList();

            if (annotations.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'No annotations yet',
                  style: AppTypography.bodySmall,
                ),
              );
            }

            return Column(
              children: annotations
                  .map((a) => _AnnotationTile(annotation: a))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Add annotation button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showAnnotationPanel.value = true,
              icon: const Icon(Icons.add_comment),
              label: const Text('Add Annotation'),
            ),
          ),
          const SizedBox(width: 12),

          // Voice note button
          IconButton(
            onPressed: _startVoiceNote,
            icon: const Icon(Icons.mic),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _quickAnnotation(AnnotationCategory category, String type) {
    _sessionController.addAnnotation(category: category, type: type);

    Get.snackbar(
      'Annotation Added',
      '${category.emoji} $type',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  void _onAnnotationAdded(Annotation annotation) {
    _showAnnotationPanel.value = false;

    Get.snackbar(
      'Annotation Added',
      annotation.displayTitle,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  void _startVoiceNote() {
    // TODO: Implement voice note recording
    Get.snackbar(
      'Voice Note',
      'Voice recording feature coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _confirmEndSurgery() {
    Get.dialog(
      AlertDialog(
        title: const Text('End Surgery?'),
        content: const Text(
          'This will transition to calibration phase. '
          'Make sure ECG is connected for calibration.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Continue Surgery'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final success = await _sessionController.endSurgery();
              if (success) {
                Get.offNamed(Routes.calibration);
              }
            },
            child: const Text('End Surgery'),
          ),
        ],
      ),
    );
  }
}

/// Large vital display widget
class _VitalDisplay extends StatelessWidget {
  final String label;
  final num value;
  final String unit;
  final IconData icon;
  final Color color;
  final VitalRange? range;
  final bool isDecimal;

  const _VitalDisplay({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    this.range,
    this.isDecimal = false,
  });

  @override
  Widget build(BuildContext context) {
    final isInRange = range?.isInRange(value.toDouble()) ?? true;
    final displayColor = isInRange ? color : AppColors.warning;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: displayColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: displayColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: displayColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(color: displayColor),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                isDecimal ? value.toStringAsFixed(1) : value.toString(),
                style: AppTypography.vitalValueLarge.copyWith(
                  color: displayColor,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                unit,
                style: AppTypography.vitalUnit.copyWith(color: displayColor),
              ),
            ],
          ),
          if (!isInRange)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.warning,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'OUT OF RANGE',
                style: AppTypography.badge.copyWith(fontSize: 8),
              ),
            ),
        ],
      ),
    );
  }
}

/// Mini trend chart widget
class _TrendChart extends StatelessWidget {
  final String title;
  final List<double> data;
  final Color color;
  final double minY;
  final double maxY;

  const _TrendChart({
    required this.title,
    required this.data,
    required this.color,
    required this.minY,
    required this.maxY,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.labelSmall),
          const SizedBox(height: 8),
          Expanded(
            child: data.isEmpty
                ? const Center(child: Text('--'))
                : LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: (data.length - 1).toDouble().clamp(
                        1,
                        double.infinity,
                      ),
                      minY: minY,
                      maxY: maxY,
                      lineBarsData: [
                        LineChartBarData(
                          spots: data.asMap().entries.map((e) {
                            return FlSpot(e.key.toDouble(), e.value);
                          }).toList(),
                          isCurved: true,
                          color: color,
                          barWidth: 2,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: color.withOpacity(0.1),
                          ),
                        ),
                      ],
                      lineTouchData: const LineTouchData(enabled: false),
                    ),
                    duration: Duration.zero,
                  ),
          ),
        ],
      ),
    );
  }
}

/// Annotation tile widget
class _AnnotationTile extends StatelessWidget {
  final Annotation annotation;

  const _AnnotationTile({required this.annotation});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(annotation.category.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(annotation.displayTitle, style: AppTypography.labelMedium),
                Text(
                  annotation.elapsedTimeFormatted,
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          if (annotation.severity == AnnotationSeverity.critical)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('CRITICAL', style: AppTypography.badge),
            ),
        ],
      ),
    );
  }
}
