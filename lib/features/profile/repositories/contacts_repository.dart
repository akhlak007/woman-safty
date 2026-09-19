import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/emergency_contact.dart';
import '../../../core/errors/app_exceptions.dart';

class ContactsRepository {
  final FirebaseFirestore? firestore;
  final Uuid _uuid = const Uuid();

  ContactsRepository({this.firestore});

  FirebaseFirestore get _db {
    try {
      return firestore ?? FirebaseFirestore.instance;
    } catch (e) {
      throw const DatabaseException('Cloud Firestore is not initialized.');
    }
  }

  CollectionReference<Map<String, dynamic>> _contactsRef(String userId) {
    return _db.collection('users').doc(userId).collection('contacts');
  }

  Stream<List<EmergencyContact>> streamContacts(String userId) {
    try {
      return _contactsRef(userId)
          .orderBy('priority', descending: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => EmergencyContact.fromMap(doc.data(), doc.id))
            .toList();
      });
    } catch (_) {
      return const Stream.empty();
    }
  }

  Future<void> addContact(String userId, EmergencyContact contact) async {
    try {
      final id = contact.id.isEmpty ? _uuid.v4() : contact.id;
      final newContact = contact.copyWith(
        verificationCode: contact.verificationCode ?? _generateVerificationCode(),
      );
      await _contactsRef(userId).doc(id).set(newContact.toMap());
    } catch (e) {
      throw DatabaseException('Failed to add emergency contact.', e.toString());
    }
  }

  Future<void> updateContact(String userId, EmergencyContact contact) async {
    try {
      await _contactsRef(userId).doc(contact.id).update(contact.toMap());
    } catch (e) {
      throw DatabaseException('Failed to update emergency contact.', e.toString());
    }
  }

  Future<void> deleteContact(String userId, String contactId) async {
    try {
      await _contactsRef(userId).doc(contactId).delete();
    } catch (e) {
      throw DatabaseException('Failed to delete emergency contact.', e.toString());
    }
  }

  /// Generates a consent verification request code / token for contact
  Future<String> requestContactConsent(String userId, String contactId) async {
    try {
      final code = _generateVerificationCode();
      await _contactsRef(userId).doc(contactId).update({
        'verificationCode': code,
      });
      return code;
    } catch (e) {
      throw DatabaseException('Failed to issue consent request.', e.toString());
    }
  }

  /// Verifies contact consent using the matching code
  Future<bool> verifyContactConsent(
    String userId,
    String contactId,
    String providedCode,
  ) async {
    try {
      final doc = await _contactsRef(userId).doc(contactId).get();
      if (!doc.exists || doc.data() == null) return false;

      final storedCode = doc.data()!['verificationCode'] as String?;
      if (storedCode != null && storedCode.trim() == providedCode.trim()) {
        await _contactsRef(userId).doc(contactId).update({
          'verified': true,
        });
        return true;
      }
      return false;
    } catch (e) {
      throw DatabaseException('Failed to verify contact consent.', e.toString());
    }
  }

  String _generateVerificationCode() {
    return (100000 + (DateTime.now().microsecondsSinceEpoch % 900000)).toString();
  }
}
