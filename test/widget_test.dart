import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safelife/app/app.dart';
import 'package:safelife/features/auth/screens/login_screen.dart';
import 'package:safelife/features/auth/screens/onboarding_screen.dart';
import 'package:safelife/features/dashboard/screens/dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('Dashboard renders Bangla-first and switches cleanly to English', (
    WidgetTester tester,
  ) async {
    // 1. Test Bangla default rendering
    await tester.pumpWidget(
      SafeLifeApp(
        initialLocale: const Locale('bn'),
        home: DashboardScreen(
          onToggleTheme: () {},
          onToggleLocale: () {},
          currentLocale: const Locale('bn'),
          currentThemeMode: ThemeMode.light,
        ),
      ),
    );
    await tester.pump();

    // Verify Bangla-first strings
    expect(find.text('সেফলাইফ'), findsOneWidget);
    expect(find.text('জরুরি এসওএস'), findsOneWidget);

    // Verify Direct Call Helplines (999 & 109)
    expect(find.textContaining('999'), findsOneWidget);
    expect(find.textContaining('109'), findsOneWidget);

    // 2. Test English rendering
    await tester.pumpWidget(
      SafeLifeApp(
        initialLocale: const Locale('en'),
        home: DashboardScreen(
          onToggleTheme: () {},
          onToggleLocale: () {},
          currentLocale: const Locale('en'),
          currentThemeMode: ThemeMode.light,
        ),
      ),
    );
    await tester.pump();

    // Verify English interface strings
    expect(find.text('SafeLife'), findsOneWidget);
    expect(find.text('SOS'), findsOneWidget);
    expect(find.textContaining('Women Safety'), findsOneWidget);
    expect(find.textContaining('Heart Attack'), findsOneWidget);
    expect(find.text('Stroke (FAST)'), findsOneWidget);
  });

  testWidgets('LoginScreen renders email, password fields and 999 direct button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const SafeLifeApp(
        initialLocale: Locale('en'),
        home: LoginScreen(),
      ),
    );
    await tester.pump();

    expect(find.byType(TextField), findsNWidgets(2)); // Email & Password
    expect(find.textContaining('999'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('OnboardingScreen renders first step and action button', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      SafeLifeApp(
        initialLocale: const Locale('en'),
        home: OnboardingScreen(
          onComplete: () {},
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(PageView), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
