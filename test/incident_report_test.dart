import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safelife/features/incident_report/models/incident_report.dart';
import 'package:safelife/features/incident_report/repositories/incident_report_repository.dart';
import 'package:safelife/features/sos/models/emergency_case.dart';

void main() {
  group('IncidentReport Unit Tests', () {
    test('Model serialization and deserialization', () {
      final now = DateTime.now();
      final report = IncidentReport(
        id: 'rep_123',
        userId: 'user_456',
        userName: 'Ayesha Rahman',
        userPhone: '+8801700000001',
        category: 'stalking',
        description: 'Followed by an unidentified person near Dhanmondi Lake.',
        location: EmergencyLocation(
          latitude: 23.7500,
          longitude: 90.3700,
          accuracy: 5.0,
          timestamp: now,
        ),
        createdAt: now,
      );

      final map = report.toMap();
      final reconstructed = IncidentReport.fromMap(map, 'rep_123');

      expect(reconstructed.id, 'rep_123');
      expect(reconstructed.userId, 'user_456');
      expect(reconstructed.userName, 'Ayesha Rahman');
      expect(reconstructed.category, 'stalking');
      expect(reconstructed.description, contains('Dhanmondi Lake'));
      expect(reconstructed.location?.latitude, 23.7500);
    });

    test('IncidentReportRepository local caching and retrieval', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = IncidentReportRepository(prefs: prefs);

      final report = IncidentReport(
        id: 'test_report_1',
        userId: 'user_1',
        userName: 'Fatima',
        userPhone: '+8801800000002',
        category: 'harassment',
        description: 'Verbal harassment at public transport stoppage.',
        createdAt: DateTime(2026, 9, 19, 8, 0),
      );

      final created = await repo.createReport(report);
      expect(created.id, 'test_report_1');

      final cached = await repo.getCachedReports();
      expect(cached.length, 1);
      expect(cached.first.id, 'test_report_1');
      expect(cached.first.category, 'harassment');
      expect(cached.first.description, contains('Verbal harassment'));
    });
  });
}
