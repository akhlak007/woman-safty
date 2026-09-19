import 'dart:async';
import 'package:flutter/material.dart';
import '../models/emergency_contact.dart';
import '../repositories/contacts_repository.dart';

class ContactsProvider extends ChangeNotifier {
  final ContactsRepository _repository;

  List<EmergencyContact> _contacts = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<EmergencyContact>>? _subscription;
  String? _currentUserId;

  ContactsProvider({ContactsRepository? repository})
      : _repository = repository ?? ContactsRepository();

  List<EmergencyContact> get contacts => _contacts;
  List<EmergencyContact> get verifiedContacts =>
      _contacts.where((c) => c.verified).toList();
  List<EmergencyContact> get pendingContacts =>
      _contacts.where((c) => !c.verified).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void bindUser(String? userId) {
    if (_currentUserId == userId) return;
    _currentUserId = userId;
    _subscription?.cancel();

    if (userId != null && userId.isNotEmpty) {
      _isLoading = true;
      notifyListeners();

      _subscription = _repository.streamContacts(userId).listen(
        (data) {
          _contacts = data;
          _isLoading = false;
          notifyListeners();
        },
        onError: (err) {
          _errorMessage = err.toString();
          _isLoading = false;
          notifyListeners();
        },
      );
    } else {
      _contacts = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addContact(EmergencyContact contact) async {
    if (_currentUserId == null) return false;
    try {
      await _repository.addContact(_currentUserId!, contact);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateContact(EmergencyContact contact) async {
    if (_currentUserId == null) return false;
    try {
      await _repository.updateContact(_currentUserId!, contact);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteContact(String contactId) async {
    if (_currentUserId == null) return false;
    try {
      await _repository.deleteContact(_currentUserId!, contactId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<String?> requestConsent(String contactId) async {
    if (_currentUserId == null) return null;
    try {
      final code = await _repository.requestContactConsent(_currentUserId!, contactId);
      return code;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> verifyConsent(String contactId, String code) async {
    if (_currentUserId == null) return false;
    try {
      final success = await _repository.verifyContactConsent(
        _currentUserId!,
        contactId,
        code,
      );
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
