import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/models/user_profile.dart';
import '../../../core/errors/app_exceptions.dart';

class ProfileRepository {
  final FirebaseFirestore? firestore;

  ProfileRepository({this.firestore});

  FirebaseFirestore get _db {
    try {
      return firestore ?? FirebaseFirestore.instance;
    } catch (e) {
      throw const DatabaseException('Cloud Firestore is not initialized.');
    }
  }

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _db.collection('users');

  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final doc = await _usersRef.doc(uid).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return UserProfile.fromMap(doc.data()!, uid);
    } catch (e) {
      throw AuthException('Failed to retrieve user profile.', e.toString());
    }
  }

  Stream<UserProfile?> streamUserProfile(String uid) {
    try {
      return _usersRef.doc(uid).snapshots().map((doc) {
        if (!doc.exists || doc.data() == null) {
          return null;
        }
        return UserProfile.fromMap(doc.data()!, uid);
      });
    } catch (_) {
      return const Stream.empty();
    }
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      await _usersRef.doc(profile.uid).set(
            profile.toMap(),
            SetOptions(merge: true),
          );
    } catch (e) {
      throw AuthException('Failed to save profile information.', e.toString());
    }
  }

  Future<void> updateMedicalInfo({
    required String uid,
    String? bloodGroup,
    required List<String> conditions,
    required List<String> medications,
    required List<String> allergies,
  }) async {
    try {
      await _usersRef.doc(uid).update({
        'bloodGroup': bloodGroup,
        'conditions': conditions,
        'medications': medications,
        'allergies': allergies,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw AuthException('Failed to update medical profile.', e.toString());
    }
  }
}
