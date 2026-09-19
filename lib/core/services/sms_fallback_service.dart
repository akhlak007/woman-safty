import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../features/profile/models/emergency_contact.dart';
import '../../features/sos/models/emergency_case.dart';

class SmsFallbackService {
  const SmsFallbackService();

  /// Formats the emergency SMS alert payload
  String formatEmergencyMessage({
    required EmergencyCase emergency,
    required String language,
  }) {
    final timeStr = DateFormat('hh:mm a, dd MMM').format(emergency.createdAt);
    final mapUrl = emergency.lastKnownLocation?.googleMapsUrl ??
        'Location unavailable (GPS timeout)';

    if (language == 'bn') {
      return '[সেফলাইফ জরুরি সতর্কতা]\n'
          '${emergency.userName} জরুরি এসওএস পাঠিয়েছেন!\n'
          'ধরন: ${emergency.type.displayName}\n'
          'অবস্থান: $mapUrl\n'
          'সময়: $timeStr\n'
          'যোগাযোগ: ${emergency.userPhone} অথবা জরুরি সেবা ৯৯৯ এ কল করুন।';
    }

    return '[SafeLife EMERGENCY ALERT]\n'
        '${emergency.userName} triggered an SOS!\n'
        'Type: ${emergency.type.displayName}\n'
        'Live Location: $mapUrl\n'
        'Time: $timeStr\n'
        'Call: ${emergency.userPhone} or National Emergency 999 immediately.';
  }

  /// Launches the native SMS composer targeting verified contacts
  Future<bool> sendDirectSms({
    required EmergencyCase emergency,
    required List<EmergencyContact> contacts,
    required String language,
  }) async {
    if (contacts.isEmpty) return false;

    final phoneNumbers = contacts
        .map((c) => c.phone.replaceAll(RegExp(r'\s+'), ''))
        .where((p) => p.isNotEmpty)
        .join(',');

    final messageBody = formatEmergencyMessage(
      emergency: emergency,
      language: language,
    );

    final uri = Uri(
      scheme: 'sms',
      path: phoneNumbers,
      queryParameters: <String, String>{
        'body': messageBody,
      },
    );

    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
