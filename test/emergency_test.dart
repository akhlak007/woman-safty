import 'package:flutter_test/flutter_test.dart';
import 'package:safelife/core/constants/alert_constants.dart';
import 'package:safelife/core/constants/emergency_numbers.dart';

void main() {
  group('Emergency Constants Tests', () {
    test('Verified Bangladesh emergency numbers must be set correctly', () {
      expect(EmergencyNumbers.nationalEmergency, '999');
      expect(EmergencyNumbers.womenAndChildrenHelpline, '109');
      expect(EmergencyNumbers.nationalHelpDesk, '333');
    });

    test('Alert Levels and default countdown match specification', () {
      expect(AlertConstants.defaultCountdownSeconds, 5);
      expect(AlertLevel.informational.value, 1);
      expect(AlertLevel.emergencyContactAlert.value, 2);
      expect(AlertLevel.highPriority.value, 3);
      expect(AlertLevel.critical.value, 4);
    });

    test('Emergency types cover safety, cardiac, and stroke', () {
      final types = EmergencyType.values.map((e) => e.code).toList();
      expect(types, contains('safety'));
      expect(types, contains('cardiac'));
      expect(types, contains('stroke'));
    });
  });
}
