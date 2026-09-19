import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/ambulance_booking.dart';
import '../../../core/errors/app_exceptions.dart';

class AmbulanceRepository {
  final FirebaseFirestore? firestore;
  final SharedPreferences? prefs;
  final Uuid _uuid = const Uuid();

  static const String _activeBookingKey = 'safelife_active_ambulance_booking';

  AmbulanceRepository({
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

  CollectionReference<Map<String, dynamic>> get _bookingsRef =>
      _db.collection('ambulanceBookings');

  /// Create a new ambulance booking
  Future<AmbulanceBooking> createBooking(AmbulanceBooking booking) async {
    final bookingId = booking.id.isEmpty ? _uuid.v4() : booking.id;
    final finalBooking = booking.copyWith(id: bookingId);

    // Save to local cache first
    await cacheActiveBooking(finalBooking);

    // Save to Firestore
    try {
      await _bookingsRef.doc(bookingId).set(finalBooking.toMap());
    } catch (_) {
      // Offline fallback
    }

    return finalBooking;
  }

  /// Update booking status
  Future<void> updateBookingStatus(
    String bookingId,
    AmbulanceStatus status, {
    String? driverName,
    String? driverPhone,
    String? vehicleNumber,
    int? estimatedMinutes,
  }) async {
    final updates = <String, dynamic>{
      'status': status.code,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (driverName != null) updates['driverName'] = driverName;
    if (driverPhone != null) updates['driverPhone'] = driverPhone;
    if (vehicleNumber != null) updates['vehicleNumber'] = vehicleNumber;
    if (estimatedMinutes != null) updates['estimatedMinutes'] = estimatedMinutes;

    try {
      await _bookingsRef.doc(bookingId).update(updates);
    } catch (_) {}

    // Update locally cached booking
    final cached = await getCachedActiveBooking();
    if (cached != null && cached.id == bookingId) {
      final updated = cached.copyWith(
        status: status,
        driverName: driverName ?? cached.driverName,
        driverPhone: driverPhone ?? cached.driverPhone,
        vehicleNumber: vehicleNumber ?? cached.vehicleNumber,
        estimatedMinutes: estimatedMinutes ?? cached.estimatedMinutes,
      );
      if (status == AmbulanceStatus.completed || status == AmbulanceStatus.cancelled) {
        await clearCachedBooking();
      } else {
        await cacheActiveBooking(updated);
      }
    }
  }

  /// Cache active booking locally
  Future<void> cacheActiveBooking(AmbulanceBooking booking) async {
    try {
      final p = await _getPrefs();
      await p.setString(_activeBookingKey, jsonEncode(booking.toMap()));
    } catch (_) {}
  }

  /// Get locally cached active booking
  Future<AmbulanceBooking?> getCachedActiveBooking() async {
    try {
      final p = await _getPrefs();
      final str = p.getString(_activeBookingKey);
      if (str == null || str.isEmpty) return null;
      final map = jsonDecode(str) as Map<String, dynamic>;
      return AmbulanceBooking.fromMap(map, map['id'] as String? ?? '');
    } catch (_) {
      return null;
    }
  }

  /// Clear active booking
  Future<void> clearCachedBooking() async {
    try {
      final p = await _getPrefs();
      await p.remove(_activeBookingKey);
    } catch (_) {}
  }
}
