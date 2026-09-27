import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/constants/alert_constants.dart';
import '../models/responder_case.dart';
import '../repositories/responder_repository.dart';

enum ResponderFilter {
  all,
  critical,
  cardiac,
  stroke,
  safety;

  String get label {
    switch (this) {
      case ResponderFilter.all:
        return 'All Active';
      case ResponderFilter.critical:
        return 'Critical Only';
      case ResponderFilter.cardiac:
        return 'Cardiac';
      case ResponderFilter.stroke:
        return 'Stroke (FAST)';
      case ResponderFilter.safety:
        return 'Women Safety';
    }
  }
}

class ResponderProvider extends ChangeNotifier {
  final ResponderRepository repository;

  StreamSubscription<List<ResponderCase>>? _subscription;
  List<ResponderCase> _allCases = [];
  ResponderCase? _selectedCase;
  ResponderFilter _activeFilter = ResponderFilter.all;
  bool _isLoading = true;

  ResponderProvider({ResponderRepository? repository, bool autoStart = true})
    : repository = repository ?? ResponderRepository() {
    if (autoStart) startListening();
  }

  List<ResponderCase> get allCases => _allCases;
  ResponderCase? get selectedCase => _selectedCase;
  ResponderFilter get activeFilter => _activeFilter;
  bool get isLoading => _isLoading;

  List<ResponderCase> get filteredCases {
    switch (_activeFilter) {
      case ResponderFilter.all:
        return _allCases;
      case ResponderFilter.critical:
        return _allCases
            .where((c) => c.emergencyCase.riskLevel == RiskLevel.critical)
            .toList();
      case ResponderFilter.cardiac:
        return _allCases
            .where((c) => c.emergencyCase.type == EmergencyType.cardiac)
            .toList();
      case ResponderFilter.stroke:
        return _allCases
            .where((c) => c.emergencyCase.type == EmergencyType.stroke)
            .toList();
      case ResponderFilter.safety:
        return _allCases
            .where((c) => c.emergencyCase.type == EmergencyType.safety)
            .toList();
    }
  }

  int get criticalCount => _allCases
      .where((c) => c.emergencyCase.riskLevel == RiskLevel.critical)
      .length;

  void startListening() {
    if (_subscription != null) return;
    _subscription = repository.streamActiveEmergencies().listen((cases) {
      _allCases = cases;
      _isLoading = false;

      if (_selectedCase != null) {
        final updatedSelected = _allCases.firstWhere(
          (c) => c.caseId == _selectedCase!.caseId,
          orElse: () => _selectedCase!,
        );
        _selectedCase = updatedSelected;
      } else if (_allCases.isNotEmpty) {
        _selectedCase = _allCases.first;
      }

      notifyListeners();
    });
  }

  void stopListeningAndClear() {
    _subscription?.cancel();
    _subscription = null;
    _allCases = [];
    _selectedCase = null;
    _activeFilter = ResponderFilter.all;
    _isLoading = true;
    notifyListeners();
  }

  void selectCase(ResponderCase rCase) {
    _selectedCase = rCase;
    notifyListeners();
  }

  void setFilter(ResponderFilter filter) {
    _activeFilter = filter;
    notifyListeners();
  }

  Future<void> acceptCase(String caseId, String unitName) async {
    final updated = await repository.acceptEmergency(caseId, unitName);
    _updateLocalCase(updated);
  }

  Future<void> updateStatus(String caseId, ResponderStatus status) async {
    final updated = await repository.updateResponderStatus(caseId, status);
    _updateLocalCase(updated);
  }

  Future<void> addNote(String caseId, String note) async {
    await repository.addNote(caseId, note);
    if (_selectedCase?.caseId == caseId) {
      final updatedNotes = List<String>.from(_selectedCase!.notes)..add(note);
      _selectedCase = _selectedCase!.copyWith(notes: updatedNotes);
      notifyListeners();
    }
  }

  void _updateLocalCase(ResponderCase updated) {
    final index = _allCases.indexWhere((c) => c.caseId == updated.caseId);
    if (index >= 0) {
      _allCases[index] = updated;
    }
    if (_selectedCase?.caseId == updated.caseId) {
      _selectedCase = updated;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
