import 'package:flutter/material.dart';
import '../models/customer.dart';
import 'contact_buttons.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;
  final String? deviceModel;
  final VoidCallback? onTap;

  const CustomerCard({
    super.key,
    required this.customer,
    this.deviceModel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst Satır: Müşteri Adı ve Telefon Arama Butonu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.person, color: Colors.blueGrey, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            customer.fullName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Müşterinin yanında tek tıkla arama ikonu
                  PhoneIconButton(phone: customer.phone),
                ],
              ),
              const Divider(height: 16),
              // Telefon Numarası
              Row(
                children: [
                  const Icon(Icons.phone_android, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    customer.phone.isNotEmpty ? customer.phone : 'Telefon kayıtlı değil',
                    style: TextStyle(
                      fontSize: 14,
                      color: customer.phone.isNotEmpty ? Colors.black87 : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Adres
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${customer.district} / ${customer.city} - ${customer.address}',
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (deviceModel != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.water_drop_outlined, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      deviceModel!,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.blue),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
