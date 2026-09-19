import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../sos/providers/sos_provider.dart';
import '../../profile/models/emergency_contact.dart';

class SafetyTimerProvider extends ChangeNotifier {
  Timer? _timer;
  bool _isRunning = false;
  int _remainingSeconds = 0;
  int _initialSeconds = 0;
  bool _isExpired = false;

  bool get isRunning => _isRunning;
  int get remainingSeconds => _remainingSeconds;
  int get initialSeconds => _initialSeconds;
  bool get isExpired => _isExpired;
  bool get isWarning => _isRunning && _remainingSeconds <= 120 && _remainingSeconds > 0;

  double get progress => _initialSeconds > 0
      ? _remainingSeconds / _initialSeconds
      : 0.0;

  String get formattedTime {
    final minutes = (_remainingSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Start safety countdown timer
  void startTimer({
    required int minutes,
    required SosProvider sosProvider,
    required String userId,
    required String userName,
    required String userPhone,
    required List<EmergencyContact> contacts,
    required String language,
  }) {
    _cancelTimer();
    _isRunning = true;
    _isExpired = false;
    _initialSeconds = minutes * 60;
    _remainingSeconds = _initialSeconds;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isRunning) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds > 1) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        timer.cancel();
        _remainingSeconds = 0;
        _isExpired = true;
        _isRunning = false;
        notifyListeners();

        // Automatic SOS escalation when timer expires unconfirmed
        sosProvider.dispatchEmergency(
          userId: userId,
          userName: userName,
          userPhone: userPhone,
          contacts: contacts,
          language: language,
          triggerSource: 'safety_timer_expiration',
        );
      }
    });
  }

  /// User confirms they have arrived safely; stops timer
  void stopTimer() {
    _cancelTimer();
    _isRunning = false;
    _remainingSeconds = 0;
    _initialSeconds = 0;
    _isExpired = false;
    notifyListeners();
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }
}
