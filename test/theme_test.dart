import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safelife/app/theme/app_theme.dart';
import 'package:safelife/app/theme/color_schemes.dart';
import 'package:safelife/app/theme/risk_level_theme.dart';
import 'package:safelife/core/constants/alert_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('Theme System Tests', () {
    test('Light theme should use Material 3 and defined primary seed color', () {
      final lightTheme = AppTheme.light();
      expect(lightTheme.useMaterial3, isTrue);
      expect(lightTheme.colorScheme.primary, AppColorSchemes.lightColorScheme.primary);
    });

    test('Dark theme should use Material 3 and defined dark surface', () {
      final darkTheme = AppTheme.dark();
      expect(darkTheme.useMaterial3, isTrue);
      expect(darkTheme.colorScheme.surface, AppColorSchemes.darkSurface);
    });

    test('RiskLevelTheme extension provides distinct colors and accessible icons', () {
      final lightTheme = AppTheme.light();
      final riskTheme = lightTheme.extension<RiskLevelTheme>();
      expect(riskTheme, isNotNull);

      // Verify colors are mapped
      expect(riskTheme!.getColor(RiskLevel.low), riskTheme.low);
      expect(riskTheme.getColor(RiskLevel.medium), riskTheme.medium);
      expect(riskTheme.getColor(RiskLevel.high), riskTheme.high);
      expect(riskTheme.getColor(RiskLevel.critical), riskTheme.critical);

      // Verify icons are mapped for accessibility
      expect(riskTheme.getIcon(RiskLevel.low), isNotNull);
      expect(riskTheme.getIcon(RiskLevel.critical), isNotNull);
    });
  });
}
