import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  static String normalizeForWhatsApp(String rawPhone) {
    String digits = rawPhone.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    if (digits.length == 10 && digits.startsWith('5')) {
      return '90$digits';
    }
    if (digits.length == 11 && digits.startsWith('05')) {
      return '90${digits.substring(1)}';
    }
    return digits;
  }

  static Future<bool> openChat(String rawPhone, {String message = ''}) async {
    final formattedPhone = normalizeForWhatsApp(rawPhone);
    if (formattedPhone.isEmpty) return false;

    final Uri url = Uri.parse('https://wa.me/$formattedPhone?text=${Uri.encodeComponent(message)}');

    try {
      if (await canLaunchUrl(url)) {
        return await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      return false;
    }
    return false;
  }
}
