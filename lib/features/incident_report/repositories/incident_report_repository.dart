import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/incident_report.dart';
import '../../../core/errors/app_exceptions.dart';

class IncidentReportRepository {
  final FirebaseFirestore? firestore;
  final SharedPreferences? prefs;
  final Uuid _uuid = const Uuid();

  static const String _cachedReportsKey = 'safelife_cached_incident_reports';

  IncidentReportRepository({
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

  CollectionReference<Map<String, dynamic>> get _reportsRef =>
      _db.collection('incidentReports');

  /// Creates a new incident report with Firestore and local backup
  Future<IncidentReport> createReport(IncidentReport report) async {
    final reportId = report.id.isEmpty ? _uuid.v4() : report.id;
    final finalReport = IncidentReport(
      id: reportId,
      userId: report.userId,
      userName: report.userName,
      userPhone: report.userPhone,
      category: report.category,
      description: report.description,
      location: report.location,
      createdAt: report.createdAt,
    );

    // Cache locally first
    await _cacheReport(finalReport);

    // Save to Firestore
    try {
      await _reportsRef.doc(reportId).set(finalReport.toMap());
    } catch (_) {
      // Offline fallback: report remains cached locally
    }

    return finalReport;
  }

  /// Streams reports filed by the current user
  Stream<List<IncidentReport>> streamUserReports(String userId) {
    try {
      return _reportsRef
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => IncidentReport.fromMap(doc.data(), doc.id))
            .toList();
      });
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Appends report to local cache
  Future<void> _cacheReport(IncidentReport report) async {
    try {
      final p = await _getPrefs();
      final existingJson = p.getStringList(_cachedReportsKey) ?? [];
      existingJson.add(jsonEncode(report.toMap()));
      await p.setStringList(_cachedReportsKey, existingJson);
    } catch (_) {}
  }

  /// Retrieves locally cached incident reports
  Future<List<IncidentReport>> getCachedReports() async {
    try {
      final p = await _getPrefs();
      final list = p.getStringList(_cachedReportsKey) ?? [];
      return list.map((item) {
        final map = jsonDecode(item) as Map<String, dynamic>;
        return IncidentReport.fromMap(map, map['id'] as String? ?? '');
      }).toList();
    } catch (_) {
      return [];
    }
  }
}
