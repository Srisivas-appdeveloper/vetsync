import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../presentation/controllers/monitoring_controller.dart';

class BCGWaveformWidget extends StatelessWidget {
  final MonitoringController controller;

  const BCGWaveformWidget({Key? key, required this.controller})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final spots = controller.waveformSpots;

      if (spots.isEmpty) {
        return Center(
          child: Text(
            'Waiting for waveform data...',
            style: TextStyle(color: Colors.grey),
          ),
        );
      }

      return LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              color: Colors.blue,
              barWidth: 2,
              dotData: FlDotData(show: false),
            ),
          ],
          minY: -5000, // Approximate range for BCG sensor
          maxY: 5000,
        ),
      );
    });
  }
}
