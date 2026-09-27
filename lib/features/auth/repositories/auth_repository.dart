import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/errors/app_exceptions.dart';

class AuthRepository {
  final FirebaseAuth? firebaseAuth;

  AuthRepository({this.firebaseAuth});

  FirebaseAuth get _auth {
    try {
      return firebaseAuth ?? FirebaseAuth.instance;
    } catch (e) {
      throw const AuthException('Firebase Auth is not initialized.');
    }
  }

  Stream<User?> get authStateChanges {
    try {
      // Includes sign-in/out and refreshed custom authorization claims.
      return _auth.idTokenChanges();
    } catch (_) {
      return const Stream.empty();
    }
  }

  User? get currentUser {
    try {
      return _auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthErrorCode(e.code), e.message);
    } catch (e) {
      throw AuthException(
        'An unexpected error occurred during sign in.',
        e.toString(),
      );
    }
  }

  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthErrorCode(e.code), e.message);
    } catch (e) {
      throw AuthException(
        'An unexpected error occurred during registration.',
        e.toString(),
      );
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthErrorCode(e.code), e.message);
    } catch (e) {
      throw AuthException('Failed to send password reset email.', e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AuthException('Failed to sign out.', e.toString());
    }
  }

  String _mapAuthErrorCode(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password. Please check your credentials.';
      case 'email-already-in-use':
        return 'An account already exists for this email address.';
      case 'invalid-email':
        return 'The email address entered is invalid.';
      case 'weak-password':
        return 'The password is too weak. Please use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again in a few moments.';
      case 'network-request-failed':
        return 'Network connection failed. Please check your internet connection.';
      default:
        return 'Authentication error ($code). Please try again.';
    }
  }
}
