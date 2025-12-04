import 'package:flutter/material.dart';

/// VetSync Clinical color palette
class AppColors {
  AppColors._();
  
  // Primary Brand Colors
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primarySurface = Color(0xFFEFF6FF);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF7C3AED);
  static const Color secondaryLight = Color(0xFF8B5CF6);
  static const Color secondaryDark = Color(0xFF6D28D9);
  
  // Status Colors
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFF4ADE80);
  static const Color successDark = Color(0xFF16A34A);
  static const Color successSurface = Color(0xFFDCFCE7);
  
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);
  static const Color warningSurface = Color(0xFFFEF3C7);
  
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);
  static const Color errorSurface = Color(0xFFFEE2E2);
  
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoDark = Color(0xFF2563EB);
  static const Color infoSurface = Color(0xFFDBEAFE);
  
  // Quality Indicator Colors
  static const Color qualityExcellent = Color(0xFF22C55E);
  static const Color qualityGood = Color(0xFF84CC16);
  static const Color qualityFair = Color(0xFFF59E0B);
  static const Color qualityPoor = Color(0xFFEF4444);
  
  // Battery Colors
  static const Color batteryFull = Color(0xFF22C55E);
  static const Color batteryMedium = Color(0xFFF59E0B);
  static const Color batteryLow = Color(0xFFEF4444);
  static const Color batteryCritical = Color(0xFF991B1B);
  
  // Surgery Mode
  static const Color surgeryRed = Color(0xFFDC2626);
  static const Color surgeryBanner = Color(0xFFFEE2E2);
  static const Color surgeryText = Color(0xFF991B1B);
  
  // Pre-Surgery Mode
  static const Color preSurgeryBanner = Color(0xFFDBEAFE);
  
  // Recovery Mode
  static const Color recoveryGreen = Color(0xFF16A34A);
  static const Color recoveryBanner = Color(0xFFDCFCE7);
  
  // Backgrounds
  static const Color background = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color surfaceVariantDark = Color(0xFF334155);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFF94A3B8);
  static const Color textDisabledDark = Color(0xFF64748B);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnError = Color(0xFFFFFFFF);
  
  // Border Colors
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF475569);
  static const Color borderFocused = Color(0xFF3B82F6);
  static const Color borderError = Color(0xFFEF4444);
  
  // Divider
  static const Color divider = Color(0xFFE2E8F0);
  static const Color dividerDark = Color(0xFF334155);
  
  // Shadow
  static const Color shadow = Color(0x1A000000);
  static const Color shadowDark = Color(0x40000000);
  
  // Shimmer
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF8FAFC);
  
  // Chart Colors
  static const Color chartLine1 = Color(0xFF3B82F6);
  static const Color chartLine2 = Color(0xFF22C55E);
  static const Color chartLine3 = Color(0xFFF59E0B);
  static const Color chartGrid = Color(0xFFE2E8F0);
  static const Color chartBackground = Color(0xFFF8FAFC);
  
  // Annotation Category Colors
  static const Color annotationAnesthesia = Color(0xFF8B5CF6);
  static const Color annotationMedication = Color(0xFF06B6D4);
  static const Color annotationPreparation = Color(0xFF84CC16);
  static const Color annotationSurgical = Color(0xFFEF4444);
  static const Color annotationEvent = Color(0xFFF59E0B);
  static const Color annotationRecovery = Color(0xFF22C55E);
  static const Color annotationBehavior = Color(0xFF3B82F6);
  static const Color annotationPhysiological = Color(0xFFEC4899);
  static const Color annotationEmergency = Color(0xFFDC2626);
  static const Color annotationSystem = Color(0xFF64748B);
  
  // Connection Status
  static const Color connected = Color(0xFF22C55E);
  static const Color connecting = Color(0xFFF59E0B);
  static const Color disconnected = Color(0xFFEF4444);
  
  // Transparent
  static const Color transparent = Colors.transparent;
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  
  /// Get quality color based on percentage
  static Color getQualityColor(int quality) {
    if (quality >= 75) return qualityExcellent;
    if (quality >= 50) return qualityFair;
    return qualityPoor;
  }
  
  /// Get battery color based on percentage
  static Color getBatteryColor(int percent) {
    if (percent > 50) return batteryFull;
    if (percent > 20) return batteryMedium;
    if (percent > 10) return batteryLow;
    return batteryCritical;
  }
  
  /// Get annotation category color
  static Color getAnnotationColor(String category) {
    switch (category) {
      case 'anesthesia':
        return annotationAnesthesia;
      case 'medication':
        return annotationMedication;
      case 'preparation':
        return annotationPreparation;
      case 'surgical':
        return annotationSurgical;
      case 'event':
        return annotationEvent;
      case 'recovery':
        return annotationRecovery;
      case 'behavior':
        return annotationBehavior;
      case 'physiological':
        return annotationPhysiological;
      case 'emergency':
        return annotationEmergency;
      case 'system':
      default:
        return annotationSystem;
    }
  }
}
