import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/analytics_summary.dart';
import '../models/incident_hotspot.dart';

class AdminAnalyticsRepository {
  final FirebaseFirestore? firestore;

  const AdminAnalyticsRepository({this.firestore});

  FirebaseFirestore get _db => firestore ?? FirebaseFirestore.instance;

  static const List<IncidentHotspot> seededHotspots = [
    IncidentHotspot(
      id: 'hs_dhanmondi',
      areaName: 'Dhanmondi (R/A & Lake)',
      banglaName: 'ধানমন্ডি (আবাসিক ও লেক)',
      latitude: 23.7461,
      longitude: 90.3742,
      totalIncidents: 64,
      safetyIncidents: 42,
      medicalIncidents: 22,
      threatLevel: ThreatLevel.high,
    ),
    IncidentHotspot(
      id: 'hs_gulshan',
      areaName: 'Gulshan & Banani Hub',
      banglaName: 'গুলশান ও বনানী হাব',
      latitude: 23.7925,
      longitude: 90.4078,
      totalIncidents: 38,
      safetyIncidents: 20,
      medicalIncidents: 18,
      threatLevel: ThreatLevel.moderate,
    ),
    IncidentHotspot(
      id: 'hs_mirpur',
      areaName: 'Mirpur 10 & Commercial',
      banglaName: 'মিরপুর ১০ ও বাণিজ্যিক অঞ্চল',
      latitude: 23.8071,
      longitude: 90.3686,
      totalIncidents: 82,
      safetyIncidents: 56,
      medicalIncidents: 26,
      threatLevel: ThreatLevel.critical,
    ),
    IncidentHotspot(
      id: 'hs_old_dhaka',
      areaName: 'Old Dhaka & Sadarghat',
      banglaName: 'পুরান ঢাকা ও সদরঘাট',
      latitude: 23.7099,
      longitude: 90.4071,
      totalIncidents: 74,
      safetyIncidents: 46,
      medicalIncidents: 28,
      threatLevel: ThreatLevel.critical,
    ),
    IncidentHotspot(
      id: 'hs_uttara',
      areaName: 'Uttara (Sectors 3, 7, 11)',
      banglaName: 'উত্তরা (সেক্টর ৩, ৭, ১১)',
      latitude: 23.8759,
      longitude: 90.3795,
      totalIncidents: 45,
      safetyIncidents: 31,
      medicalIncidents: 14,
      threatLevel: ThreatLevel.moderate,
    ),
    IncidentHotspot(
      id: 'hs_mohakhali',
      areaName: 'Mohakhali & Tejgaon Link',
      banglaName: 'মহাখালী ও তেজগাঁও লিংক রোড',
      latitude: 23.7772,
      longitude: 90.4024,
      totalIncidents: 58,
      safetyIncidents: 34,
      medicalIncidents: 24,
      threatLevel: ThreatLevel.high,
    ),
    IncidentHotspot(
      id: 'hs_motijheel',
      areaName: 'Motijheel Commercial Area',
      banglaName: 'মতিঝিল বাণিজ্যিক এলাকা',
      latitude: 23.7330,
      longitude: 90.4172,
      totalIncidents: 29,
      safetyIncidents: 15,
      medicalIncidents: 14,
      threatLevel: ThreatLevel.low,
    ),
  ];

  /// Fetch Platform Key Performance Indicators
  Future<PlatformKPIs> getPlatformKPIs() async {
    try {
      final doc = await _db.collection('analytics').doc('platform_summary').get();
      if (doc.exists && doc.data() != null) {
        return PlatformKPIs.fromMap(doc.data()!);
      }
    } catch (_) {
      // Use seeded baseline metrics for thesis evaluation & testing
    }

    return const PlatformKPIs(
      totalUsers: 1280,
      activeEmergencies: 3,
      resolvedEmergencies: 342,
      verifiedContactsCoverage: 91.4,
      avgResponseLatencySeconds: 3.8,
      smsFallbackDeliveryRate: 99.2,
    );
  }

  /// Emergency Distribution by Category
  Future<EmergencyDistribution> getEmergencyDistribution() async {
    try {
      final doc = await _db.collection('analytics').doc('emergency_distribution').get();
      if (doc.exists && doc.data() != null) {
        return EmergencyDistribution.fromMap(doc.data()!);
      }
    } catch (_) {}

    return const EmergencyDistribution(
      safetyCount: 168,
      cardiacCount: 108,
      strokeCount: 66,
    );
  }

  /// Risk Severity Distribution
  Future<RiskSeverityBreakdown> getRiskSeverityBreakdown() async {
    try {
      final doc = await _db.collection('analytics').doc('severity_breakdown').get();
      if (doc.exists && doc.data() != null) {
        return RiskSeverityBreakdown.fromMap(doc.data()!);
      }
    } catch (_) {}

    return const RiskSeverityBreakdown(
      lowCount: 48,
      mediumCount: 112,
      highCount: 106,
      criticalCount: 76,
    );
  }

  /// List of regional Dhaka hotspots
  Future<List<IncidentHotspot>> getDhakaHotspots() async {
    try {
      final snap = await _db.collection('incidentHotspots').get();
      if (snap.docs.isNotEmpty) {
        return snap.docs.map((d) => IncidentHotspot.fromMap(d.data(), d.id)).toList();
      }
    } catch (_) {}

    return seededHotspots;
  }
}
