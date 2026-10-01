import 'package:url_launcher/url_launcher.dart';

class PhoneService {
  static String normalizePhoneNumber(String rawPhone) {
    String digits = rawPhone.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    if (digits.length == 10 && digits.startsWith('5')) {
      return '+90$digits';
    }
    if (digits.length == 11 && digits.startsWith('05')) {
      return '+90${digits.substring(1)}';
    }
    if (digits.length == 12 && digits.startsWith('90')) {
      return '+$digits';
    }
    return '+$digits';
  }

  static Future<bool> makePhoneCall(String rawPhone) async {
    final normalized = normalizePhoneNumber(rawPhone);
    if (normalized.isEmpty) return false;

    final Uri launchUri = Uri(
      scheme: 'tel',
      path: normalized,
    );

    try {
      if (await canLaunchUrl(launchUri)) {
        return await launchUrl(launchUri);
      }
    } catch (_) {
      return false;
    }
    return false;
  }
}
