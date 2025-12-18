// lib/widgets/vital_signs_display.dart
import 'package:flutter/material.dart';
import '../core/algorithms/bcg_algorithm.dart';
import '../services/bcg_service.dart';

/// Main vital signs display widget
/// Shows HR, RR, Temperature, and Signal Quality with color-coded indicators
class VitalSignsDisplay extends StatelessWidget {
  final BcgResult? bcgResult;
  final double? temperatureCelsius;
  final int? signalQuality;
  final VoidCallback? onRefresh;

  const VitalSignsDisplay({
    Key? key,
    this.bcgResult,
    this.temperatureCelsius,
    this.signalQuality,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Waiting for data state
    if (bcgResult == null || !bcgResult!.isValid) {
      return _buildWaitingState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header with quality indicator
        _buildHeader(context),

        const SizedBox(height: 16),

        // Main vitals grid
        _buildVitalsGrid(context),

        // Signal quality warning (if needed)
        if (bcgResult!.qualityLevel == QualityLevel.poor ||
            bcgResult!.qualityLevel == QualityLevel.fair)
          _buildQualityWarning(context),
      ],
    );
  }

  Widget _buildWaitingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Collecting data...',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Minimum 5 seconds required',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
          ),
          if (onRefresh != null) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final quality = bcgResult!.qualityLevel;
    final color = _getQualityColor(quality);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(_getQualityIcon(quality), color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              bcgResult!.qualityMessage,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          if (onRefresh != null)
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              onPressed: onRefresh,
              color: Colors.grey[600],
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  Widget _buildVitalsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        // Heart Rate
        VitalSignCard(
          icon: Icons.monitor_heart_outlined,
          label: 'Heart Rate',
          value: '${bcgResult!.heartRateBpm}',
          unit: 'BPM',
          confidence: bcgResult!.hrConfidence,
          isPlausible: bcgResult!.isHeartRatePlausible,
          color: Colors.red,
          normalRange: '60-180 BPM',
        ),

        // Respiratory Rate
        VitalSignCard(
          icon: Icons.air,
          label: 'Respiratory Rate',
          value: '${bcgResult!.respiratoryRateBpm}',
          unit: 'BPM',
          confidence: bcgResult!.rrConfidence,
          isPlausible: bcgResult!.isRespiratoryRatePlausible,
          color: Colors.blue,
          normalRange: '10-40 BPM',
        ),

        // Temperature
        VitalSignCard(
          icon: Icons.thermostat,
          label: 'Temperature',
          value: temperatureCelsius?.toStringAsFixed(1) ?? '--',
          unit: '°C',
          confidence: 1.0, // Temperature is always reliable
          isPlausible:
              temperatureCelsius != null &&
              temperatureCelsius! >= 30 &&
              temperatureCelsius! <= 50,
          color: Colors.orange,
          normalRange: '37.5-39.5°C',
        ),

        // Signal Quality
        VitalSignCard(
          icon: Icons.signal_cellular_alt,
          label: 'Signal Quality',
          value: '${bcgResult!.signalQuality}',
          unit: '%',
          confidence: bcgResult!.signalQuality / 100,
          isPlausible: true,
          color: Colors.green,
          normalRange: '>60%',
        ),
      ],
    );
  }

  Widget _buildQualityWarning(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.amber[800], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Check collar fit and position. Values may be inaccurate.',
              style: TextStyle(color: Colors.amber[900], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Color _getQualityColor(QualityLevel level) {
    switch (level) {
      case QualityLevel.poor:
        return Colors.red;
      case QualityLevel.fair:
        return Colors.orange;
      case QualityLevel.good:
        return Colors.blue;
      case QualityLevel.excellent:
        return Colors.green;
    }
  }

  IconData _getQualityIcon(QualityLevel level) {
    switch (level) {
      case QualityLevel.poor:
        return Icons.error;
      case QualityLevel.fair:
        return Icons.warning;
      case QualityLevel.good:
        return Icons.check_circle;
      case QualityLevel.excellent:
        return Icons.verified;
    }
  }
}

/// Individual vital sign card
class VitalSignCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final double confidence;
  final bool isPlausible;
  final Color color;
  final String? normalRange;

  const VitalSignCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.confidence,
    required this.isPlausible,
    required this.color,
    this.normalRange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final opacity = isPlausible ? 1.0 : 0.5;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.2), width: 2),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and label
            Row(
              children: [
                Icon(icon, color: color.withOpacity(opacity), size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!isPlausible)
                  Icon(Icons.warning_amber, color: Colors.orange, size: 16),
              ],
            ),

            const Spacer(),

            // Value
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: color.withOpacity(opacity),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // Confidence indicator
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: confidence,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      color.withOpacity(opacity),
                    ),
                    minHeight: 3,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(confidence * 100).toInt()}%',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),

            // Normal range hint
            if (normalRange != null) ...[
              const SizedBox(height: 4),
              Text(
                'Normal: $normalRange',
                style: TextStyle(fontSize: 9, color: Colors.grey[500]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
