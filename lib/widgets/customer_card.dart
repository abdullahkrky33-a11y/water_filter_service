import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../models/device.dart';
import 'contact_buttons.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;
  final Device? device;
  final VoidCallback? onTap;

  const CustomerCard({
    super.key,
    required this.customer,
    this.device,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        title: Text(
          customer.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('📞 ${customer.phone}'),
            Text('📍 ${customer.address}'),
            if (device != null) ...[
              const SizedBox(height: 4),
              Text('💧 ${device!.brandModel}'),
            ],
          ],
        ),
        trailing: ContactButtons(phone: customer.phone),
      ),
    );
  }
}
