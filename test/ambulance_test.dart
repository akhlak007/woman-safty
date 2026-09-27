import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safelife/app/app.dart';
import 'package:safelife/core/services/location_service.dart';
import 'package:safelife/features/ambulance/models/ambulance_booking.dart';
import 'package:safelife/features/ambulance/providers/ambulance_provider.dart';
import 'package:safelife/features/ambulance/repositories/ambulance_repository.dart';
import 'package:safelife/features/ambulance/screens/ambulance_request_screen.dart';
import 'package:safelife/features/auth/providers/auth_provider.dart';
import 'package:safelife/features/sos/models/emergency_case.dart';
import 'package:safelife/features/sos/providers/sos_provider.dart';
import 'package:safelife/features/profile/providers/profile_provider.dart';
import 'package:safelife/features/profile/providers/contacts_provider.dart';

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

class FakeAmbulanceRepository extends AmbulanceRepository {
  AmbulanceBooking? _cached;

  @override
  Future<AmbulanceBooking> createBooking(AmbulanceBooking booking) async {
    final created = booking.copyWith(id: 'test_booking_123');
    _cached = created;
    return created;
  }

  @override
  Future<void> updateBookingStatus(
    String bookingId,
    AmbulanceStatus status, {
    String? driverName,
    String? driverPhone,
    String? vehicleNumber,
    int? estimatedMinutes,
  }) async {
    if (_cached != null && _cached!.id == bookingId) {
      _cached = _cached!.copyWith(
        status: status,
        driverName: driverName ?? _cached!.driverName,
        driverPhone: driverPhone ?? _cached!.driverPhone,
        vehicleNumber: vehicleNumber ?? _cached!.vehicleNumber,
        estimatedMinutes: estimatedMinutes ?? _cached!.estimatedMinutes,
      );
    }
  }

  @override
  Future<AmbulanceBooking?> getCachedActiveBooking() async => _cached;

  @override
  Future<void> clearCachedBooking() async {
    _cached = null;
  }
}

class DelayedAmbulanceRepository extends AmbulanceRepository {
  final Completer<AmbulanceBooking> pending = Completer<AmbulanceBooking>();

  @override
  Future<AmbulanceBooking> createBooking(AmbulanceBooking booking) =>
      pending.future;
}

Widget createAmbulanceTestApp({
  required AmbulanceProvider ambulanceProvider,
  SosProvider? sosProvider,
  SafeLifeAuthProvider? authProvider,
  LocationService? locationService,
}) {
  return SafeLifeApp(
    authProvider: authProvider,
    ambulanceProvider: ambulanceProvider,
    sosProvider:
        sosProvider ??
        SosProvider(locationService: const MockLocationService()),
    profileProvider: ProfileProvider(),
    contactsProvider: ContactsProvider(),
    initialLocale: const Locale('en'),
    home: AmbulanceRequestScreen(
      locationService: locationService ?? const MockLocationService(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('AmbulanceBooking Model Tests', () {
    test('AmbulanceBooking toMap and fromMap serialization', () {
      final now = DateTime(2026, 9, 19, 10, 30);
      final booking = AmbulanceBooking(
        id: 'booking_001',
        userId: 'user_123',
        userName: 'Fatima Rahman',
        userPhone: '+8801700000000',
        pickupAddress: 'Dhanmondi 27, Dhaka',
        pickupLocation: EmergencyLocation(
          latitude: 23.75,
          longitude: 90.38,
          accuracy: 10.0,
          timestamp: now,
        ),
        destinationHospital: 'NICVD',
        ambulanceType: AmbulanceType.als,
        status: AmbulanceStatus.dispatched,
        driverName: 'Rahim',
        driverPhone: '+8801800000000',
        vehicleNumber: 'DHK-11-2233',
        estimatedMinutes: 8,
        createdAt: now,
      );

      final map = booking.toMap();
      expect(map['id'], 'booking_001');
      expect(map['ambulanceType'], 'als');
      expect(map['status'], 'dispatched');
      expect(map['estimatedMinutes'], 8);

      final restored = AmbulanceBooking.fromMap(map, 'booking_001');
      expect(restored.id, 'booking_001');
      expect(restored.ambulanceType, AmbulanceType.als);
      expect(restored.status, AmbulanceStatus.dispatched);
      expect(restored.driverName, 'Rahim');
      expect(restored.estimatedMinutes, 8);
    });

    test('AmbulanceBooking copyWith updates fields correctly', () {
      final booking = AmbulanceBooking(
        id: 'b1',
        userId: 'u1',
        userName: 'User 1',
        userPhone: '017',
        pickupAddress: 'Street 1',
        destinationHospital: 'Hospital A',
        ambulanceType: AmbulanceType.bls,
        status: AmbulanceStatus.requested,
        createdAt: DateTime.now(),
      );

      final updated = booking.copyWith(
        status: AmbulanceStatus.enRoute,
        driverName: 'Karim',
        estimatedMinutes: 5,
      );

      expect(updated.status, AmbulanceStatus.enRoute);
      expect(updated.driverName, 'Karim');
      expect(updated.estimatedMinutes, 5);
      expect(updated.ambulanceType, AmbulanceType.bls);
    });
  });

  group('AmbulanceProvider Unit Tests', () {
    late FakeAmbulanceRepository fakeRepo;
    late AmbulanceProvider provider;

    setUp(() {
      fakeRepo = FakeAmbulanceRepository();
      provider = AmbulanceProvider(repository: fakeRepo);
    });

    tearDown(() {
      provider.dispose();
    });

    test(
      'Request ambulance sets active booking and status requested',
      () async {
        final booking = await provider.requestAmbulance(
          userId: 'u_test',
          userName: 'Test User',
          userPhone: '+8801711111111',
          pickupAddress: 'Gulshan 2, Dhaka',
          destinationHospital: 'United Hospital',
          ambulanceType: AmbulanceType.als,
        );

        expect(provider.hasActiveBooking, isTrue);
        expect(provider.activeBooking?.status, AmbulanceStatus.requested);
        expect(booking.ambulanceType, AmbulanceType.als);
        expect(booking.destinationHospital, 'United Hospital');
      },
    );

    test('Cancel active booking transitions status to cancelled', () async {
      await provider.requestAmbulance(
        userId: 'u_test',
        userName: 'Test User',
        userPhone: '+8801711111111',
        pickupAddress: 'Gulshan 2, Dhaka',
        destinationHospital: 'United Hospital',
        ambulanceType: AmbulanceType.bls,
      );

      expect(provider.hasActiveBooking, isTrue);

      await provider.cancelBooking();
      expect(provider.hasActiveBooking, isFalse);
      expect(provider.activeBooking, isNull);
    });

    test(
      'Cached booking is not exposed to a different signed-in user',
      () async {
        await provider.requestAmbulance(
          userId: 'user_one',
          userName: 'First User',
          userPhone: '+8801711111111',
          pickupAddress: 'Dhaka',
          destinationHospital: 'Hospital',
          ambulanceType: AmbulanceType.bls,
        );

        provider.bindUser('user_two');
        await Future<void>.delayed(Duration.zero);

        expect(provider.activeBooking, isNull);
        expect(provider.hasActiveBooking, isFalse);
      },
    );

    test('In-flight request cannot restore state after sign-out', () async {
      final delayedRepo = DelayedAmbulanceRepository();
      final delayedProvider = AmbulanceProvider(repository: delayedRepo);
      addTearDown(delayedProvider.dispose);
      delayedProvider.bindUser('user_one');

      final request = delayedProvider.requestAmbulance(
        userId: 'user_one',
        userName: 'First User',
        userPhone: '+8801711111111',
        pickupAddress: 'Dhaka',
        destinationHospital: 'Hospital',
        ambulanceType: AmbulanceType.bls,
      );
      delayedProvider.bindUser(null);
      delayedRepo.pending.complete(
        AmbulanceBooking(
          id: 'late_booking',
          userId: 'user_one',
          userName: 'First User',
          userPhone: '+8801711111111',
          pickupAddress: 'Dhaka',
          destinationHospital: 'Hospital',
          ambulanceType: AmbulanceType.bls,
          status: AmbulanceStatus.requested,
          createdAt: DateTime.now(),
        ),
      );
      await request;

      expect(delayedProvider.activeBooking, isNull);
      expect(delayedProvider.hasActiveBooking, isFalse);
    });
  });

  group('AmbulanceRequestScreen Widget Tests', () {
    testWidgets('Renders ambulance options and allows selecting ALS vs BLS', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeRepo = FakeAmbulanceRepository();
      final provider = AmbulanceProvider(repository: fakeRepo);

      await tester.pumpWidget(
        createAmbulanceTestApp(ambulanceProvider: provider),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Header & title
      expect(find.text('Request Emergency Ambulance'), findsOneWidget);

      // Verify BLS and ALS options are present
      expect(find.text('Basic Life Support (BLS)'), findsOneWidget);
      expect(find.text('Advanced Cardiac Life Support (ALS)'), findsOneWidget);

      // Verify Quick Helplines
      expect(find.text('Call 999 Ambulance'), findsOneWidget);
      expect(find.textContaining('Red Crescent'), findsOneWidget);

      // Select ALS card
      await tester.tap(find.text('Advanced Cardiac Life Support (ALS)'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Check request button exists
      expect(find.text('Request Ambulance Dispatch'), findsOneWidget);

      provider.dispose();
    });

    testWidgets('Submitting ambulance request displays active tracking UI', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeRepo = FakeAmbulanceRepository();
      final provider = AmbulanceProvider(repository: fakeRepo);

      await tester.pumpWidget(
        createAmbulanceTestApp(ambulanceProvider: provider),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Enter pickup address
      await tester.enterText(
        find.byType(TextField).first,
        'Dhanmondi 27, Dhaka',
      );
      await tester.pump();

      // Tap Request Ambulance Dispatch
      final reqButton = find.text('Request Ambulance Dispatch');
      expect(reqButton, findsOneWidget);
      await tester.ensureVisible(reqButton);
      await tester.tap(reqButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Active booking tracking timeline should be visible
      expect(find.text('Dispatch Timeline'), findsOneWidget);
      expect(find.text('Cancel Request'), findsOneWidget);

      // Tap Cancel Request button to trigger dialog
      await tester.tap(find.text('Cancel Request'));
      await tester.pumpAndSettle();

      // Tap Yes, Cancel in dialog
      expect(find.text('Yes, Cancel'), findsOneWidget);
      await tester.tap(find.text('Yes, Cancel'));
      await tester.pumpAndSettle();

      // Should return to idle request form
      expect(find.text('Request Ambulance Dispatch'), findsOneWidget);

      provider.dispose();
    });
  });
}
