import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/ambulance_booking.dart';
import '../repositories/ambulance_repository.dart';
import '../../sos/models/emergency_case.dart';

class AmbulanceProvider extends ChangeNotifier {
  final AmbulanceRepository repository;

  AmbulanceBooking? _activeBooking;
  bool _isLoading = false;
  final List<Timer> _simulationTimers = [];

  AmbulanceProvider({AmbulanceRepository? repository})
      : repository = repository ?? AmbulanceRepository() {
    _loadCachedBooking();
  }

  AmbulanceBooking? get activeBooking => _activeBooking;
  bool get hasActiveBooking => _activeBooking != null &&
      _activeBooking!.status != AmbulanceStatus.completed &&
      _activeBooking!.status != AmbulanceStatus.cancelled;
  bool get isLoading => _isLoading;

  Future<void> _loadCachedBooking() async {
    _activeBooking = await repository.getCachedActiveBooking();
    notifyListeners();
  }

  /// Request ambulance dispatch and begin live status tracking
  Future<AmbulanceBooking> requestAmbulance({
    required String userId,
    required String userName,
    required String userPhone,
    required String pickupAddress,
    EmergencyLocation? pickupLocation,
    required String destinationHospital,
    required AmbulanceType ambulanceType,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newBooking = AmbulanceBooking(
        id: '',
        userId: userId,
        userName: userName,
        userPhone: userPhone,
        pickupAddress: pickupAddress,
        pickupLocation: pickupLocation,
        destinationHospital: destinationHospital,
        ambulanceType: ambulanceType,
        status: AmbulanceStatus.requested,
        estimatedMinutes: 15,
        createdAt: DateTime.now(),
      );

      final created = await repository.createBooking(newBooking);
      _activeBooking = created;
      _isLoading = false;
      notifyListeners();

      // Start simulated dispatch progression for demonstration
      _startSimulatedProgression(created.id);

      return created;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void _startSimulatedProgression(String bookingId) {
    _cancelTimers();

    // Step 1: Dispatched after 3 seconds
    _simulationTimers.add(Timer(const Duration(seconds: 3), () async {
      if (_activeBooking?.id != bookingId || _activeBooking?.status == AmbulanceStatus.cancelled) return;
      await repository.updateBookingStatus(
        bookingId,
        AmbulanceStatus.dispatched,
        driverName: 'Md. Rafiqul Islam',
        driverPhone: '+8801711223344',
        vehicleNumber: 'Dhaka Metro-Cha 11-4521',
        estimatedMinutes: 12,
      );
      _activeBooking = _activeBooking?.copyWith(
        status: AmbulanceStatus.dispatched,
        driverName: 'Md. Rafiqul Islam',
        driverPhone: '+8801711223344',
        vehicleNumber: 'Dhaka Metro-Cha 11-4521',
        estimatedMinutes: 12,
      );
      notifyListeners();
    }));

    // Step 2: En Route after 7 seconds
    _simulationTimers.add(Timer(const Duration(seconds: 7), () async {
      if (_activeBooking?.id != bookingId || _activeBooking?.status == AmbulanceStatus.cancelled) return;
      await repository.updateBookingStatus(
        bookingId,
        AmbulanceStatus.enRoute,
        estimatedMinutes: 7,
      );
      _activeBooking = _activeBooking?.copyWith(
        status: AmbulanceStatus.enRoute,
        estimatedMinutes: 7,
      );
      notifyListeners();
    }));

    // Step 3: Arrived on scene after 14 seconds
    _simulationTimers.add(Timer(const Duration(seconds: 14), () async {
      if (_activeBooking?.id != bookingId || _activeBooking?.status == AmbulanceStatus.cancelled) return;
      await repository.updateBookingStatus(
        bookingId,
        AmbulanceStatus.arrived,
        estimatedMinutes: 0,
      );
      _activeBooking = _activeBooking?.copyWith(
        status: AmbulanceStatus.arrived,
        estimatedMinutes: 0,
      );
      notifyListeners();
    }));
  }

  Future<void> cancelBooking() async {
    _cancelTimers();
    if (_activeBooking != null) {
      await repository.updateBookingStatus(_activeBooking!.id, AmbulanceStatus.cancelled);
      _activeBooking = null;
      notifyListeners();
    }
  }

  Future<void> completeBooking() async {
    _cancelTimers();
    if (_activeBooking != null) {
      await repository.updateBookingStatus(_activeBooking!.id, AmbulanceStatus.completed);
      _activeBooking = null;
      notifyListeners();
    }
  }

  void _cancelTimers() {
    for (final t in _simulationTimers) {
      t.cancel();
    }
    _simulationTimers.clear();
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }
}
