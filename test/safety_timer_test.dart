import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safelife/app/app.dart';
import 'package:safelife/core/services/location_service.dart';
import 'package:safelife/features/auth/providers/auth_provider.dart';
import 'package:safelife/features/profile/models/emergency_contact.dart';
import 'package:safelife/features/profile/providers/contacts_provider.dart';
import 'package:safelife/features/profile/providers/profile_provider.dart';
import 'package:safelife/features/safety_timer/providers/safety_timer_provider.dart';
import 'package:safelife/features/safety_timer/screens/safety_timer_screen.dart';
import 'package:safelife/features/sos/models/emergency_case.dart';
import 'package:safelife/features/sos/providers/sos_provider.dart';
import 'package:safelife/features/sos/repositories/emergency_repository.dart';

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
}

class FakeEmergencyRepository extends EmergencyRepository {
  EmergencyCase? lastDispatchedCase;

  @override
  Future<EmergencyCase> createEmergencyCase(EmergencyCase emergencyCase) async {
    lastDispatchedCase = emergencyCase;
    return emergencyCase;
  }
}

Widget createSafetyTimerTestApp({
  required SafetyTimerProvider safetyTimerProvider,
  required SosProvider sosProvider,
  SafeLifeAuthProvider? authProvider,
}) {
  return SafeLifeApp(
    authProvider: authProvider,
    safetyTimerProvider: safetyTimerProvider,
    sosProvider: sosProvider,
    profileProvider: ProfileProvider(),
    contactsProvider: ContactsProvider(),
    initialLocale: const Locale('en'),
    home: const SafetyTimerScreen(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('SafetyTimerProvider Unit Tests', () {
    late SafetyTimerProvider timerProvider;
    late FakeEmergencyRepository fakeRepo;
    late SosProvider sosProvider;

    setUp(() {
      timerProvider = SafetyTimerProvider();
      fakeRepo = FakeEmergencyRepository();
      sosProvider = SosProvider(
        emergencyRepository: fakeRepo,
        locationService: const MockLocationService(),
      );
    });

    tearDown(() {
      timerProvider.dispose();
      sosProvider.dispose();
    });

    test('Starting timer sets isRunning true and calculates remaining seconds', () {
      expect(timerProvider.isRunning, isFalse);
      expect(timerProvider.remainingSeconds, 0);

      timerProvider.startTimer(
        minutes: 15,
        sosProvider: sosProvider,
        userId: 'u_123',
        userName: 'Amina Begum',
        userPhone: '+8801700000000',
        contacts: [
          EmergencyContact(
            id: 'c1',
            name: 'Brother',
            phone: '+8801800000000',
            relation: 'Brother',
            createdAt: DateTime.now(),
          ),
        ],
        language: 'en',
      );

      expect(timerProvider.isRunning, isTrue);
      expect(timerProvider.remainingSeconds, 900);
      expect(timerProvider.initialSeconds, 900);
      expect(timerProvider.formattedTime, '15:00');
      expect(timerProvider.progress, 1.0);
    });

    test('Stopping timer clears timer and resets running status', () {
      timerProvider.startTimer(
        minutes: 30,
        sosProvider: sosProvider,
        userId: 'u_123',
        userName: 'Amina Begum',
        userPhone: '+8801700000000',
        contacts: const [],
        language: 'en',
      );

      expect(timerProvider.isRunning, isTrue);
      timerProvider.stopTimer();

      expect(timerProvider.isRunning, isFalse);
      expect(timerProvider.remainingSeconds, 0);
      expect(timerProvider.isExpired, isFalse);
    });
  });

  group('SafetyTimerScreen Widget Tests', () {
    testWidgets('Renders duration picker and starts countdown timer',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final timerProvider = SafetyTimerProvider();
      final fakeRepo = FakeEmergencyRepository();
      final sosProvider = SosProvider(
        emergencyRepository: fakeRepo,
        locationService: const MockLocationService(),
      );

      await tester.pumpWidget(
        createSafetyTimerTestApp(
          safetyTimerProvider: timerProvider,
          sosProvider: sosProvider,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Title & explainer
      expect(find.text('Safety Timer (Walk With Me)'), findsWidgets);
      expect(find.text('Select Commute Window'), findsOneWidget);

      // Duration presets: 5, 15, 30, 60
      expect(find.text('5'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
      expect(find.text('60'), findsOneWidget);

      // Select 30 min
      await tester.tap(find.text('30'));
      await tester.pump();

      // Start timer button
      final startBtn = find.text('Start 30-Minute Safety Timer');
      expect(startBtn, findsOneWidget);

      await tester.tap(startBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Should now show active countdown view
      expect(find.text('30:00'), findsOneWidget);
      expect(find.text('Safety timer active'), findsOneWidget);
      expect(find.text('I Arrived Safely'), findsOneWidget);

      // Tap I Arrived Safely
      await tester.tap(find.text('I Arrived Safely'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Returned to setup view
      expect(find.text('Start 30-Minute Safety Timer'), findsOneWidget);

      timerProvider.dispose();
      sosProvider.dispose();
    });
  });
}
