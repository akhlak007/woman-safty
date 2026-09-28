import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safelife/app/routes.dart';
import 'package:safelife/core/errors/app_exceptions.dart';
import 'package:safelife/features/auth/models/user_profile.dart';
import 'package:safelife/features/auth/providers/auth_provider.dart';
import 'package:safelife/features/auth/repositories/auth_repository.dart';
import 'package:safelife/features/auth/screens/register_screen.dart';
import 'package:safelife/features/profile/repositories/profile_repository.dart';

class MockUser extends Fake implements User {
  @override
  final String uid;
  @override
  final String? email;
  String? _displayName;

  MockUser({required this.uid, this.email, String? displayName})
      : _displayName = displayName;

  @override
  String? get displayName => _displayName;

  @override
  String? get phoneNumber => '+8801700000000';

  @override
  Future<void> updateDisplayName(String? displayName) async {
    _displayName = displayName;
  }

  @override
  Future<IdTokenResult> getIdTokenResult([bool forceRefresh = false]) async {
    return MockIdTokenResult();
  }
}

class MockIdTokenResult extends Fake implements IdTokenResult {
  @override
  Map<String, dynamic>? get claims => const <String, dynamic>{};
}

class MockUserCredential extends Fake implements UserCredential {
  @override
  final User? user;

  MockUserCredential({this.user});
}

class MockAuthRepository extends Fake implements AuthRepository {
  final _controller = StreamController<User?>.broadcast();
  User? _current;

  @override
  Stream<User?> get authStateChanges => _controller.stream;

  @override
  User? get currentUser => _current;

  @override
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final mockUser = MockUser(uid: 'mock_uid_123', email: email);
    _current = mockUser;
    _controller.add(mockUser);
    return MockUserCredential(user: mockUser);
  }
}

class FailingProfileRepository extends Fake implements ProfileRepository {
  @override
  Stream<UserProfile?> streamUserProfile(String uid) {
    return const Stream.empty();
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    // Simulates Firestore permission-denied
    throw const AuthException('Failed to save profile information.', 'permission-denied');
  }
}

void main() {
  group('SafeLifeAuthProvider Registration & Resilience Tests', () {
    test('register succeeds and sets userProfile even when profile saving throws error', () async {
      final mockAuth = MockAuthRepository();
      final failingProfileRepo = FailingProfileRepository();

      final provider = SafeLifeAuthProvider(
        authRepository: mockAuth,
        profileRepository: failingProfileRepo,
      );

      final success = await provider.register(
        email: 'test@example.com',
        password: 'password123',
        name: 'Ayesha Rahman',
        phone: '+8801700000000',
      );

      expect(success, isTrue);
      expect(provider.errorMessage, isNull);
      expect(provider.user, isNotNull);
      expect(provider.user?.uid, 'mock_uid_123');
      expect(provider.userProfile, isNotNull);
      expect(provider.userProfile?.name, 'Ayesha Rahman');
      expect(provider.userProfile?.phone, '+8801700000000');
      expect(provider.userProfile?.email, 'test@example.com');
    });

    testWidgets('RegisterScreen submits and navigates to dashboard on success', (tester) async {
      final mockAuth = MockAuthRepository();
      final failingProfileRepo = FailingProfileRepository();

      final provider = SafeLifeAuthProvider(
        authRepository: mockAuth,
        profileRepository: failingProfileRepo,
      );

      bool navigatedToDashboard = false;
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ChangeNotifierProvider<SafeLifeAuthProvider>.value(
          value: provider,
          child: MaterialApp(
            initialRoute: AppRoutes.register,
            routes: {
              AppRoutes.register: (_) => const RegisterScreen(),
              AppRoutes.dashboard: (_) {
                navigatedToDashboard = true;
                return const Scaffold(body: Text('Dashboard View'));
              },
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter details
      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(5));

      await tester.enterText(textFields.at(0), 'Ayesha Rahman'); // Name
      await tester.enterText(textFields.at(1), '+8801700000000'); // Phone
      await tester.enterText(textFields.at(2), 'ayesha@example.com'); // Email
      await tester.enterText(textFields.at(3), 'secret123'); // Password
      await tester.enterText(textFields.at(4), 'secret123'); // Confirm password

      // Toggle disclaimer checkbox
      final checkboxFinder = find.byType(Checkbox);
      expect(checkboxFinder, findsOneWidget);
      await tester.ensureVisible(checkboxFinder);
      await tester.tap(checkboxFinder);
      await tester.pumpAndSettle();

      // Tap Create Account
      final submitButton = find.widgetWithText(FilledButton, 'Create Account');
      expect(submitButton, findsOneWidget);
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);

      await tester.pumpAndSettle();

      // Verify navigated to dashboard
      expect(navigatedToDashboard, isTrue);
      expect(find.text('Dashboard View'), findsOneWidget);
    });
  });
}
