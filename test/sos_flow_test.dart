import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safelife/app/app.dart';
import 'package:safelife/core/services/location_service.dart';
import 'package:safelife/features/dashboard/screens/dashboard_screen.dart';
import 'package:safelife/features/profile/models/emergency_contact.dart';
import 'package:safelife/features/sos/models/emergency_case.dart';
import 'package:safelife/features/sos/providers/sos_provider.dart';
import 'package:safelife/features/sos/screens/active_emergency_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('SosProvider Unit Tests', () {
    test('SosProvider countdown starts and cancels correctly', () {
      final provider = SosProvider(locationService: const MockLocationService());
      expect(provider.countdown, 5);
      expect(provider.isCountingDown, isFalse);

      provider.startCountdown(
        userId: 'u1',
        userName: 'Test User',
        userPhone: '+8801700000000',
        contacts: [],
        language: 'en',
      );

      expect(provider.isCountingDown, isTrue);

      provider.cancelCountdown();
      expect(provider.isCountingDown, isFalse);
      expect(provider.countdown, 5);
    });

    test('SosProvider dispatches emergency and resolves cleanly', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = SosProvider(locationService: const MockLocationService());

      final emergency = await provider.dispatchEmergency(
        userId: 'u123',
        userName: 'Sadia',
        userPhone: '+8801711111111',
        contacts: [
          EmergencyContact(
            id: 'c1',
            name: 'Brother',
            phone: '+8801811111111',
            relation: 'Brother',
            priority: 1,
            verified: true,
            createdAt: DateTime(2026, 9, 19),
          ),
        ],
        language: 'en',
      );

      expect(emergency, isNotNull);
      expect(provider.hasActiveEmergency, isTrue);
      expect(provider.activeEmergency?.userName, 'Sadia');

      // Resolve emergency
      await provider.resolveEmergency(status: EmergencyStatus.resolved);
      expect(provider.hasActiveEmergency, isFalse);
      expect(provider.activeEmergency, isNull);
    });
  });

  group('Active Emergency Screen Widget Tests', () {
    testWidgets('ActiveEmergencyScreen renders emergency information and resolve dialog', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final sosProvider = SosProvider(locationService: const MockLocationService());

      await sosProvider.dispatchEmergency(
        userId: 'u1',
        userName: 'Amina',
        userPhone: '+8801700000000',
        contacts: [
          EmergencyContact(
            id: 'c1',
            name: 'Father',
            phone: '+8801722222222',
            relation: 'Parent',
            priority: 1,
            verified: true,
            createdAt: DateTime(2026, 9, 19),
          ),
        ],
        language: 'en',
      );

      await tester.pumpWidget(
        SafeLifeApp(
          sosProvider: sosProvider,
          initialLocale: const Locale('en'),
          home: const ActiveEmergencyScreen(),
        ),
      );
      await tester.pump();

      // Verify Screen Elements
      expect(find.textContaining('ACTIVE EMERGENCY'), findsWidgets);
      expect(find.text('Live GPS Location'), findsOneWidget);
      expect(find.text('Alerted Emergency Contacts'), findsOneWidget);
      expect(find.text('Father'), findsOneWidget);
      expect(find.textContaining('Call 999'), findsOneWidget);

      // Verify Resolve Action triggers Dialog
      final resolveButton = find.text("I'm Safe / Resolve");
      expect(resolveButton, findsOneWidget);
      await tester.ensureVisible(resolveButton);
      await tester.tap(resolveButton);
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Dialog Options
      expect(find.text('Resolve Emergency'), findsOneWidget);
      expect(find.text('False Alarm / Test'), findsOneWidget);
      expect(find.text('I Am Safe (Resolved)'), findsOneWidget);

      // Tap Resolved
      await tester.tap(find.text('I Am Safe (Resolved)'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(sosProvider.hasActiveEmergency, isFalse);

      // Unmount to dispose repeating pulse animation
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('Dashboard Emergency SOS Integration Tests', () {
    testWidgets('Dashboard displays active emergency banner when SOS is active', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final sosProvider = SosProvider(locationService: const MockLocationService());

      // 1. Initially without active emergency
      await tester.pumpWidget(
        SafeLifeApp(
          sosProvider: sosProvider,
          initialLocale: const Locale('en'),
          home: DashboardScreen(
            onToggleTheme: () {},
            onToggleLocale: () {},
            currentLocale: const Locale('en'),
            currentThemeMode: ThemeMode.light,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('ACTIVE EMERGENCY IN PROGRESS'), findsNothing);

      // 2. Dispatch emergency and re-render
      await sosProvider.dispatchEmergency(
        userId: 'u1',
        userName: 'Rina',
        userPhone: '+8801700000000',
        contacts: [],
        language: 'en',
      );
      await tester.pump();

      // Banner should now be visible on Dashboard
      expect(find.text('ACTIVE EMERGENCY IN PROGRESS'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('Tapping central SOS button launches countdown dialog and cancel works', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final sosProvider = SosProvider(locationService: const MockLocationService());

      await tester.pumpWidget(
        SafeLifeApp(
          sosProvider: sosProvider,
          initialLocale: const Locale('en'),
          home: DashboardScreen(
            onToggleTheme: () {},
            onToggleLocale: () {},
            currentLocale: const Locale('en'),
            currentThemeMode: ThemeMode.light,
          ),
        ),
      );
      await tester.pump();

      // Tap the central SOS button
      final sosButton = find.byIcon(Icons.emergency_rounded);
      expect(sosButton, findsOneWidget);
      await tester.tap(sosButton);
      await tester.pump(const Duration(milliseconds: 300));

      // Countdown dialog should appear
      expect(find.text('Emergency Alert Triggering'), findsOneWidget);
      expect(find.text('Dispatch Now'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Emergency Alert Triggering'), findsNothing);

      await tester.pumpWidget(const SizedBox());
    });
  });
}
