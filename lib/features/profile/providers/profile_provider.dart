import 'package:flutter/material.dart';
import '../../auth/models/user_profile.dart';
import '../repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository;

  bool _isSaving = false;
  String? _errorMessage;

  ProfileProvider({ProfileRepository? repository})
      : _repository = repository ?? ProfileRepository();

  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  Future<bool> saveProfile(UserProfile profile) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.saveUserProfile(profile);
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile.';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateMedicalDetails({
    required String uid,
    String? bloodGroup,
    required List<String> conditions,
    required List<String> medications,
    required List<String> allergies,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateMedicalInfo(
        uid: uid,
        bloodGroup: bloodGroup,
        conditions: conditions,
        medications: medications,
        allergies: allergies,
      );
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update medical details.';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }
}
