import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safelife/features/settings/screens/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('SettingsScreen Widget Tests', () {
    testWidgets('Renders language toggle, appearance switch, and emergency countdown selector',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool themeToggled = false;
      bool localeToggled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(
            currentLocale: const Locale('en'),
            currentThemeMode: ThemeMode.light,
            onToggleTheme: () => themeToggled = true,
            onToggleLocale: () => localeToggled = true,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Check title and sections
      expect(find.text('Settings & Preferences'), findsOneWidget);
      expect(find.text('Language & Display'), findsOneWidget);
      expect(find.text('Emergency & SOS Preferences'), findsOneWidget);
      expect(find.text('Profile & Security'), findsOneWidget);
      expect(find.text('About SafeLife & Ethics'), findsOneWidget);

      // Verify toggle theme switch exists and works
      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);
      await tester.tap(switchFinder);
      expect(themeToggled, isTrue);

      // Verify toggle locale button works
      final langBtnFinder = find.text('বাংলায় দেখুন');
      expect(langBtnFinder, findsOneWidget);
      await tester.tap(langBtnFinder);
      expect(localeToggled, isTrue);

      // Verify countdown chips
      expect(find.text('3 seconds'), findsOneWidget);
      expect(find.text('5 seconds'), findsOneWidget);
      expect(find.text('10 seconds'), findsOneWidget);

      // Tap 10 seconds chip
      await tester.tap(find.text('10 seconds'));
      await tester.pump();

      // Clinical notice check
      expect(find.textContaining('CLINICAL NOTICE'), findsOneWidget);
      expect(find.textContaining('999'), findsWidgets);
    });
  });
}
