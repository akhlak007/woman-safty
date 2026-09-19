import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safelife/app/app.dart';
import 'package:safelife/features/admin/models/analytics_summary.dart';
import 'package:safelife/features/admin/models/incident_hotspot.dart';
import 'package:safelife/features/admin/repositories/admin_analytics_repository.dart';
import 'package:safelife/features/admin/screens/admin_dashboard_screen.dart';

class FakeAdminAnalyticsRepository extends AdminAnalyticsRepository {
  final PlatformKPIs? customKPIs;
  final EmergencyDistribution? customDist;
  final RiskSeverityBreakdown? customSeverity;
  final List<IncidentHotspot>? customHotspots;

  const FakeAdminAnalyticsRepository({
    this.customKPIs,
    this.customDist,
    this.customSeverity,
    this.customHotspots,
  });

  @override
  Future<PlatformKPIs> getPlatformKPIs() async {
    return customKPIs ??
        const PlatformKPIs(
          totalUsers: 1280,
          activeEmergencies: 3,
          resolvedEmergencies: 342,
          verifiedContactsCoverage: 91.4,
          avgResponseLatencySeconds: 3.8,
          smsFallbackDeliveryRate: 99.2,
        );
  }

  @override
  Future<EmergencyDistribution> getEmergencyDistribution() async {
    return customDist ??
        const EmergencyDistribution(
          safetyCount: 168,
          cardiacCount: 108,
          strokeCount: 66,
        );
  }

  @override
  Future<RiskSeverityBreakdown> getRiskSeverityBreakdown() async {
    return customSeverity ??
        const RiskSeverityBreakdown(
          lowCount: 48,
          mediumCount: 112,
          highCount: 106,
          criticalCount: 76,
        );
  }

  @override
  Future<List<IncidentHotspot>> getDhakaHotspots() async {
    return customHotspots ?? AdminAnalyticsRepository.seededHotspots;
  }
}

Widget createAdminTestApp({AdminAnalyticsRepository? repository}) {
  return SafeLifeApp(
    initialLocale: const Locale('en'),
    home: AdminDashboardScreen(
      repository: repository ?? const FakeAdminAnalyticsRepository(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('PlatformKPIs Model Tests', () {
    test('PlatformKPIs serialization and deserialization', () {
      const kpis = PlatformKPIs(
        totalUsers: 2500,
        activeEmergencies: 5,
        resolvedEmergencies: 1200,
        verifiedContactsCoverage: 92.5,
        avgResponseLatencySeconds: 3.5,
        smsFallbackDeliveryRate: 99.4,
      );

      final map = kpis.toMap();
      expect(map['totalUsers'], 2500);
      expect(map['activeEmergencies'], 5);
      expect(map['resolvedEmergencies'], 1200);
      expect(map['verifiedContactsCoverage'], 92.5);
      expect(map['avgResponseLatencySeconds'], 3.5);
      expect(map['smsFallbackDeliveryRate'], 99.4);

      final fromMap = PlatformKPIs.fromMap(map);
      expect(fromMap.totalUsers, 2500);
      expect(fromMap.activeEmergencies, 5);
      expect(fromMap.resolvedEmergencies, 1200);
      expect(fromMap.verifiedContactsCoverage, 92.5);
      expect(fromMap.avgResponseLatencySeconds, 3.5);
      expect(fromMap.smsFallbackDeliveryRate, 99.4);
    });

    test('PlatformKPIs fallback defaults on empty map', () {
      final fallback = PlatformKPIs.fromMap({});
      expect(fallback.totalUsers, 0);
      expect(fallback.activeEmergencies, 0);
      expect(fallback.resolvedEmergencies, 0);
      expect(fallback.verifiedContactsCoverage, 0.0);
    });
  });

  group('EmergencyDistribution Model Tests', () {
    test('EmergencyDistribution percentages and total calculation', () {
      const dist = EmergencyDistribution(
        safetyCount: 25,
        cardiacCount: 50,
        strokeCount: 25,
      );

      expect(dist.totalCount, 100);
      expect(dist.cardiacPercent, 50.0);
      expect(dist.strokePercent, 25.0);
      expect(dist.safetyPercent, 25.0);

      final map = dist.toMap();
      final fromMap = EmergencyDistribution.fromMap(map);
      expect(fromMap.totalCount, 100);
      expect(fromMap.cardiacCount, 50);
      expect(fromMap.strokeCount, 25);
      expect(fromMap.safetyCount, 25);
    });

    test('EmergencyDistribution handles zero total without division by zero', () {
      const dist = EmergencyDistribution(
        safetyCount: 0,
        cardiacCount: 0,
        strokeCount: 0,
      );

      expect(dist.totalCount, 0);
      expect(dist.cardiacPercent, 0.0);
      expect(dist.strokePercent, 0.0);
      expect(dist.safetyPercent, 0.0);
    });
  });

  group('RiskSeverityBreakdown Model Tests', () {
    test('RiskSeverityBreakdown percentages and serialization', () {
      const severity = RiskSeverityBreakdown(
        lowCount: 10,
        mediumCount: 30,
        highCount: 40,
        criticalCount: 20,
      );

      expect(severity.totalCount, 100);
      expect(severity.criticalPercent, 20.0);
      expect(severity.highPercent, 40.0);
      expect(severity.mediumPercent, 30.0);
      expect(severity.lowPercent, 10.0);

      final map = severity.toMap();
      final fromMap = RiskSeverityBreakdown.fromMap(map);
      expect(fromMap.criticalCount, 20);
      expect(fromMap.highCount, 40);
      expect(fromMap.mediumCount, 30);
      expect(fromMap.lowCount, 10);
    });
  });

  group('IncidentHotspot Model Tests', () {
    test('IncidentHotspot threat level parsing and serialization', () {
      const hotspot = IncidentHotspot(
        id: 'hs_mirpur',
        areaName: 'Mirpur 10',
        banglaName: 'মিরপুর ১০',
        totalIncidents: 35,
        safetyIncidents: 20,
        medicalIncidents: 15,
        threatLevel: ThreatLevel.critical,
        latitude: 23.8071,
        longitude: 90.3686,
      );

      expect(hotspot.threatLevel.label, 'Critical Hotspot');
      expect(hotspot.threatLevel.banglaLabel, 'সংবেদনশীল হটস্পট');

      final map = hotspot.toMap();
      expect(map['id'], 'hs_mirpur');
      expect(map['areaName'], 'Mirpur 10');
      expect(map['threatLevel'], 'critical');

      final fromMap = IncidentHotspot.fromMap(map, 'hs_mirpur');
      expect(fromMap.id, 'hs_mirpur');
      expect(fromMap.areaName, 'Mirpur 10');
      expect(fromMap.threatLevel, ThreatLevel.critical);
      expect(fromMap.totalIncidents, 35);
      expect(fromMap.safetyIncidents, 20);
      expect(fromMap.medicalIncidents, 15);
      expect(fromMap.latitude, 23.8071);
    });
  });

  group('AdminAnalyticsRepository Tests', () {
    test('Repository returns pre-seeded KPIs, distribution, and Dhaka hotspots', () async {
      const repo = AdminAnalyticsRepository();
      final kpis = await repo.getPlatformKPIs();
      expect(kpis.totalUsers, greaterThan(0));
      expect(kpis.verifiedContactsCoverage, greaterThan(80.0));

      final dist = await repo.getEmergencyDistribution();
      expect(dist.totalCount, greaterThan(0));

      final severity = await repo.getRiskSeverityBreakdown();
      expect(severity.totalCount, greaterThan(0));

      final hotspots = await repo.getDhakaHotspots();
      expect(hotspots.length, 7);
      expect(hotspots.any((h) => h.areaName.contains('Dhanmondi')), isTrue);
      expect(hotspots.any((h) => h.areaName.contains('Mirpur')), isTrue);
      expect(hotspots.any((h) => h.areaName.contains('Gulshan')), isTrue);
    });
  });

  group('AdminDashboardScreen Widget Tests', () {
    testWidgets('Renders KPI cards, distribution, hotspots, and thesis export dialog',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createAdminTestApp());
      await tester.pumpAndSettle();

      // Check App Bar
      expect(find.text('Admin Analytics Portal'), findsOneWidget);

      // Check KPI Cards
      expect(find.text('1280'), findsOneWidget); // Total Registered Users
      expect(find.text('3'), findsOneWidget); // Active Emergencies
      expect(find.text('3.8s'), findsOneWidget); // Avg Alert Latency
      expect(find.text('91.4%'), findsOneWidget); // Verified Contacts Coverage

      // Check Emergency Distribution section
      expect(find.text('Emergency Type Distribution'), findsOneWidget);
      expect(find.text('Acute Cardiac Triage'), findsOneWidget);
      expect(find.text('Stroke F.A.S.T. Assessment'), findsOneWidget);
      expect(find.text("Women's Safety SOS"), findsOneWidget);

      // Check Risk Severity section
      expect(find.text('Triage Risk Breakdown'), findsOneWidget);

      // Check Hotspots Explorer
      expect(find.text('Geographic Incident Hotspots (Dhaka)'), findsOneWidget);
      expect(find.text('Dhanmondi (R/A & Lake)'), findsOneWidget);
      expect(find.text('Mirpur 10 & Commercial'), findsOneWidget);

      // Check Thesis Export Action Button
      final exportButton = find.byIcon(Icons.download_rounded);
      expect(exportButton, findsOneWidget);

      await tester.tap(exportButton);
      await tester.pumpAndSettle();

      // Verify Thesis Dataset Dialog opens
      expect(find.text('Thesis Evaluation Metrics'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Thesis Evaluation Metrics'), findsNothing);
    });
  });
}
