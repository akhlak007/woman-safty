import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../repositories/auth_repository.dart';
import '../../profile/repositories/profile_repository.dart';
import '../../../core/errors/app_exceptions.dart';

class SafeLifeAuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;

  User? _user;
  UserProfile? _userProfile;
  bool _isAdmin = false;
  bool _isResponder = false;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<UserProfile?>? _profileSubscription;

  SafeLifeAuthProvider({
    AuthRepository? authRepository,
    ProfileRepository? profileRepository,
  }) : _authRepository = authRepository ?? AuthRepository(),
       _profileRepository = profileRepository ?? ProfileRepository() {
    _init();
  }

  User? get user => _user;
  UserProfile? get userProfile => _userProfile;
  bool get isAuthenticated => _user != null;
  bool get canAccessAdmin => _isAdmin;
  bool get canAccessResponder => _isResponder;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _init() {
    _authSubscription = _authRepository.authStateChanges.listen((firebaseUser) {
      _user = firebaseUser;
      _isAdmin = false;
      _isResponder = false;
      if (firebaseUser != null) {
        _subscribeToProfile(firebaseUser.uid);
        _loadAuthorizationClaims(firebaseUser);
      } else {
        _profileSubscription?.cancel();
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadAuthorizationClaims(User firebaseUser) async {
    try {
      final token = await firebaseUser.getIdTokenResult();
      if (_user?.uid != firebaseUser.uid) return;
      final claims = token.claims ?? const <String, dynamic>{};
      _isAdmin = claims['admin'] == true;
      _isResponder = _isAdmin || claims['responder'] == true;
      notifyListeners();
    } catch (_) {
      // Authorization fails closed when claims cannot be verified.
      if (_user?.uid == firebaseUser.uid) {
        _isAdmin = false;
        _isResponder = false;
        notifyListeners();
      }
    }
  }

  void _subscribeToProfile(String uid) {
    _profileSubscription?.cancel();
    _profileSubscription = _profileRepository.streamUserProfile(uid).listen((
      profile,
    ) {
      _userProfile = profile;
      notifyListeners();
    });
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An error occurred during sign in.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authRepository.registerWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user?.uid;
      if (uid != null) {
        final profile = UserProfile(
          uid: uid,
          name: name.trim(),
          phone: phone.trim(),
          email: email.trim(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _profileRepository.saveUserProfile(profile);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An error occurred during registration.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.sendPasswordResetEmail(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to send password reset email.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    await _authRepository.signOut();
    _user = null;
    _userProfile = null;
    _isAdmin = false;
    _isResponder = false;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _profileSubscription?.cancel();
    super.dispose();
  }
}
