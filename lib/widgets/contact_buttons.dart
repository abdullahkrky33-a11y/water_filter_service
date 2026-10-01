import 'package:flutter/material.dart';
import '../services/phone_service.dart';
import '../services/whatsapp_service.dart';

class ContactButtons extends StatelessWidget {
  final String phone;

  const ContactButtons({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.phone, color: Colors.green),
          onPressed: () => PhoneService.makePhoneCall(phone),
          tooltip: 'Ara',
        ),
        IconButton(
          icon: const Icon(Icons.message, color: Colors.blue),
          onPressed: () => WhatsAppService.openChat(phone),
          tooltip: 'WhatsApp',
        ),
      ],
    );
  }
}
