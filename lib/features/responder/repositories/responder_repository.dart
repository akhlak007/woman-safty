import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/alert_constants.dart';
import '../../sos/models/emergency_case.dart';
import '../models/responder_case.dart';

class ResponderRepository {
  final FirebaseFirestore? firestore;
  final Map<String, ResponderCase> _localCases = {};

  ResponderRepository({this.firestore}) {
    _initializeDemoCases();
  }

  FirebaseFirestore get _db => firestore ?? FirebaseFirestore.instance;

  void _initializeDemoCases() {
    final now = DateTime.now();

    // 1. Critical Stroke FAST Emergency in Dhanmondi
    final strokeCase = EmergencyCase(
      id: 'demo_case_stroke_01',
      userId: 'user_dhaka_01',
      userName: 'Nurul Huda',
      userPhone: '+8801712001122',
      type: EmergencyType.stroke,
      riskLevel: RiskLevel.critical,
      alertLevel: AlertLevel.critical,
      status: EmergencyStatus.active,
      createdAt: now.subtract(const Duration(minutes: 8)),
      lastKnownLocation: EmergencyLocation(
        latitude: 23.7461,
        longitude: 90.3742,
        accuracy: 6.0,
        timestamp: now.subtract(const Duration(minutes: 2)),
        address: 'House 42, Road 7/A, Dhanmondi, Dhaka',
      ),
      triageAnswers: const {
        'faceDroop': true,
        'armWeakness': true,
        'speechDifficulty': false,
        'isBystanderMode': true,
        'onsetTime': '08:45 AM',
      },
    );

    // 2. High Risk Acute Cardiac Event in Mohakhali
    final cardiacCase = EmergencyCase(
      id: 'demo_case_cardiac_02',
      userId: 'user_dhaka_02',
      userName: 'Begum Rokeya',
      userPhone: '+8801819334455',
      type: EmergencyType.cardiac,
      riskLevel: RiskLevel.high,
      alertLevel: AlertLevel.highPriority,
      status: EmergencyStatus.active,
      createdAt: now.subtract(const Duration(minutes: 14)),
      lastKnownLocation: EmergencyLocation(
        latitude: 23.7772,
        longitude: 90.4024,
        accuracy: 8.0,
        timestamp: now.subtract(const Duration(minutes: 3)),
        address: 'Amtoli Bus Stop, Mohakhali, Dhaka',
      ),
      triageAnswers: const {
        'chestPain': true,
        'painSeverity': 8,
        'painRadiation': true,
        'shortnessOfBreath': true,
        'profuseDiaphoresis': true,
      },
    );

    // 3. Women Safety Distress Trigger in Mirpur
    final safetyCase = EmergencyCase(
      id: 'demo_case_safety_03',
      userId: 'user_dhaka_03',
      userName: 'Sharmin Sultana',
      userPhone: '+8801911778899',
      type: EmergencyType.safety,
      riskLevel: RiskLevel.medium,
      alertLevel: AlertLevel.emergencyContactAlert,
      status: EmergencyStatus.active,
      createdAt: now.subtract(const Duration(minutes: 5)),
      lastKnownLocation: EmergencyLocation(
        latitude: 23.8071,
        longitude: 90.3686,
        accuracy: 10.0,
        timestamp: now.subtract(const Duration(minutes: 1)),
        address: 'Near Mirpur 10 Roundabout, Dhaka',
      ),
    );

    _localCases[strokeCase.id] = ResponderCase.fromEmergency(strokeCase);
    _localCases[cardiacCase.id] = ResponderCase.fromEmergency(cardiacCase);
    _localCases[safetyCase.id] = ResponderCase.fromEmergency(safetyCase);
  }

  /// Stream of active emergency cases for responder dispatch queue
  Stream<List<ResponderCase>> streamActiveEmergencies() {
    try {
      return _db
          .collection('emergencies')
          .where('status', isEqualTo: 'active')
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isEmpty) {
          return _getSortedLocalCases();
        }
        return snapshot.docs.map((doc) {
          final eCase = EmergencyCase.fromMap(doc.data(), doc.id);
          final local = _localCases[eCase.id];
          return local ?? ResponderCase.fromEmergency(eCase);
        }).toList()
          ..sort(_sortCases);
      });
    } catch (_) {
      return Stream.value(_getSortedLocalCases());
    }
  }

  List<ResponderCase> _getSortedLocalCases() {
    final list = _localCases.values.toList();
    list.sort(_sortCases);
    return list;
  }

  int _sortCases(ResponderCase a, ResponderCase b) {
    // Priority 1: Risk level descending (Critical first)
    final riskComp = b.emergencyCase.riskLevel.index.compareTo(a.emergencyCase.riskLevel.index);
    if (riskComp != 0) return riskComp;
    // Priority 2: Creation date descending (Newest first)
    return b.emergencyCase.createdAt.compareTo(a.emergencyCase.createdAt);
  }

  /// Responder accepts case and assigns a response unit
  Future<ResponderCase> acceptEmergency(String caseId, String unitName) async {
    final existing = _localCases[caseId];
    final updated = (existing ??
            ResponderCase.fromEmergency(
              EmergencyCase(
                id: caseId,
                userId: '',
                userName: 'Patient',
                userPhone: '',
                type: EmergencyType.safety,
                riskLevel: RiskLevel.medium,
                alertLevel: AlertLevel.emergencyContactAlert,
                status: EmergencyStatus.active,
                createdAt: DateTime.now(),
              ),
            ))
        .copyWith(
      status: ResponderStatus.accepted,
      assignedUnit: unitName,
      acceptedAt: DateTime.now(),
    );

    _localCases[caseId] = updated;

    try {
      await _db.collection('emergencies').doc(caseId).update({
        'responderStatus': ResponderStatus.accepted.name,
        'assignedUnit': unitName,
        'acceptedAt': DateTime.now().toIso8601String(),
      });
    } catch (_) {}

    return updated;
  }

  /// Update responder operational status (dispatched, onScene, resolved)
  Future<ResponderCase> updateResponderStatus(String caseId, ResponderStatus status) async {
    final existing = _localCases[caseId];
    if (existing == null) throw Exception('Case not found');

    DateTime? arrived = existing.arrivedAt;
    DateTime? resolved = existing.resolvedAt;

    if (status == ResponderStatus.onScene) {
      arrived = DateTime.now();
    } else if (status == ResponderStatus.resolved) {
      resolved = DateTime.now();
    }

    final updated = existing.copyWith(
      status: status,
      arrivedAt: arrived,
      resolvedAt: resolved,
    );

    _localCases[caseId] = updated;

    try {
      await _db.collection('emergencies').doc(caseId).update({
        'responderStatus': status.name,
        if (arrived != null) 'arrivedAt': arrived.toIso8601String(),
        if (resolved != null) 'resolvedAt': resolved.toIso8601String(),
        if (status == ResponderStatus.resolved) 'status': 'resolved',
      });
    } catch (_) {}

    return updated;
  }

  /// Add clinical or operational note to case
  Future<void> addNote(String caseId, String note) async {
    final existing = _localCases[caseId];
    if (existing != null) {
      final newNotes = List<String>.from(existing.notes)..add(note);
      _localCases[caseId] = existing.copyWith(notes: newNotes);
    }

    try {
      await _db.collection('emergencies').doc(caseId).update({
        'notes': FieldValue.arrayUnion([note]),
      });
    } catch (_) {}
  }
}
