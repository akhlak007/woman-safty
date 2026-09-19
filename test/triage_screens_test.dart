import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safelife/app/app.dart';
import 'package:safelife/core/constants/alert_constants.dart';
import 'package:safelife/core/services/location_service.dart';
import 'package:safelife/features/auth/providers/auth_provider.dart';
import 'package:safelife/features/heart_triage/screens/cardiac_triage_screen.dart';
import 'package:safelife/features/history/screens/emergency_history_screen.dart';
import 'package:safelife/features/incident_report/repositories/incident_report_repository.dart';
import 'package:safelife/features/incident_report/screens/incident_report_screen.dart';
import 'package:safelife/features/profile/providers/contacts_provider.dart';
import 'package:safelife/features/profile/providers/profile_provider.dart';
import 'package:safelife/features/sos/models/emergency_case.dart';
import 'package:safelife/features/sos/providers/sos_provider.dart';
import 'package:safelife/features/sos/repositories/emergency_repository.dart';
import 'package:safelife/features/stroke_triage/screens/stroke_triage_screen.dart';

class MockLocationService extends LocationService {
  final EmergencyLocation? fixedLocation;
  const MockLocationService({this.fixedLocation});

  @override
  Future<bool> checkAndRequestPermission() async => true;

  @override
  Future<EmergencyLocation?> getCurrentLocation() async =>
      fixedLocation ??
      EmergencyLocation(
        latitude: 23.8103,
        longitude: 90.4125,
        accuracy: 10,
        timestamp: DateTime(2026, 9, 19, 10, 0),
      );

  @override
  Stream<EmergencyLocation> getPositionStream({int intervalSeconds = 10}) {
    return Stream.value(
      fixedLocation ??
          EmergencyLocation(
            latitude: 23.8103,
            longitude: 90.4125,
            accuracy: 10,
            timestamp: DateTime(2026, 9, 19, 10, 0),
          ),
    );
  }
}

Widget createTestApp(
  Widget child, {
  SafeLifeAuthProvider? authProvider,
  SosProvider? sosProvider,
}) {
  return SafeLifeApp(
    authProvider: authProvider,
    sosProvider: sosProvider ?? SosProvider(locationService: const MockLocationService()),
    profileProvider: ProfileProvider(),
    contactsProvider: ContactsProvider(),
    initialLocale: const Locale('en'),
    home: child,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('Phase 3 Widget Tests', () {
    testWidgets('CardiacTriageScreen renders questions and updates risk badge',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestApp(const CardiacTriageScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Check header and medical disclaimer
      expect(find.text('Cardiac Risk Assessment'), findsOneWidget);
      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);

      // Verify switches exist
      expect(find.byType(SwitchListTile), findsWidgets);

      // Tap on chest pain switch
      final chestPainFinder = find.widgetWithText(
        SwitchListTile,
        'Are you experiencing chest pain, tightness, or heavy pressure?',
      );
      expect(chestPainFinder, findsOneWidget);

      await tester.tap(chestPainFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap on radiation switch
      final radiationFinder = find.widgetWithText(
        SwitchListTile,
        'Does the pain radiate to your left arm, jaw, neck, or back?',
      );
      expect(radiationFinder, findsOneWidget);
      await tester.tap(radiationFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap on shortness of breath switch
      final breathFinder = find.widgetWithText(
        SwitchListTile,
        'Are you experiencing severe shortness of breath or difficulty breathing?',
      );
      expect(breathFinder, findsOneWidget);
      await tester.tap(breathFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap Assess Risk button
      final assessRiskBtn = find.text('Assess Risk');
      expect(assessRiskBtn, findsOneWidget);
      await tester.tap(assessRiskBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // With chest pain + radiation + breath, classic presentation triggers CRITICAL badge
      expect(find.text('CRITICAL'), findsOneWidget);
      expect(find.text('Dispatch Cardiac SOS Alert'), findsOneWidget);

      // Teardown
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('StrokeTriageScreen renders FAST protocol and mode toggle',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestApp(const StrokeTriageScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Header exists
      expect(find.text('Stroke F.A.S.T. Assessment'), findsOneWidget);

      // Mode selector exists
      expect(find.byType(SegmentedButton<bool>), findsOneWidget);

      // Verify 3 FAST switches exist
      expect(find.byType(Switch), findsNWidgets(3));

      // Toggle Face Droop switch
      final firstSwitch = find.byType(Switch).first;
      await tester.tap(firstSwitch);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap Assess Risk button
      final assessBtn = find.text('Assess Risk');
      expect(assessBtn, findsOneWidget);
      await tester.tap(assessBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Immediate critical stroke risk alert must appear
      expect(find.text('CRITICAL STROKE RISK IDENTIFIED'), findsOneWidget);
      expect(find.text('Dispatch Stroke SOS Alert'), findsOneWidget);

      // Teardown
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('IncidentReportScreen switches categories and submits report',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = IncidentReportRepository(prefs: prefs);

      await tester.pumpWidget(createTestApp(
        IncidentReportScreen(
          repository: repo,
          locationService: const MockLocationService(),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tabs exist
      expect(find.byType(TabBar), findsOneWidget);
      expect(find.text('My Incident Reports'), findsOneWidget);

      // Category chips exist
      expect(find.text('Harassment'), findsOneWidget);
      expect(find.text('Stalking / Followed'), findsOneWidget);

      // Tap 'Stalking / Followed'
      await tester.tap(find.text('Stalking / Followed'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Enter description
      final descField = find.byType(TextFormField);
      expect(descField, findsOneWidget);
      await tester.enterText(
        descField,
        'Suspicious individual following near bus terminal after dark.',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap submit button
      final submitButton = find.text('Submit Incident Report');
      expect(submitButton, findsOneWidget);
      await tester.tap(submitButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify repository has cached the report
      final reports = await repo.getCachedReports();
      expect(reports.length, 1);
      expect(reports.first.category, 'stalking');
      expect(reports.first.description, contains('Suspicious individual'));

      // Teardown
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('EmergencyHistoryScreen renders history items and filter chips',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = EmergencyRepository(prefs: prefs);

      // Seed a cached emergency
      final sampleCase = EmergencyCase(
        id: 'hist_case_1',
        userId: 'u1',
        userName: 'Ayesha',
        userPhone: '+8801700000001',
        type: EmergencyType.cardiac,
        riskLevel: RiskLevel.critical,
        alertLevel: AlertLevel.critical,
        status: EmergencyStatus.resolved,
        createdAt: DateTime(2026, 9, 19, 8, 30),
        resolvedAt: DateTime(2026, 9, 19, 9, 0),
        lastKnownLocation: EmergencyLocation(
          latitude: 23.8103,
          longitude: 90.4125,
          accuracy: 5.0,
          timestamp: DateTime(2026, 9, 19, 8, 30),
        ),
        triageAnswers: {
          'Chest Pain': true,
          'Pain Radiating': true,
        },
      );
      await repo.createEmergencyCase(sampleCase);

      await tester.pumpWidget(createTestApp(
        EmergencyHistoryScreen(repository: repo),
      ));
      await tester.pump();
      // Pump microtasks for FutureBuilder to resolve cached history
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      // Verify header and filter chips
      expect(find.text('Emergency History'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Cardiac'), findsOneWidget);

      // Verify seeded card appears
      expect(find.text('Heart Attack / Cardiac'), findsOneWidget);
      expect(find.text('RESOLVED'), findsOneWidget);
      expect(find.text('Critical'), findsOneWidget);

      // Tap on card to open details dialog
      await tester.tap(find.text('Heart Attack / Cardiac'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Emergency Case Details'), findsOneWidget);
      expect(find.text('Open in Google Maps'), findsOneWidget);
      expect(find.text('Chest Pain: true'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('Close'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Teardown
      await tester.pumpWidget(const SizedBox());
    });
  });
}
