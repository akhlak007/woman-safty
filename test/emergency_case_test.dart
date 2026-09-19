import 'package:flutter_test/flutter_test.dart';
import 'package:safelife/core/constants/alert_constants.dart';
import 'package:safelife/core/services/sms_fallback_service.dart';
import 'package:safelife/features/sos/models/emergency_case.dart';
import 'package:safelife/features/sos/repositories/emergency_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Emergency Models & Serialization Tests', () {
    test('EmergencyLocation serialization and Google Maps URL generation', () {
      final now = DateTime(2026, 9, 19, 8, 30);
      final location = EmergencyLocation(
        latitude: 23.8103,
        longitude: 90.4125,
        accuracy: 12.5,
        timestamp: now,
        address: 'Dhaka, Bangladesh',
      );

      expect(location.googleMapsUrl, 'https://maps.google.com/?q=23.8103,90.4125');

      final map = location.toMap();
      expect(map['latitude'], 23.8103);
      expect(map['longitude'], 90.4125);
      expect(map['accuracy'], 12.5);
      expect(map['address'], 'Dhaka, Bangladesh');

      final deserialized = EmergencyLocation.fromMap(map);
      expect(deserialized.latitude, location.latitude);
      expect(deserialized.longitude, location.longitude);
      expect(deserialized.accuracy, location.accuracy);
      expect(deserialized.address, location.address);
    });

    test('ContactAlertRecord serialization', () {
      final record = ContactAlertRecord(
        contactId: 'c123',
        contactName: 'Fatima',
        contactPhone: '+8801700000001',
        channel: 'sms',
        status: 'sent',
        timestamp: DateTime(2026, 9, 19, 8, 30),
      );

      final map = record.toMap();
      expect(map['contactId'], 'c123');
      expect(map['contactName'], 'Fatima');
      expect(map['channel'], 'sms');
      expect(map['status'], 'sent');

      final deserialized = ContactAlertRecord.fromMap(map);
      expect(deserialized.contactId, 'c123');
      expect(deserialized.contactName, 'Fatima');
      expect(deserialized.contactPhone, '+8801700000001');
    });

    test('EmergencyCase serialization and copyWith', () {
      final now = DateTime(2026, 9, 19, 8, 30);
      final emergencyCase = EmergencyCase(
        id: 'emg-001',
        userId: 'usr-999',
        userName: 'Ayesha Rahman',
        userPhone: '+8801700000000',
        type: EmergencyType.safety,
        riskLevel: RiskLevel.high,
        alertLevel: AlertLevel.emergencyContactAlert,
        status: EmergencyStatus.active,
        createdAt: now,
        lastKnownLocation: EmergencyLocation(
          latitude: 23.75,
          longitude: 90.38,
          accuracy: 5.0,
          timestamp: now,
        ),
        contactAlerts: [
          ContactAlertRecord(
            contactId: 'c1',
            contactName: 'Mother',
            contactPhone: '+8801800000000',
            channel: 'sms',
            status: 'sent',
            timestamp: now,
          ),
        ],
      );

      final map = emergencyCase.toMap();
      expect(map['id'], 'emg-001');
      expect(map['userId'], 'usr-999');
      expect(map['type'], 'safety');
      expect(map['status'], 'active');

      final restored = EmergencyCase.fromMap(map, 'emg-001');
      expect(restored.id, 'emg-001');
      expect(restored.userName, 'Ayesha Rahman');
      expect(restored.type, EmergencyType.safety);
      expect(restored.lastKnownLocation?.latitude, 23.75);
      expect(restored.contactAlerts.length, 1);

      // copyWith status update
      final resolved = restored.copyWith(
        status: EmergencyStatus.resolved,
        resolvedAt: now.add(const Duration(minutes: 10)),
      );
      expect(resolved.status, EmergencyStatus.resolved);
      expect(resolved.resolvedAt, isNotNull);
    });
  });

  group('SMS Fallback Service Tests', () {
    const service = SmsFallbackService();
    final now = DateTime(2026, 9, 19, 10, 15);
    final emergency = EmergencyCase(
      id: 'test-sos',
      userId: 'u1',
      userName: 'Nusrat',
      userPhone: '+8801711111111',
      type: EmergencyType.safety,
      riskLevel: RiskLevel.high,
      alertLevel: AlertLevel.emergencyContactAlert,
      status: EmergencyStatus.active,
      createdAt: now,
      lastKnownLocation: EmergencyLocation(
        latitude: 23.81,
        longitude: 90.41,
        accuracy: 10,
        timestamp: now,
      ),
    );

    test('English SMS message contains critical keywords, map link, and 999', () {
      final msg = service.formatEmergencyMessage(
        emergency: emergency,
        language: 'en',
      );

      expect(msg, contains('EMERGENCY ALERT'));
      expect(msg, contains('Nusrat'));
      expect(msg, contains('https://maps.google.com/?q=23.81,90.41'));
      expect(msg, contains('999'));
    });

    test('Bengali SMS message contains Bangla alert tags, map link, and ৯৯৯', () {
      final msg = service.formatEmergencyMessage(
        emergency: emergency,
        language: 'bn',
      );

      expect(msg, contains('সেফলাইফ জরুরি সতর্কতা'));
      expect(msg, contains('Nusrat'));
      expect(msg, contains('https://maps.google.com/?q=23.81,90.41'));
      expect(msg, contains('৯৯৯'));
    });

    test('SendDirectSms returns false when no contacts provided', () async {
      final result = await service.sendDirectSms(
        emergency: emergency,
        contacts: [],
        language: 'en',
      );
      expect(result, isFalse);
    });
  });

  group('Emergency Repository Offline Cache Tests', () {
    test('Local cache stores, retrieves, and clears active emergency case', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = EmergencyRepository();

      final emg = EmergencyCase(
        id: 'cache-001',
        userId: 'usr-offline',
        userName: 'Offline Test User',
        userPhone: '+8801700000000',
        type: EmergencyType.safety,
        riskLevel: RiskLevel.high,
        alertLevel: AlertLevel.emergencyContactAlert,
        status: EmergencyStatus.active,
        createdAt: DateTime.now(),
      );

      // Cache emergency
      await repo.cacheActiveEmergency(emg);

      // Retrieve cached
      final retrieved = await repo.getCachedActiveEmergency();
      expect(retrieved, isNotNull);
      expect(retrieved!.id, 'cache-001');
      expect(retrieved.userId, 'usr-offline');
      expect(retrieved.status, EmergencyStatus.active);

      // Clear cache
      await repo.clearCachedEmergency();
      final cleared = await repo.getCachedActiveEmergency();
      expect(cleared, isNull);
    });
  });
}
