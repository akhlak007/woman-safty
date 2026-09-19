import 'package:flutter/material.dart';
import '../../core/constants/alert_constants.dart';

/// Custom ThemeExtension providing accessible risk-level styling
class RiskLevelTheme extends ThemeExtension<RiskLevelTheme> {
  final Color low;
  final Color onLow;
  final Color medium;
  final Color onMedium;
  final Color high;
  final Color onHigh;
  final Color critical;
  final Color onCritical;

  const RiskLevelTheme({
    required this.low,
    required this.onLow,
    required this.medium,
    required this.onMedium,
    required this.high,
    required this.onHigh,
    required this.critical,
    required this.onCritical,
  });

  /// Default light scheme colors
  static const RiskLevelTheme light = RiskLevelTheme(
    low: Color(0xFF2E7D32),
    onLow: Colors.white,
    medium: Color(0xFFF9A825),
    onMedium: Colors.black87,
    high: Color(0xFFEF6C00),
    onHigh: Colors.white,
    critical: Color(0xFFD32F2F),
    onCritical: Colors.white,
  );

  /// Default dark scheme colors
  static const RiskLevelTheme dark = RiskLevelTheme(
    low: Color(0xFF81C784),
    onLow: Colors.black87,
    medium: Color(0xFFFFD54F),
    onMedium: Colors.black87,
    high: Color(0xFFFFB74D),
    onHigh: Colors.black87,
    critical: Color(0xFFE57373),
    onCritical: Colors.black87,
  );

  Color getColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return low;
      case RiskLevel.medium:
        return medium;
      case RiskLevel.high:
        return high;
      case RiskLevel.critical:
        return critical;
    }
  }

  Color getOnColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return onLow;
      case RiskLevel.medium:
        return onMedium;
      case RiskLevel.high:
        return onHigh;
      case RiskLevel.critical:
        return onCritical;
    }
  }

  IconData getIcon(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return Icons.check_circle_outline_rounded;
      case RiskLevel.medium:
        return Icons.info_outline_rounded;
      case RiskLevel.high:
        return Icons.warning_amber_rounded;
      case RiskLevel.critical:
        return Icons.dangerous_rounded;
    }
  }

  @override
  ThemeExtension<RiskLevelTheme> copyWith({
    Color? low,
    Color? onLow,
    Color? medium,
    Color? onMedium,
    Color? high,
    Color? onHigh,
    Color? critical,
    Color? onCritical,
  }) {
    return RiskLevelTheme(
      low: low ?? this.low,
      onLow: onLow ?? this.onLow,
      medium: medium ?? this.medium,
      onMedium: onMedium ?? this.onMedium,
      high: high ?? this.high,
      onHigh: onHigh ?? this.onHigh,
      critical: critical ?? this.critical,
      onCritical: onCritical ?? this.onCritical,
    );
  }

  @override
  ThemeExtension<RiskLevelTheme> lerp(
    covariant ThemeExtension<RiskLevelTheme>? other,
    double t,
  ) {
    if (other is! RiskLevelTheme) return this;
    return RiskLevelTheme(
      low: Color.lerp(low, other.low, t) ?? low,
      onLow: Color.lerp(onLow, other.onLow, t) ?? onLow,
      medium: Color.lerp(medium, other.medium, t) ?? medium,
      onMedium: Color.lerp(onMedium, other.onMedium, t) ?? onMedium,
      high: Color.lerp(high, other.high, t) ?? high,
      onHigh: Color.lerp(onHigh, other.onHigh, t) ?? onHigh,
      critical: Color.lerp(critical, other.critical, t) ?? critical,
      onCritical: Color.lerp(onCritical, other.onCritical, t) ?? onCritical,
    );
  }
}
