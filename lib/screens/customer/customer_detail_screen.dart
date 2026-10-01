import 'package:flutter/material.dart';
import '../../models/customer.dart';
import '../../models/device.dart';
import '../../repositories/customer_repository.dart';
import '../../widgets/contact_buttons.dart';
import '../../services/url_launcher_service.dart';
import 'customer_form_screen.dart';

class CustomerDetailScreen extends StatefulWidget {
  final int customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  final _customerRepo = CustomerRepository();
  Customer? _customer;
  Device? _device;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final cust = await _customerRepo.getCustomerById(widget.customerId);
    final dev = await _customerRepo.getDeviceByCustomerId(widget.customerId);
    setState(() {
      _customer = cust;
      _device = dev;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Müşteri Detayı')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hata')),
        body: const Center(child: Text('Müşteri bulunamadı.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_customer!.fullName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CustomerFormScreen(customer: _customer),
                ),
              );
              if (result == true) _loadData();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          QuickContactButtons(phone: _customer!.phone),
          const SizedBox(height: 20),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Adres Bilgisi',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.map, color: Colors.blue),
                        onPressed: () {
                          final fullAddr = '${_customer!.district} ${_customer!.city} ${_customer!.address}';
                          UrlLauncherService.openMapLocation(context, fullAddr);
                        },
                      )
                    ],
                  ),
                  const Divider(),
                  Text('${_customer!.district} / ${_customer!.city}'),
                  const SizedBox(height: 4),
                  Text(_customer!.address, style: const TextStyle(color: Colors.black87)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cihaz ve Bakım Bilgileri',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.water_drop, color: Colors.blue, size: 32),
                    title: Text(_device?.brandModel ?? 'Cihaz Tanımlı Değil'),
                    subtitle: Text(
                      _device != null
                          ? 'Bakım Periyodu: ${_device!.filterChangePeriodMonths} Ayda Bir'
                          : 'Henüz cihaz bilgisi eklenmemiş.',
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_customer!.notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Özel Notlar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Divider(),
                    Text(_customer!.notes),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
