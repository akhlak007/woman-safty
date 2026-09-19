import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/emergency_case.dart';
import '../../../core/errors/app_exceptions.dart';

class EmergencyRepository {
  final FirebaseFirestore? firestore;
  final SharedPreferences? prefs;
  final Uuid _uuid = const Uuid();

  static const String _activeEmergencyKey = 'safelife_active_emergency';
  static const String _historyEmergenciesKey = 'safelife_cached_emergency_history';

  EmergencyRepository({
    this.firestore,
    this.prefs,
  });

  FirebaseFirestore get _db {
    try {
      return firestore ?? FirebaseFirestore.instance;
    } catch (e) {
      throw const DatabaseException('Cloud Firestore is not initialized.');
    }
  }

  Future<SharedPreferences> _getPrefs() async {
    return prefs ?? await SharedPreferences.getInstance();
  }

  CollectionReference<Map<String, dynamic>> get _emergenciesRef =>
      _db.collection('emergencies');

  /// Create a new emergency case in Firestore and local cache
  Future<EmergencyCase> createEmergencyCase(EmergencyCase emergency) async {
    final caseId = emergency.id.isEmpty ? _uuid.v4() : emergency.id;
    final finalCase = EmergencyCase(
      id: caseId,
      userId: emergency.userId,
      userName: emergency.userName,
      userPhone: emergency.userPhone,
      type: emergency.type,
      riskLevel: emergency.riskLevel,
      alertLevel: emergency.alertLevel,
      status: emergency.status,
      createdAt: emergency.createdAt,
      resolvedAt: emergency.resolvedAt,
      lastKnownLocation: emergency.lastKnownLocation,
      triggerSource: emergency.triggerSource,
      triageAnswers: emergency.triageAnswers,
      contactAlerts: emergency.contactAlerts,
    );

    // Save to local cache first for instant offline readiness
    await cacheActiveEmergency(finalCase);
    await _cacheEmergencyHistory(finalCase);

    // Persist to Firestore
    try {
      await _emergenciesRef.doc(caseId).set(finalCase.toMap());
    } catch (_) {
      // Offline fallback: still recorded in local cache
    }

    return finalCase;
  }

  /// Update the live location for an active emergency
  Future<void> updateLiveLocation(String emergencyId, EmergencyLocation location) async {
    try {
      await _emergenciesRef.doc(emergencyId).update({
        'lastKnownLocation': location.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      // Also log location history breadcrumb
      await _emergenciesRef
          .doc(emergencyId)
          .collection('locations')
          .add(location.toMap());
    } catch (_) {
      // Best-effort for live location updates
    }
  }

  /// Update status (resolved, cancelled, false_alarm)
  Future<void> updateStatus(
    String emergencyId,
    EmergencyStatus status, {
    DateTime? resolvedAt,
  }) async {
    final resolvedTime = resolvedAt ?? DateTime.now();
    try {
      await _emergenciesRef.doc(emergencyId).update({
        'status': status.code,
        'resolvedAt': resolvedTime.toIso8601String(),
      });
    } catch (_) {
      // Best-effort Firestore update
    }

    // Clear or update local cache
    if (status != EmergencyStatus.active) {
      await clearCachedEmergency();
    }
  }

  /// Stream active emergency for a user
  Stream<EmergencyCase?> streamActiveEmergency(String userId) {
    try {
      return _emergenciesRef
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: EmergencyStatus.active.code)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isEmpty) return null;
        final doc = snapshot.docs.first;
        return EmergencyCase.fromMap(doc.data(), doc.id);
      });
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Streams emergency history for a user
  Stream<List<EmergencyCase>> streamEmergencyHistory(String userId) {
    try {
      return _emergenciesRef
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => EmergencyCase.fromMap(doc.data(), doc.id))
            .toList();
      });
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Get emergency by ID
  Future<EmergencyCase?> getEmergencyById(String emergencyId) async {
    try {
      final doc = await _emergenciesRef.doc(emergencyId).get();
      if (!doc.exists || doc.data() == null) return null;
      return EmergencyCase.fromMap(doc.data()!, doc.id);
    } catch (_) {
      return null;
    }
  }

  /// Cache active emergency locally
  Future<void> cacheActiveEmergency(EmergencyCase emergency) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString(_activeEmergencyKey, jsonEncode(emergency.toMap()));
    } catch (_) {}
  }

  /// Append/update emergency in locally cached history
  Future<void> _cacheEmergencyHistory(EmergencyCase emergency) async {
    try {
      final prefs = await _getPrefs();
      final list = prefs.getStringList(_historyEmergenciesKey) ?? [];
      final encoded = jsonEncode(emergency.toMap());
      // Remove previous entry with same id if any
      list.removeWhere((item) {
        final m = jsonDecode(item) as Map<String, dynamic>;
        return m['id'] == emergency.id;
      });
      list.insert(0, encoded);
      await prefs.setStringList(_historyEmergenciesKey, list);
    } catch (_) {}
  }

  /// Get locally cached emergency history
  Future<List<EmergencyCase>> getCachedHistory() async {
    try {
      final prefs = await _getPrefs();
      final list = prefs.getStringList(_historyEmergenciesKey) ?? [];
      return list.map((item) {
        final map = jsonDecode(item) as Map<String, dynamic>;
        return EmergencyCase.fromMap(map, map['id'] as String? ?? '');
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// Get locally cached active emergency
  Future<EmergencyCase?> getCachedActiveEmergency() async {
    try {
      final prefs = await _getPrefs();
      final jsonStr = prefs.getString(_activeEmergencyKey);
      if (jsonStr == null || jsonStr.isEmpty) return null;
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return EmergencyCase.fromMap(map, map['id'] as String? ?? '');
    } catch (_) {
      return null;
    }
  }

  /// Clear locally cached emergency
  Future<void> clearCachedEmergency() async {
    try {
      final prefs = await _getPrefs();
      await prefs.remove(_activeEmergencyKey);
    } catch (_) {}
  }
}
