import 'package:flutter/material.dart';
import '../services/url_launcher_service.dart';

/// Kart üzeri tek tıkla arama ikonu (Büyük dokunma alanı)
class PhoneIconButton extends StatelessWidget {
  final String? phone;
  final double size;

  const PhoneIconButton({
    super.key,
    required this.phone,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    final bool isValid = UrlLauncherService.isValidPhone(phone);

    return Tooltip(
      message: 'Müşteriyi Ara',
      child: IconButton(
        icon: Icon(
          Icons.phone_in_talk,
          color: isValid ? Theme.of(context).primaryColor : Colors.grey.shade400,
          size: size,
        ),
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48), // Ergonomik dokunma alanı
        onPressed: isValid
            ? () => UrlLauncherService.makePhoneCall(context, phone)
            : () => UrlLauncherService.makePhoneCall(context, null), // Hata uyarısı verir
      ),
    );
  }
}

/// Müşteri Detay Ekranı İçin Yan Yana [📞 ARA] ve [💬 WHATSAPP] Butonları
class QuickContactButtons extends StatelessWidget {
  final String? phone;

  const QuickContactButtons({
    super.key,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    final bool isValid = UrlLauncherService.isValidPhone(phone);

    return Row(
      children: [
        // ARA BUTONU
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 2,
            ),
            icon: const Icon(Icons.phone, size: 20),
            label: const Text(
              '📞 ARA',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            onPressed: () => UrlLauncherService.makePhoneCall(context, phone),
          ),
        ),
        const SizedBox(width: 12),
        // WHATSAPP BUTONU
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366), // WhatsApp Yeşili
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 2,
            ),
            icon: const Icon(Icons.chat, size: 20),
            label: const Text(
              '💬 WHATSAPP',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            onPressed: () => UrlLauncherService.sendWhatsAppMessage(context, phone),
          ),
        ),
      ],
    );
  }
}
