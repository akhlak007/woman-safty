import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safelife/app/app.dart';
import 'package:safelife/core/services/location_service.dart';
import 'package:safelife/features/hospitals/models/hospital.dart';
import 'package:safelife/features/hospitals/repositories/hospital_repository.dart';
import 'package:safelife/features/hospitals/screens/hospital_directory_screen.dart';
import 'package:safelife/features/sos/models/emergency_case.dart';

class MockLocationService extends LocationService {
  final EmergencyLocation? fixedLocation;
  const MockLocationService({this.fixedLocation});

  @override
  Future<bool> checkAndRequestPermission() async => true;

  @override
  Future<EmergencyLocation?> getCurrentLocation() async =>
      fixedLocation ??
      EmergencyLocation(
        latitude: 23.7712, // Close to NICVD and NINS
        longitude: 90.3697,
        accuracy: 5,
        timestamp: DateTime(2026, 9, 19, 10, 0),
      );
}

Widget createTestApp(
  Widget child, {
  LocationService? locationService,
  HospitalRepository? hospitalRepository,
}) {
  return SafeLifeApp(
    initialLocale: const Locale('en'),
    home: child,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('HospitalRepository Unit Tests', () {
    final repo = HospitalRepository();

    test('Returns seeded hospitals sorted by distance from user location', () {
      // User location at Sher-e-Bangla Nagar (very close to NICVD)
      final results = repo.getHospitals(
        userLat: 23.7712,
        userLng: 90.3697,
      );

      expect(results.isNotEmpty, isTrue);
      expect(results.first.distanceTo(23.7712, 90.3697), lessThan(1.0));
      // First hospital should be NICVD or NINS
      expect(results.first.id, anyOf('hosp_nicvd', 'hosp_nins'));
    });

    test('Filters hospitals by Cath Lab capability', () {
      final results = repo.getHospitals(
        userLat: 23.8103,
        userLng: 90.4125,
        onlyCathLab: true,
      );

      expect(results.isNotEmpty, isTrue);
      for (final h in results) {
        expect(h.hasCathLab, isTrue);
      }
    });

    test('Filters hospitals by Stroke Thrombolysis (tPA) capability', () {
      final results = repo.getHospitals(
        userLat: 23.8103,
        userLng: 90.4125,
        onlyStroke: true,
      );

      expect(results.isNotEmpty, isTrue);
      for (final h in results) {
        expect(h.hasStrokeThrombolysis, isTrue);
      }
      final ids = results.map((h) => h.id).toList();
      expect(ids, contains('hosp_nins'));
    });

    test('Filters hospitals by ICU capability', () {
      final results = repo.getHospitals(
        userLat: 23.8103,
        userLng: 90.4125,
        onlyICU: true,
      );

      expect(results.isNotEmpty, isTrue);
      for (final h in results) {
        expect(h.hasICU, isTrue);
      }
    });

    test('Filters hospitals by search query matching name or address', () {
      final dhakaMed = repo.getHospitals(
        userLat: 23.8103,
        userLng: 90.4125,
        searchQuery: 'Dhaka Medical',
      );
      expect(dhakaMed.length, 1);
      expect(dhakaMed.first.id, 'hosp_dmch');

      final banglaSearch = repo.getHospitals(
        userLat: 23.8103,
        userLng: 90.4125,
        searchQuery: 'ইউনাইটেড',
      );
      expect(banglaSearch.length, 1);
      expect(banglaSearch.first.id, 'hosp_united');
    });

    test('Correctly calculates Haversine distance formula', () {
      const hosp = Hospital(
        id: 'dhaka',
        name: 'Dhaka Hosp',
        banglaName: 'ঢাকা',
        address: 'Dhaka',
        phone: '123',
        latitude: 23.8103,
        longitude: 90.4125,
      );
      // Distance between Dhaka (23.8103, 90.4125) and Chittagong (22.3569, 91.7832) is ~210 km
      final dist = hosp.distanceTo(22.3569, 91.7832);
      expect(dist, greaterThan(200.0));
      expect(dist, lessThan(230.0));
    });

    test('Hospital serialization to Map', () {
      const hosp = Hospital(
        id: 'test_hosp',
        name: 'Test Hospital',
        banglaName: 'টেস্ট হাসপাতাল',
        address: 'Test Address',
        phone: '123456',
        latitude: 23.8,
        longitude: 90.4,
        hasCathLab: true,
        hasStrokeThrombolysis: true,
        hasICU: true,
        type: 'government',
      );

      final map = hosp.toMap();
      expect(map['id'], 'test_hosp');
      expect(map['hasCathLab'], true);
      expect(map['type'], 'government');
      expect(map['area'], 'Dhaka');
    });

    test('Filters hospitals by area and district', () {
      final mirpurHospitals = repo.getHospitals(
        areaFilter: 'Mirpur',
      );
      expect(mirpurHospitals.isNotEmpty, isTrue);
      expect(mirpurHospitals.any((h) => h.id == 'hosp_nhf'), isTrue);

      final ctgHospitals = repo.getHospitals(
        areaFilter: 'Chattogram',
      );
      expect(ctgHospitals.isNotEmpty, isTrue);
      expect(ctgHospitals.any((h) => h.id == 'hosp_cmch'), isTrue);
    });

    test('Filters hospitals by max distance radius', () {
      // From Sher-e-Bangla Nagar, hospitals within 2 km should include NICVD / NINS
      final closeHospitals = repo.getHospitals(
        userLat: 23.7712,
        userLng: 90.3698,
        maxDistanceKm: 2.0,
      );
      expect(closeHospitals.isNotEmpty, isTrue);
      for (final h in closeHospitals) {
        expect(h.distanceTo(23.7712, 90.3698), lessThanOrEqualTo(2.0));
      }
    });

    test('Estimated driving time calculation works accurately', () {
      const hosp = Hospital(
        id: 'hosp_demo',
        name: 'Demo Hospital',
        banglaName: 'ডেমো',
        address: 'Demo',
        phone: '123',
        latitude: 23.7,
        longitude: 90.3,
      );
      expect(hosp.estimatedDrivingMinutes(1.0), inInclusiveRange(2, 6));
      expect(hosp.estimatedDrivingMinutes(10.0), inInclusiveRange(20, 30));
    });
  });

  group('HospitalDirectoryScreen Widget Tests', () {
    testWidgets('Renders directory search, filter chips, and hospital cards',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const mockLocation = MockLocationService();
      final repo = HospitalRepository();

      await tester.pumpWidget(
        createTestApp(
          HospitalDirectoryScreen(
            repository: repo,
            locationService: mockLocation,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Title & search field
      expect(find.text('Emergency Hospitals'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Location reference bar & GPS button
      expect(find.textContaining('Live GPS'), findsWidgets);

      // Filter chips: Cath Lab, Stroke Care, ICU, 24/7 Emergency
      expect(find.text('Cardiac (Cath Lab)'), findsOneWidget);
      expect(find.text('Stroke Care'), findsOneWidget);
      expect(find.text('ICU Available'), findsOneWidget);
      expect(find.text('24/7 Emergency'), findsOneWidget);

      // Hospital cards should appear (e.g. NICVD)
      expect(find.textContaining('NICVD'), findsWidgets);

      // Tap on Cath Lab filter chip
      final cathLabChip = find.text('Cardiac (Cath Lab)');
      await tester.tap(cathLabChip);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Ensure filtered list still shows cath lab hospital
      expect(find.textContaining('National Institute of Cardiovascular Diseases'), findsWidgets);

      // Enter search query
      await tester.enterText(find.byType(TextField), 'Square');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Square Hospital'), findsOneWidget);

      // Tap on Radar Map View button
      final radarMapButton = find.byIcon(Icons.radar_rounded);
      expect(radarMapButton, findsOneWidget);
      await tester.tap(radarMapButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Proximity Radar'), findsOneWidget);
    });
  });
}
