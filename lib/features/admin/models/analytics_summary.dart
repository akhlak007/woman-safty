/// Platform-wide Key Performance Indicators and Analytics Summary
class PlatformKPIs {
  final int totalUsers;
  final int activeEmergencies;
  final int resolvedEmergencies;
  final double verifiedContactsCoverage; // Percentage e.g. 88.5
  final double avgResponseLatencySeconds; // Alert dispatch latency e.g. 4.2
  final double smsFallbackDeliveryRate; // Percentage e.g. 99.1

  const PlatformKPIs({
    required this.totalUsers,
    required this.activeEmergencies,
    required this.resolvedEmergencies,
    required this.verifiedContactsCoverage,
    required this.avgResponseLatencySeconds,
    required this.smsFallbackDeliveryRate,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalUsers': totalUsers,
      'activeEmergencies': activeEmergencies,
      'resolvedEmergencies': resolvedEmergencies,
      'verifiedContactsCoverage': verifiedContactsCoverage,
      'avgResponseLatencySeconds': avgResponseLatencySeconds,
      'smsFallbackDeliveryRate': smsFallbackDeliveryRate,
    };
  }

  factory PlatformKPIs.fromMap(Map<String, dynamic> map) {
    return PlatformKPIs(
      totalUsers: (map['totalUsers'] as num?)?.toInt() ?? 0,
      activeEmergencies: (map['activeEmergencies'] as num?)?.toInt() ?? 0,
      resolvedEmergencies: (map['resolvedEmergencies'] as num?)?.toInt() ?? 0,
      verifiedContactsCoverage: (map['verifiedContactsCoverage'] as num?)?.toDouble() ?? 0.0,
      avgResponseLatencySeconds: (map['avgResponseLatencySeconds'] as num?)?.toDouble() ?? 0.0,
      smsFallbackDeliveryRate: (map['smsFallbackDeliveryRate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Volume and percentage breakdown of emergency triggers
class EmergencyDistribution {
  final int safetyCount;
  final int cardiacCount;
  final int strokeCount;

  const EmergencyDistribution({
    required this.safetyCount,
    required this.cardiacCount,
    required this.strokeCount,
  });

  int get totalCount => safetyCount + cardiacCount + strokeCount;

  double get safetyPercent => totalCount > 0 ? (safetyCount / totalCount) * 100 : 0.0;
  double get cardiacPercent => totalCount > 0 ? (cardiacCount / totalCount) * 100 : 0.0;
  double get strokePercent => totalCount > 0 ? (strokeCount / totalCount) * 100 : 0.0;

  Map<String, dynamic> toMap() {
    return {
      'safetyCount': safetyCount,
      'cardiacCount': cardiacCount,
      'strokeCount': strokeCount,
    };
  }

  factory EmergencyDistribution.fromMap(Map<String, dynamic> map) {
    return EmergencyDistribution(
      safetyCount: (map['safetyCount'] as num?)?.toInt() ?? 0,
      cardiacCount: (map['cardiacCount'] as num?)?.toInt() ?? 0,
      strokeCount: (map['strokeCount'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Clinical and threat triage risk classification counts
class RiskSeverityBreakdown {
  final int lowCount;
  final int mediumCount;
  final int highCount;
  final int criticalCount;

  const RiskSeverityBreakdown({
    required this.lowCount,
    required this.mediumCount,
    required this.highCount,
    required this.criticalCount,
  });

  int get totalCount => lowCount + mediumCount + highCount + criticalCount;

  double get lowPercent => totalCount > 0 ? (lowCount / totalCount) * 100 : 0.0;
  double get mediumPercent => totalCount > 0 ? (mediumCount / totalCount) * 100 : 0.0;
  double get highPercent => totalCount > 0 ? (highCount / totalCount) * 100 : 0.0;
  double get criticalPercent => totalCount > 0 ? (criticalCount / totalCount) * 100 : 0.0;

  Map<String, dynamic> toMap() {
    return {
      'lowCount': lowCount,
      'mediumCount': mediumCount,
      'highCount': highCount,
      'criticalCount': criticalCount,
    };
  }

  factory RiskSeverityBreakdown.fromMap(Map<String, dynamic> map) {
    return RiskSeverityBreakdown(
      lowCount: (map['lowCount'] as num?)?.toInt() ?? 0,
      mediumCount: (map['mediumCount'] as num?)?.toInt() ?? 0,
      highCount: (map['highCount'] as num?)?.toInt() ?? 0,
      criticalCount: (map['criticalCount'] as num?)?.toInt() ?? 0,
    );
  }
}
