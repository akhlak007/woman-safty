import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/constants/alert_constants.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/sms_fallback_service.dart';
import '../../profile/models/emergency_contact.dart';
import '../models/emergency_case.dart';
import '../repositories/emergency_repository.dart';

class SosProvider extends ChangeNotifier {
  final EmergencyRepository _emergencyRepository;
  final LocationService _locationService;
  final SmsFallbackService _smsFallbackService;

  SosProvider({
    EmergencyRepository? emergencyRepository,
    LocationService? locationService,
    SmsFallbackService? smsFallbackService,
  })  : _emergencyRepository = emergencyRepository ?? EmergencyRepository(),
        _locationService = locationService ?? const LocationService(),
        _smsFallbackService = smsFallbackService ?? const SmsFallbackService();

  // Countdown state
  int _countdown = 5;
  Timer? _countdownTimer;
  bool _isCountingDown = false;

  // Active emergency state
  bool _isDispatching = false;
  EmergencyCase? _activeEmergency;
  EmergencyLocation? _currentLocation;
  String? _errorMessage;
  StreamSubscription<EmergencyLocation>? _locationSubscription;
  DateTime? _lastLocationUpdateTime;

  // Getters
  int get countdown => _countdown;
  bool get isCountingDown => _isCountingDown;
  bool get isDispatching => _isDispatching;
  EmergencyCase? get activeEmergency => _activeEmergency;
  bool get hasActiveEmergency => _activeEmergency != null && _activeEmergency!.status == EmergencyStatus.active;
  EmergencyLocation? get currentLocation => _currentLocation ?? _activeEmergency?.lastKnownLocation;
  String? get errorMessage => _errorMessage;

  /// Starts the 5-second SOS countdown before dispatch
  void startCountdown({
    required String userId,
    required String userName,
    required String userPhone,
    required List<EmergencyContact> contacts,
    required String language,
    EmergencyType type = EmergencyType.safety,
    VoidCallback? onCountdownFinished,
  }) {
    if (_isCountingDown || hasActiveEmergency) return;

    _countdown = 5;
    _isCountingDown = true;
    _errorMessage = null;
    notifyListeners();

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      _countdown--;
      notifyListeners();

      if (_countdown <= 0) {
        timer.cancel();
        _isCountingDown = false;
        notifyListeners();

        onCountdownFinished?.call();

        await dispatchEmergency(
          userId: userId,
          userName: userName,
          userPhone: userPhone,
          contacts: contacts,
          language: language,
          type: type,
        );
      }
    });
  }

  /// Cancels the ongoing countdown
  void cancelCountdown() {
    if (!_isCountingDown) return;
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _countdown = 5;
    _isCountingDown = false;
    notifyListeners();
  }

  /// Dispatches the emergency case immediately
  Future<EmergencyCase?> dispatchEmergency({
    required String userId,
    required String userName,
    required String userPhone,
    required List<EmergencyContact> contacts,
    required String language,
    EmergencyType type = EmergencyType.safety,
    Map<String, dynamic> triageAnswers = const {},
    RiskLevel riskLevel = RiskLevel.high,
    AlertLevel alertLevel = AlertLevel.emergencyContactAlert,
    String triggerSource = 'sos_button',
  }) async {
    _isDispatching = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Acquire current coordinates
      EmergencyLocation? location;
      try {
        location = await _locationService.getCurrentLocation();
        _currentLocation = location;
      } catch (_) {
        // Continue dispatching even if GPS is slow/temporarily unavailable
      }

      // 2. Prepare contact alert records
      final alertRecords = contacts.map((contact) {
        return ContactAlertRecord(
          contactId: contact.id,
          contactName: contact.name,
          contactPhone: contact.phone,
          channel: 'sms',
          status: 'pending',
          timestamp: DateTime.now(),
        );
      }).toList();

      // 3. Construct emergency case
      final newCase = EmergencyCase(
        id: '',
        userId: userId,
        userName: userName.isNotEmpty ? userName : 'SafeLife User',
        userPhone: userPhone,
        type: type,
        riskLevel: riskLevel,
        alertLevel: alertLevel,
        status: EmergencyStatus.active,
        createdAt: DateTime.now(),
        lastKnownLocation: location,
        triggerSource: triggerSource,
        triageAnswers: triageAnswers,
        contactAlerts: alertRecords,
      );

      // 4. Save to repository (Firestore + local offline cache)
      final savedCase = await _emergencyRepository.createEmergencyCase(newCase);
      _activeEmergency = savedCase;

      // 5. Trigger direct SMS fallback if contacts are configured
      if (contacts.isNotEmpty) {
        unawaited(_smsFallbackService.sendDirectSms(
          emergency: savedCase,
          contacts: contacts,
          language: language,
        ));
      }

      // 6. Start continuous live location tracking
      _startLocationTracking(savedCase.id);

      return savedCase;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isDispatching = false;
      notifyListeners();
    }
  }

  /// Starts live location stream and updates Firestore throttled
  void _startLocationTracking(String emergencyId) {
    _locationSubscription?.cancel();

    try {
      _locationSubscription = _locationService.getPositionStream(intervalSeconds: 5).listen(
        (newLoc) {
          _currentLocation = newLoc;
          if (_activeEmergency != null) {
            _activeEmergency = _activeEmergency!.copyWith(lastKnownLocation: newLoc);
          }
          notifyListeners();

          // Throttle remote Firestore updates to every 10 seconds
          final now = DateTime.now();
          if (_lastLocationUpdateTime == null ||
              now.difference(_lastLocationUpdateTime!).inSeconds >= 10) {
            _lastLocationUpdateTime = now;
            _emergencyRepository.updateLiveLocation(emergencyId, newLoc);
          }
        },
        onError: (_) {
          // GPS stream error - maintain last known location
        },
      );
    } catch (_) {}
  }

  /// Resolves or cancels the active emergency
  Future<void> resolveEmergency({
    EmergencyStatus status = EmergencyStatus.resolved,
  }) async {
    if (_activeEmergency == null) return;

    final caseId = _activeEmergency!.id;
    _locationSubscription?.cancel();
    _locationSubscription = null;

    final resolvedCase = _activeEmergency!.copyWith(
      status: status,
      resolvedAt: DateTime.now(),
    );

    _activeEmergency = null;
    _currentLocation = null;
    notifyListeners();

    await _emergencyRepository.updateStatus(
      caseId,
      status,
      resolvedAt: resolvedCase.resolvedAt,
    );
  }

  /// Restores active emergency state from cache or backend if available
  Future<void> restoreActiveEmergency(String userId) async {
    try {
      final cachedCase = await _emergencyRepository.getCachedActiveEmergency();
      if (cachedCase != null &&
          cachedCase.userId == userId &&
          cachedCase.status == EmergencyStatus.active) {
        _activeEmergency = cachedCase;
        _currentLocation = cachedCase.lastKnownLocation;
        _startLocationTracking(cachedCase.id);
        notifyListeners();
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _locationSubscription?.cancel();
    super.dispose();
  }
}
