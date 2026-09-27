import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safelife/app/app.dart';
import 'package:safelife/app/auth_wrapper.dart';
import 'package:safelife/features/auth/screens/login_screen.dart';
import 'package:safelife/features/auth/screens/onboarding_screen.dart';
import 'package:safelife/features/dashboard/screens/dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  Widget buildDashboard() {
    return SafeLifeApp(
      initialLocale: const Locale('en'),
      home: DashboardScreen(
        onToggleTheme: () {},
        onToggleLocale: () {},
        currentLocale: const Locale('en'),
        currentThemeMode: ThemeMode.light,
      ),
    );
  }

  testWidgets('Web startup opens the public website dashboard directly', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      SafeLifeApp(
        initialLocale: const Locale('en'),
        home: AuthWrapper(
          websiteMode: true,
          onToggleTheme: () {},
          onToggleLocale: () {},
          currentLocale: const Locale('en'),
          currentThemeMode: ThemeMode.light,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Fast help when\nevery second matters.'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('Public website hides staff tools and protects SOS', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildDashboard());
    await tester.pump();

    expect(find.text('Responder & Hospital Command Panel'), findsNothing);
    expect(find.text('Admin Analytics Portal'), findsNothing);

    await tester.tap(find.byIcon(Icons.emergency_rounded).first);
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Native startup keeps the onboarding flow', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      SafeLifeApp(
        initialLocale: const Locale('en'),
        home: AuthWrapper(
          websiteMode: false,
          onToggleTheme: () {},
          onToggleLocale: () {},
          currentLocale: const Locale('en'),
          currentThemeMode: ThemeMode.light,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.byType(DashboardScreen), findsNothing);
  });

  testWidgets('Dashboard and drawer do not overflow a compact phone viewport', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildDashboard());
    await tester.pump();
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.text('Navigation'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Dashboard adapts without overflow on tablet and desktop', (
    WidgetTester tester,
  ) async {
    for (final size in <Size>[const Size(768, 1024), const Size(1440, 900)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(buildDashboard());
      await tester.pump();
      expect(tester.takeException(), isNull, reason: 'Failed at $size');
    }
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });

  testWidgets(
    'Dashboard renders Bangla-first and switches cleanly to English',
    (WidgetTester tester) async {
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
    },
  );

  testWidgets(
    'LoginScreen renders email, password fields and 999 direct button',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const SafeLifeApp(initialLocale: Locale('en'), home: LoginScreen()),
      );
      await tester.pump();

      expect(find.byType(TextField), findsNWidgets(2)); // Email & Password
      expect(find.textContaining('999'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    },
  );

  testWidgets('OnboardingScreen renders first step and action button', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      SafeLifeApp(
        initialLocale: const Locale('en'),
        home: OnboardingScreen(onComplete: () {}),
      ),
    );
    await tester.pump();

    expect(find.byType(PageView), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
