import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/onboarding_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/profile/providers/contacts_provider.dart';

class AuthWrapper extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final VoidCallback onToggleLocale;
  final Locale currentLocale;
  final ThemeMode currentThemeMode;

  const AuthWrapper({
    super.key,
    required this.onToggleTheme,
    required this.onToggleLocale,
    required this.currentLocale,
    required this.currentThemeMode,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _onboardingCompleted = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
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

    final auth = context.watch<SafeLifeAuthProvider>();

    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }

    // Bind authenticated user to contacts provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContactsProvider>().bindUser(auth.user?.uid);
    });

    return DashboardScreen(
      onToggleTheme: widget.onToggleTheme,
      onToggleLocale: widget.onToggleLocale,
      currentLocale: widget.currentLocale,
      currentThemeMode: widget.currentThemeMode,
    );
  }
}
