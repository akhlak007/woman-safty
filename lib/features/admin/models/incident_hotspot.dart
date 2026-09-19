enum ThreatLevel {
  low,
  moderate,
  high,
  critical;

  String get label {
    switch (this) {
      case ThreatLevel.low:
        return 'Low Activity';
      case ThreatLevel.moderate:
        return 'Moderate Activity';
      case ThreatLevel.high:
        return 'High Density';
      case ThreatLevel.critical:
        return 'Critical Hotspot';
    }
  }

  String get banglaLabel {
    switch (this) {
      case ThreatLevel.low:
        return 'স্বল্প প্রবণতা';
      case ThreatLevel.moderate:
        return 'মাঝারি প্রবণতা';
      case ThreatLevel.high:
        return 'উচ্চ ঘনত্ব';
      case ThreatLevel.critical:
        return 'সংবেদনশীল হটস্পট';
    }
  }
}

/// Anonymized regional geographic emergency cluster in Dhaka
class IncidentHotspot {
  final String id;
  final String areaName;
  final String banglaName;
  final double latitude;
  final double longitude;
  final int totalIncidents;
  final int safetyIncidents;
  final int medicalIncidents;
  final ThreatLevel threatLevel;

  const IncidentHotspot({
    required this.id,
    required this.areaName,
    required this.banglaName,
    required this.latitude,
    required this.longitude,
    required this.totalIncidents,
    required this.safetyIncidents,
    required this.medicalIncidents,
    required this.threatLevel,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'areaName': areaName,
      'banglaName': banglaName,
      'latitude': latitude,
      'longitude': longitude,
      'totalIncidents': totalIncidents,
      'safetyIncidents': safetyIncidents,
      'medicalIncidents': medicalIncidents,
      'threatLevel': threatLevel.name,
    };
  }

  factory IncidentHotspot.fromMap(Map<String, dynamic> map, String id) {
    ThreatLevel level = ThreatLevel.moderate;
    final levelStr = map['threatLevel'] as String?;
    if (levelStr != null) {
      level = ThreatLevel.values.firstWhere(
        (e) => e.name == levelStr,
        orElse: () => ThreatLevel.moderate,
      );
    }

    return IncidentHotspot(
      id: id,
      areaName: map['areaName'] as String? ?? 'Dhaka Area',
      banglaName: map['banglaName'] as String? ?? 'ঢাকা এলাকা',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 23.8103,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 90.4125,
      totalIncidents: (map['totalIncidents'] as num?)?.toInt() ?? 0,
      safetyIncidents: (map['safetyIncidents'] as num?)?.toInt() ?? 0,
      medicalIncidents: (map['medicalIncidents'] as num?)?.toInt() ?? 0,
      threatLevel: level,
    );
  }
}
