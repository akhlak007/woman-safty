import 'package:flutter_test/flutter_test.dart';
import 'package:safelife/features/auth/models/user_profile.dart';
import 'package:safelife/features/profile/models/emergency_contact.dart';

void main() {
  group('Phase 1: UserProfile Model Tests', () {
    final now = DateTime(2026, 9, 19, 1, 0, 0);

    test('UserProfile should correctly serialize and deserialize to/from Map', () {
      final profile = UserProfile(
        uid: 'user_123',
        name: 'Fatima Rahman',
        phone: '+8801712345678',
        email: 'fatima@example.com',
        bloodGroup: 'B+',
        conditions: ['Hypertension (High BP)', 'Diabetes Mellitus'],
        medications: ['Metformin 500mg', 'Amlodipine 5mg'],
        allergies: ['Penicillin'],
        language: 'bn',
        createdAt: now,
        updatedAt: now,
      );

      final map = profile.toMap();
      expect(map['uid'], 'user_123');
      expect(map['name'], 'Fatima Rahman');
      expect(map['bloodGroup'], 'B+');
      expect(map['conditions'], contains('Hypertension (High BP)'));
      expect(map['medications'], contains('Metformin 500mg'));
      expect(map['allergies'], contains('Penicillin'));

      final restored = UserProfile.fromMap(map, 'user_123');
      expect(restored.uid, profile.uid);
      expect(restored.name, profile.name);
      expect(restored.phone, profile.phone);
      expect(restored.email, profile.email);
      expect(restored.bloodGroup, profile.bloodGroup);
      expect(restored.conditions, profile.conditions);
      expect(restored.medications, profile.medications);
      expect(restored.allergies, profile.allergies);
    });

    test('UserProfile copyWith should update specific fields immutably', () {
      final profile = UserProfile(
        uid: 'user_123',
        name: 'Fatima Rahman',
        phone: '+8801712345678',
        email: 'fatima@example.com',
        createdAt: now,
        updatedAt: now,
      );

      final updated = profile.copyWith(
        bloodGroup: 'O+',
        conditions: ['Asthma / COPD'],
      );

      expect(updated.bloodGroup, 'O+');
      expect(updated.conditions, ['Asthma / COPD']);
      expect(updated.name, profile.name);
      expect(profile.bloodGroup, isNull);
    });

    test('Available blood groups contain all 8 standard types', () {
      expect(UserProfile.availableBloodGroups.length, 8);
      expect(UserProfile.availableBloodGroups, containsAll(['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']));
    });
  });

  group('Phase 1: EmergencyContact Model Tests', () {
    final now = DateTime(2026, 9, 19, 1, 0, 0);

    test('EmergencyContact should correctly serialize and deserialize', () {
      final contact = EmergencyContact(
        id: 'contact_001',
        name: 'Rafiq Islam',
        phone: '+8801812345678',
        relation: 'Spouse',
        priority: 1,
        verified: true,
        verificationCode: '789123',
        createdAt: now,
      );

      final map = contact.toMap();
      expect(map['id'], 'contact_001');
      expect(map['name'], 'Rafiq Islam');
      expect(map['relation'], 'Spouse');
      expect(map['priority'], 1);
      expect(map['verified'], isTrue);
      expect(map['verificationCode'], '789123');

      final restored = EmergencyContact.fromMap(map, 'contact_001');
      expect(restored.id, contact.id);
      expect(restored.name, contact.name);
      expect(restored.verified, isTrue);
      expect(restored.relation, 'Spouse');
    });

    test('EmergencyContact defaults to unverified (consent required)', () {
      final contact = EmergencyContact(
        id: 'contact_002',
        name: 'Salma Begum',
        phone: '+8801912345678',
        relation: 'Parent',
        createdAt: now,
      );

      expect(contact.verified, isFalse);
      expect(contact.priority, 1);
    });
  });
}
