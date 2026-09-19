import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safelife/app/app.dart';
import 'package:safelife/core/constants/alert_constants.dart';
import 'package:safelife/features/responder/models/responder_case.dart';
import 'package:safelife/features/responder/providers/responder_provider.dart';
import 'package:safelife/features/responder/repositories/responder_repository.dart';
import 'package:safelife/features/responder/screens/responder_panel_screen.dart';
import 'package:safelife/features/sos/models/emergency_case.dart';

Widget createResponderTestApp({ResponderProvider? provider}) {
  return SafeLifeApp(
    responderProvider: provider ?? ResponderProvider(),
    initialLocale: const Locale('en'),
    home: const ResponderPanelScreen(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('ResponderCase Model Tests', () {
    test('ResponderStatus enum labels and banglaLabels', () {
      expect(ResponderStatus.pending.label, 'Pending Dispatch');
      expect(ResponderStatus.pending.banglaLabel, 'অপেক্ষমাণ ডিসপ্যাচ');
      expect(ResponderStatus.accepted.label, 'Accepted');
      expect(ResponderStatus.accepted.banglaLabel, 'গৃহীত');
      expect(ResponderStatus.dispatched.label, 'Dispatched');
      expect(ResponderStatus.onScene.label, 'On Scene');
      expect(ResponderStatus.resolved.label, 'Resolved');
      expect(ResponderStatus.resolved.banglaLabel, 'নিষ্পন্ন');
    });

    test('ResponderCase creation, copyWith, and serialization', () {
      final now = DateTime(2026, 9, 19, 10, 0);
      final eCase = EmergencyCase(
        id: 'case_test_01',
        userId: 'user_01',
        userName: 'Ayesha Siddiqua',
        userPhone: '+8801711122233',
        type: EmergencyType.stroke,
        riskLevel: RiskLevel.critical,
        alertLevel: AlertLevel.critical,
        status: EmergencyStatus.active,
        createdAt: now,
      );

      final rCase = ResponderCase.fromEmergency(eCase);
      expect(rCase.caseId, 'case_test_01');
      expect(rCase.status, ResponderStatus.pending);
      expect(rCase.notes, isEmpty);

      final updated = rCase.copyWith(
        status: ResponderStatus.accepted,
        assignedUnit: 'Rapid Rescue 1',
        notes: ['Unit rolling from Dhanmondi base'],
        acceptedAt: now.add(const Duration(minutes: 1)),
      );

      expect(updated.status, ResponderStatus.accepted);
      expect(updated.assignedUnit, 'Rapid Rescue 1');
      expect(updated.notes.length, 1);

      final map = updated.toMap();
      expect(map['caseId'], 'case_test_01');
      expect(map['status'], 'accepted');
      expect(map['assignedUnit'], 'Rapid Rescue 1');
      expect(map['notes'], ['Unit rolling from Dhanmondi base']);
    });
  });

  group('ResponderRepository Tests', () {
    test('Loads demo cases ordered by risk severity critical first', () async {
      final repo = ResponderRepository();
      final stream = repo.streamActiveEmergencies();
      final cases = await stream.first;

      expect(cases.length, 3);
      // First case must be Critical (Stroke)
      expect(cases[0].emergencyCase.riskLevel, RiskLevel.critical);
      expect(cases[0].emergencyCase.type, EmergencyType.stroke);

      // Second case must be High (Cardiac)
      expect(cases[1].emergencyCase.riskLevel, RiskLevel.high);
      expect(cases[1].emergencyCase.type, EmergencyType.cardiac);

      // Third case must be Medium (Women Safety)
      expect(cases[2].emergencyCase.riskLevel, RiskLevel.medium);
      expect(cases[2].emergencyCase.type, EmergencyType.safety);
    });

    test('acceptEmergency assigns unit and timestamps acceptance', () async {
      final repo = ResponderRepository();
      final accepted = await repo.acceptEmergency('demo_case_stroke_01', 'Ambulance Unit 5');

      expect(accepted.status, ResponderStatus.accepted);
      expect(accepted.assignedUnit, 'Ambulance Unit 5');
      expect(accepted.acceptedAt, isNotNull);
    });

    test('updateResponderStatus handles onScene and resolved transitions', () async {
      final repo = ResponderRepository();
      final onScene = await repo.updateResponderStatus(
        'demo_case_stroke_01',
        ResponderStatus.onScene,
      );
      expect(onScene.status, ResponderStatus.onScene);
      expect(onScene.arrivedAt, isNotNull);

      final resolved = await repo.updateResponderStatus(
        'demo_case_stroke_01',
        ResponderStatus.resolved,
      );
      expect(resolved.status, ResponderStatus.resolved);
      expect(resolved.resolvedAt, isNotNull);
    });

    test('addNote appends operational and clinical logs', () async {
      final repo = ResponderRepository();
      await repo.addNote('demo_case_stroke_01', 'Patient administered oxygen therapy');
      await repo.addNote('demo_case_stroke_01', 'Arrived at National Institute of Neurosciences');

      final cases = await repo.streamActiveEmergencies().first;
      final target = cases.firstWhere((c) => c.caseId == 'demo_case_stroke_01');
      expect(target.notes.length, 2);
      expect(target.notes[0], 'Patient administered oxygen therapy');
      expect(target.notes[1], 'Arrived at National Institute of Neurosciences');
    });
  });

  group('ResponderProvider Tests', () {
    test('Initializes with active cases and defaults selection to critical first', () async {
      final provider = ResponderProvider();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(provider.isLoading, isFalse);
      expect(provider.allCases.length, 3);
      expect(provider.criticalCount, 1);
      expect(provider.selectedCase, isNotNull);
      expect(provider.selectedCase!.caseId, 'demo_case_stroke_01');
    });

    test('Filtering by category returns only targeted emergency types', () async {
      final provider = ResponderProvider();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      provider.setFilter(ResponderFilter.critical);
      expect(provider.filteredCases.length, 1);
      expect(provider.filteredCases.first.emergencyCase.riskLevel, RiskLevel.critical);

      provider.setFilter(ResponderFilter.cardiac);
      expect(provider.filteredCases.length, 1);
      expect(provider.filteredCases.first.emergencyCase.type, EmergencyType.cardiac);

      provider.setFilter(ResponderFilter.stroke);
      expect(provider.filteredCases.length, 1);
      expect(provider.filteredCases.first.emergencyCase.type, EmergencyType.stroke);

      provider.setFilter(ResponderFilter.safety);
      expect(provider.filteredCases.length, 1);
      expect(provider.filteredCases.first.emergencyCase.type, EmergencyType.safety);

      provider.setFilter(ResponderFilter.all);
      expect(provider.filteredCases.length, 3);
    });

    test('Provider updates status and notes reactively', () async {
      final provider = ResponderProvider();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await provider.acceptCase('demo_case_stroke_01', 'Dhaka Rescue Unit 7');
      expect(provider.selectedCase?.status, ResponderStatus.accepted);
      expect(provider.selectedCase?.assignedUnit, 'Dhaka Rescue Unit 7');

      await provider.addNote('demo_case_stroke_01', 'IV line established');
      expect(provider.selectedCase?.notes.contains('IV line established'), isTrue);
    });
  });

  group('ResponderPanelScreen Widget Tests', () {
    testWidgets('Renders emergency queue, critical badge, details, and dispatch flow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final provider = ResponderProvider();
      await tester.pumpWidget(createResponderTestApp(provider: provider));
      await tester.pumpAndSettle();

      // Check App Bar & Critical Count Badge
      expect(find.text('Responder & Hospital Command Panel'), findsOneWidget);
      expect(find.text('1 CRITICAL'), findsOneWidget);

      // Check Filter Chips
      expect(find.text('All Active'), findsOneWidget);
      expect(find.text('Critical Only'), findsOneWidget);
      expect(find.text('Cardiac'), findsOneWidget);
      expect(find.text('Stroke (FAST)'), findsOneWidget);
      expect(find.text('Women Safety'), findsOneWidget);

      // Check Patient Names in Queue
      expect(find.text('Nurul Huda'), findsWidgets);
      expect(find.text('Begum Rokeya'), findsWidgets);
      expect(find.text('Sharmin Sultana'), findsWidgets);

      // Check Case Details Header (Dhanmondi stroke case selected by default)
      expect(find.text('STROKE F.A.S.T. ASSESSMENT'), findsWidgets);
      expect(find.text('Case ID: demo_case_stroke_01'), findsOneWidget);

      // Check Triage Indicators
      expect(find.text('faceDroop: true'), findsOneWidget);
      expect(find.text('armWeakness: true'), findsOneWidget);

      // Check Accept & Dispatch Flow
      final acceptButton = find.text('Accept & Dispatch');
      expect(acceptButton, findsOneWidget);

      await tester.tap(acceptButton);
      await tester.pumpAndSettle();

      // Modal dialog appears
      expect(find.text('Response Unit Name / Call Sign'), findsOneWidget);
      final confirmDispatch = find.text('Confirm Dispatch');
      expect(confirmDispatch, findsOneWidget);

      await tester.tap(confirmDispatch);
      await tester.pumpAndSettle();

      // Button updates to Mark On-Scene
      expect(find.text('Mark On-Scene'), findsOneWidget);

      // Progress to On Scene
      await tester.tap(find.text('Mark On-Scene'));
      await tester.pumpAndSettle();

      // Button updates to Resolve Emergency Case
      expect(find.text('Resolve Emergency Case'), findsOneWidget);

      // Test adding responder note
      final noteInput = find.byType(TextField).last;
      await tester.enterText(noteInput, 'Vitals stable on site');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Vitals stable on site'), findsOneWidget);
    });
  });
}
