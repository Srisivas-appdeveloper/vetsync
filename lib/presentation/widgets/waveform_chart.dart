import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../app/themes/app_colors.dart';
import '../../app/themes/app_typography.dart';

/// Real-time waveform display widget for BCG/ECG signals
class RealtimeWaveformChart extends StatefulWidget {
  /// Stream of data points to display
  final Stream<double>? dataStream;

  /// Number of seconds of data to display
  final int displaySeconds;

  /// Sample rate of incoming data (Hz)
  final int sampleRate;

  /// Y-axis range
  final double minY;
  final double maxY;

  /// Chart title
  final String? title;

  /// Line color
  final Color lineColor;

  /// Grid color
  final Color gridColor;

  /// Background color
  final Color backgroundColor;

  /// Whether to show grid
  final bool showGrid;

  /// Line width
  final double lineWidth;

  /// Whether chart is paused
  final bool isPaused;

  /// Callback when chart is tapped
  final VoidCallback? onTap;

  const RealtimeWaveformChart({
    super.key,
    this.dataStream,
    this.displaySeconds = 10,
    this.sampleRate = 100,
    this.minY = -1.0,
    this.maxY = 1.0,
    this.title,
    this.lineColor = AppColors.primary,
    this.gridColor = const Color(0x20000000),
    this.backgroundColor = Colors.transparent,
    this.showGrid = true,
    this.lineWidth = 1.5,
    this.isPaused = false,
    this.onTap,
  });

  @override
  State<RealtimeWaveformChart> createState() => _RealtimeWaveformChartState();
}

class _RealtimeWaveformChartState extends State<RealtimeWaveformChart> {
  late Queue<FlSpot> _dataPoints;
  late int _maxPoints;
  StreamSubscription<double>? _subscription;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _maxPoints = widget.displaySeconds * widget.sampleRate;
    _dataPoints = Queue<FlSpot>();
    _subscribeToStream();
  }

  @override
  void didUpdateWidget(RealtimeWaveformChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.dataStream != oldWidget.dataStream) {
      _subscription?.cancel();
      _subscribeToStream();
    }

    if (widget.displaySeconds != oldWidget.displaySeconds ||
        widget.sampleRate != oldWidget.sampleRate) {
      _maxPoints = widget.displaySeconds * widget.sampleRate;
      _trimDataPoints();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _subscribeToStream() {
    if (widget.dataStream == null) return;

    _subscription = widget.dataStream!.listen((value) {
      if (widget.isPaused) return;

      setState(() {
        _dataPoints.addLast(FlSpot(_currentIndex.toDouble(), value));
        _currentIndex++;
        _trimDataPoints();
      });
    });
  }

  void _trimDataPoints() {
    while (_dataPoints.length > _maxPoints) {
      _dataPoints.removeFirst();
    }
  }

  /// Add a single data point programmatically
  void addDataPoint(double value) {
    if (widget.isPaused) return;

    setState(() {
      _dataPoints.addLast(FlSpot(_currentIndex.toDouble(), value));
      _currentIndex++;
      _trimDataPoints();
    });
  }

  /// Add multiple data points
  void addDataPoints(List<double> values) {
    if (widget.isPaused) return;

    setState(() {
      for (final value in values) {
        _dataPoints.addLast(FlSpot(_currentIndex.toDouble(), value));
        _currentIndex++;
      }
      _trimDataPoints();
    });
  }

  /// Clear all data points
  void clear() {
    setState(() {
      _dataPoints.clear();
      _currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.title != null)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 8, bottom: 4),
                child: Row(
                  children: [
                    Text(widget.title!, style: AppTypography.labelSmall),
                    if (widget.isPaused) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('PAUSED', style: AppTypography.badge),
                      ),
                    ],
                  ],
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: _buildChart(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    if (_dataPoints.isEmpty) {
      return Center(
        child: Text(
          'Waiting for data...',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    final spots = _dataPoints.toList();

    // Calculate x-axis range
    final minX = spots.isNotEmpty ? spots.first.x : 0;
    final maxX = spots.isNotEmpty ? spots.last.x : _maxPoints.toDouble();

    return LineChart(
      LineChartData(
        // minX: minX,
        maxX: maxX,
        minY: widget.minY,
        maxY: widget.maxY,
        clipData: const FlClipData.all(),
        lineTouchData: const LineTouchData(enabled: false),
        titlesData: const FlTitlesData(show: false),
        gridData: FlGridData(
          show: widget.showGrid,
          drawVerticalLine: true,
          drawHorizontalLine: true,
          horizontalInterval: (widget.maxY - widget.minY) / 4,
          verticalInterval: widget.sampleRate.toDouble(), // 1 second intervals
          getDrawingHorizontalLine: (value) =>
              FlLine(color: widget.gridColor, strokeWidth: 0.5),
          getDrawingVerticalLine: (value) =>
              FlLine(color: widget.gridColor, strokeWidth: 0.5),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: widget.gridColor, width: 1),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.2,
            color: widget.lineColor,
            barWidth: widget.lineWidth,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
      duration: Duration.zero, // Disable animation for real-time
    );
  }
}

/// Dual waveform chart for BCG + ECG comparison during calibration
class DualWaveformChart extends StatelessWidget {
  final Stream<double>? bcgStream;
  final Stream<double>? ecgStream;
  final int displaySeconds;
  final int bcgSampleRate;
  final int ecgSampleRate;
  final bool isPaused;

  const DualWaveformChart({
    super.key,
    this.bcgStream,
    this.ecgStream,
    this.displaySeconds = 10,
    this.bcgSampleRate = 128,
    this.ecgSampleRate = 1000,
    this.isPaused = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ECG Chart (top)
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: RealtimeWaveformChart(
              dataStream: ecgStream,
              displaySeconds: displaySeconds,
              sampleRate: ecgSampleRate,
              minY: -1.5,
              maxY: 1.5,
              title: 'ECG (Ground Truth)',
              lineColor: AppColors.error,
              isPaused: isPaused,
            ),
          ),
        ),

        // BCG Chart (bottom)
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: RealtimeWaveformChart(
              dataStream: bcgStream,
              displaySeconds: displaySeconds,
              sampleRate: bcgSampleRate,
              minY: -1.0,
              maxY: 1.0,
              title: 'BCG (Collar)',
              lineColor: AppColors.primary,
              isPaused: isPaused,
            ),
          ),
        ),
      ],
    );
  }
}

/// Vitals trend chart - shows HR/RR over time
class VitalsTrendChart extends StatelessWidget {
  final List<VitalDataPoint> heartRateData;
  final List<VitalDataPoint> respiratoryRateData;
  final double? hrMin;
  final double? hrMax;
  final double? rrMin;
  final double? rrMax;
  final Duration displayDuration;

  const VitalsTrendChart({
    super.key,
    required this.heartRateData,
    required this.respiratoryRateData,
    this.hrMin,
    this.hrMax,
    this.rrMin,
    this.rrMax,
    this.displayDuration = const Duration(minutes: 30),
  });

  @override
  Widget build(BuildContext context) {
    if (heartRateData.isEmpty && respiratoryRateData.isEmpty) {
      return Center(
        child: Text(
          'No trend data available',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    // Calculate time range
    final now = DateTime.now();
    final minTime = now.subtract(displayDuration);

    // Filter data to display range
    final hrPoints = heartRateData
        .where((p) => p.timestamp.isAfter(minTime))
        .map(
          (p) => FlSpot(p.timestamp.millisecondsSinceEpoch.toDouble(), p.value),
        )
        .toList();

    final rrPoints = respiratoryRateData
        .where((p) => p.timestamp.isAfter(minTime))
        .map(
          (p) => FlSpot(p.timestamp.millisecondsSinceEpoch.toDouble(), p.value),
        )
        .toList();

    return LineChart(
      LineChartData(
        minX: minTime.millisecondsSinceEpoch.toDouble(),
        maxX: now.millisecondsSinceEpoch.toDouble(),
        minY: 0,
        maxY: 200,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            // getTooltipColor: (spot) => AppColors.surfaceVariant,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final isHR = spot.barIndex == 0;
                return LineTooltipItem(
                  '${spot.y.round()} ${isHR ? 'bpm' : 'brpm'}',
                  AppTypography.labelSmall.copyWith(
                    color: isHR ? AppColors.error : AppColors.primary,
                  ),
                );
              }).toList();
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: AppTypography.caption,
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: displayDuration.inMilliseconds / 4,
              getTitlesWidget: (value, meta) {
                final time = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return Text(
                  '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                  style: AppTypography.caption,
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 40,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: AppColors.border, strokeWidth: 0.5),
          getDrawingVerticalLine: (value) =>
              FlLine(color: AppColors.border, strokeWidth: 0.5),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: AppColors.border),
        ),
        lineBarsData: [
          // Heart rate line
          if (hrPoints.isNotEmpty)
            LineChartBarData(
              spots: hrPoints,
              isCurved: true,
              curveSmoothness: 0.3,
              color: AppColors.error,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.error.withOpacity(0.1),
              ),
            ),

          // Respiratory rate line
          if (rrPoints.isNotEmpty)
            LineChartBarData(
              spots: rrPoints,
              isCurved: true,
              curveSmoothness: 0.3,
              color: AppColors.primary,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
        ],
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            // HR normal range
            if (hrMin != null)
              HorizontalLine(
                y: hrMin!,
                color: AppColors.error.withOpacity(0.3),
                strokeWidth: 1,
                dashArray: [5, 5],
              ),
            if (hrMax != null)
              HorizontalLine(
                y: hrMax!,
                color: AppColors.error.withOpacity(0.3),
                strokeWidth: 1,
                dashArray: [5, 5],
              ),
          ],
        ),
      ),
    );
  }
}

/// Single vital data point
class VitalDataPoint {
  final DateTime timestamp;
  final double value;

  VitalDataPoint({required this.timestamp, required this.value});
}

/// Quality indicator bar
class SignalQualityBar extends StatelessWidget {
  final int quality;
  final double height;

  const SignalQualityBar({super.key, required this.quality, this.height = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: quality / 100,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.getQualityColor(quality),
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}
