import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/onboarding_screen.dart';
import '../features/ambulance/providers/ambulance_provider.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/profile/providers/contacts_provider.dart';
import '../features/responder/providers/responder_provider.dart';
import '../features/safety_timer/providers/safety_timer_provider.dart';
import '../features/sos/providers/sos_provider.dart';

class AuthWrapper extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final VoidCallback onToggleLocale;
  final Locale currentLocale;
  final ThemeMode currentThemeMode;
  final bool websiteMode;

  const AuthWrapper({
    super.key,
    required this.onToggleTheme,
    required this.onToggleLocale,
    required this.currentLocale,
    required this.currentThemeMode,
    this.websiteMode = kIsWeb,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _onboardingCompleted = false;
  String? _syncedUserId;
  bool _syncedResponderAccess = false;
  bool _hasSyncedSession = false;

  @override
  void initState() {
    super.initState();
    if (widget.websiteMode) {
      _isLoading = false;
    } else {
      _checkOnboarding();
    }
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool(OnboardingScreen.keyCompleted) ?? false;
    if (mounted) {
      setState(() {
        _onboardingCompleted = completed;
        _isLoading = false;
      });
    }
  }

  void _syncUserSession(
    BuildContext context,
    String? userId,
    bool canAccessResponder,
  ) {
    if (_hasSyncedSession &&
        _syncedUserId == userId &&
        _syncedResponderAccess == canAccessResponder) {
      return;
    }
    final accountChanged = !_hasSyncedSession || _syncedUserId != userId;
    _hasSyncedSession = true;
    _syncedUserId = userId;
    _syncedResponderAccess = canAccessResponder;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      context.read<ContactsProvider>().bindUser(userId);
      context.read<AmbulanceProvider>().bindUser(userId);

      if (accountChanged || !canAccessResponder) {
        context.read<ResponderProvider>().stopListeningAndClear();
      }

      final sos = context.read<SosProvider>();
      if (accountChanged) sos.clearSession();
      if (userId == null || userId.isEmpty) {
        context.read<SafetyTimerProvider>().stopTimer();
      } else {
        sos.restoreActiveEmergency(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<SafeLifeAuthProvider>();
    _syncUserSession(context, auth.user?.uid, auth.canAccessResponder);

    if (widget.websiteMode) {
      return DashboardScreen(
        onToggleTheme: widget.onToggleTheme,
        onToggleLocale: widget.onToggleLocale,
        currentLocale: widget.currentLocale,
        currentThemeMode: widget.currentThemeMode,
      );
    }

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_onboardingCompleted) {
      return OnboardingScreen(
        onComplete: () {
          setState(() {
            _onboardingCompleted = true;
          });
        },
      );
    }

    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }

    return DashboardScreen(
      onToggleTheme: widget.onToggleTheme,
      onToggleLocale: widget.onToggleLocale,
      currentLocale: widget.currentLocale,
      currentThemeMode: widget.currentThemeMode,
    );
  }
}
