import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherService {
  /// Telefon numarasını normalize eder (sadece rakamları tutar)
  static String normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }

  /// Telefon numarasının geçerli olup olmadığını kontrol eder
  static bool isValidPhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) return false;
    final clean = normalizePhone(phone);
    return clean.length >= 10;
  }

  /// Doğrudan Android arama ekranına yönlendirir
  static Future<void> makePhoneCall(BuildContext context, String? phoneNumber) async {
    if (!isValidPhone(phoneNumber)) {
      _showSnackBar(context, 'Telefon numarası kayıtlı değil veya geçersiz.');
      return;
    }

    final cleanNumber = normalizePhone(phoneNumber!);
    final Uri uri = Uri(scheme: 'tel', path: cleanNumber);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) _showSnackBar(context, 'Arama uygulaması açılamadı.');
      }
    } catch (e) {
      if (context.mounted) _showSnackBar(context, 'Hata oluştu: Arama başlatılamadı.');
    }
  }

  /// WhatsApp uygulamasında sohbet başlatır
  static Future<void> sendWhatsAppMessage(BuildContext context, String? phoneNumber, {String message = ''}) async {
    if (!isValidPhone(phoneNumber)) {
      _showSnackBar(context, 'Telefon numarası kayıtlı değil veya geçersiz.');
      return;
    }

    var cleanNumber = normalizePhone(phoneNumber!);
    // Türkiye numaraları için +90 varsayılan ülke kodu ekleme kontrolü
    if (cleanNumber.startsWith('0')) {
      cleanNumber = '90${cleanNumber.substring(1)}';
    } else if (!cleanNumber.startsWith('90') && !cleanNumber.startsWith('+')) {
      cleanNumber = '90$cleanNumber';
    }

    final encodedMsg = Uri.encodeComponent(message);
    final Uri uri = Uri.parse('https://wa.me/$cleanNumber?text=$encodedMsg');

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        _showSnackBar(context, 'WhatsApp cihazınızda yüklü değil veya açılamadı.');
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'WhatsApp açılamadı. Lütfen uygulamanın yüklü olduğunu kontrol edin.');
      }
    }
  }

  /// Adresi Google Haritalar üzerinde açar
  static Future<void> openMapLocation(BuildContext context, String? address) async {
    if (address == null || address.trim().isEmpty) {
      _showSnackBar(context, 'Adres bilgisi bulunamadı.');
      return;
    }

    final encodedAddress = Uri.encodeComponent(address);
    final Uri uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedAddress');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) _showSnackBar(context, 'Harita uygulaması açılamadı.');
      }
    } catch (e) {
      if (context.mounted) _showSnackBar(context, 'Harita açılırken bir hata oluştu.');
    }
  }

  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
