import 'package:url_launcher/url_launcher.dart';

/// Bangladesh Emergency & Essential Helpline Numbers
class EmergencyNumbers {
  const EmergencyNumbers._();

  /// National Emergency Service (Police, Fire Service, Ambulance)
  static const String nationalEmergency = '999';

  /// National Women and Children Helpline
  static const String womenAndChildrenHelpline = '109';

  /// National Call Center for Government Services & Social Safety
  static const String nationalHelpDesk = '333';

  /// National Human Rights Commission Hotline
  static const String humanRightsHotline = '16108';

  /// National Institute of Cardiovascular Diseases (NICVD) Emergency
  static const String nicvdEmergency = '+880258153096';

  /// Dhaka Medical College Hospital (DMCH) Emergency
  static const String dmchEmergency = '+880255165088';

  /// Helper to trigger a direct phone dialer
  static Future<bool> makeEmergencyCall(String phoneNumber) async {
    final sanitizedNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri(scheme: 'tel', path: sanitizedNumber);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }
}
