import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../app/themes/app_colors.dart';
import '../../data/models/models.dart';
import '../../data/services/ble_service.dart';

/// Real-time waveform display widget for BCG/ECG signals
class WaveformDisplay extends StatefulWidget {
  final String title;
  final Color color;
  final double height;
  final int maxDataPoints;
  final bool showGrid;
  final bool autoScale;

  const WaveformDisplay({
    super.key,
    required this.title,
    this.color = AppColors.primary,
    this.height = 120,
    this.maxDataPoints = 200,
    this.showGrid = true,
    this.autoScale = true,
  });

  @override
  State<WaveformDisplay> createState() => _WaveformDisplayState();
}

class _WaveformDisplayState extends State<WaveformDisplay> {
  final BleService _bleService = Get.find<BleService>();
  final List<FlSpot> _dataPoints = [];
  StreamSubscription<CollarDataPacket>? _dataSubscription;
  int _sampleIndex = 0;
  double _minY = -1000;
  double _maxY = 1000;

  @override
  void initState() {
    super.initState();
    _setupDataStream();
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    super.dispose();
  }

  void _setupDataStream() {
    _dataSubscription = _bleService.dataStream.listen((packet) {
      if (!mounted) return;

      setState(() {
        // Add new data point from packet
        // pressureRaw is int? and pressureFiltered is int
        final int sample = packet.pressureRaw ?? packet.pressureFiltered;

        _dataPoints.add(FlSpot(_sampleIndex.toDouble(), sample.toDouble()));
        _sampleIndex++;

        // Update Y bounds if auto-scaling
        if (widget.autoScale) {
          if (sample < _minY) _minY = sample.toDouble();
          if (sample > _maxY) _maxY = sample.toDouble();
        }

        // Keep only the latest maxDataPoints
        while (_dataPoints.length > widget.maxDataPoints) {
          _dataPoints.removeAt(0);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  color: widget.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              // Signal indicator
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _dataPoints.isNotEmpty
                      ? AppColors.success
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // Waveform chart
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
            child: _dataPoints.isEmpty
                ? Center(
                    child: Text(
                      'Waiting for data...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: widget.showGrid,
                        drawVerticalLine: false,
                        horizontalInterval: (_maxY - _minY) / 4,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: AppColors.border.withValues(alpha: 0.3),
                            strokeWidth: 0.5,
                          );
                        },
                      ),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _dataPoints,
                          isCurved: false,
                          color: widget.color,
                          barWidth: 1.5,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: widget.color.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                      minY: _minY - ((_maxY - _minY) * 0.1),
                      maxY: _maxY + ((_maxY - _minY) * 0.1),
                      lineTouchData: const LineTouchData(enabled: false),
                      clipData: const FlClipData.all(),
                    ),
                    duration: Duration.zero,
                  ),
          ),
        ),
      ],
    );
  }
}

/// Static waveform display for showing recorded/historical data
class StaticWaveformDisplay extends StatelessWidget {
  final String title;
  final List<double> data;
  final Color color;
  final double height;
  final bool showGrid;

  const StaticWaveformDisplay({
    super.key,
    required this.title,
    required this.data,
    this.color = AppColors.primary,
    this.height = 120,
    this.showGrid = true,
  });

  @override
  Widget build(BuildContext context) {
    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    double minY = data.isEmpty ? -1 : data.reduce((a, b) => a < b ? a : b);
    double maxY = data.isEmpty ? 1 : data.reduce((a, b) => a > b ? a : b);

    // Ensure some range
    if (maxY - minY < 0.01) {
      minY -= 0.5;
      maxY += 0.5;
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
              child: spots.isEmpty
                  ? Center(
                      child: Text(
                        'No data',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: showGrid,
                          drawVerticalLine: false,
                          horizontalInterval: (maxY - minY) / 4,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: AppColors.border.withValues(alpha: 0.3),
                              strokeWidth: 0.5,
                            );
                          },
                        ),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: false,
                            color: color,
                            barWidth: 1.5,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: color.withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                        minY: minY - ((maxY - minY) * 0.1),
                        maxY: maxY + ((maxY - minY) * 0.1),
                        lineTouchData: const LineTouchData(enabled: false),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
