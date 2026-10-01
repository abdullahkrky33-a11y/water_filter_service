import 'package:flutter/material.dart';
import '../../models/customer.dart';
import '../../models/device.dart';
import '../../repositories/customer_repository.dart';

class CustomerDetailScreen extends StatefulWidget {
  final int customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  final CustomerRepository _customerRepo = CustomerRepository();
  Customer? _customer;
  Device? _device;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final customer = await _customerRepo.getCustomerById(widget.customerId);
    final device = await _customerRepo.getDeviceByCustomerId(widget.customerId);
    setState(() {
      _customer = customer;
      _device = device;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Müşteri Detayı')),
        body: const Center(child: Text('Müşteri bulunamadı.')),
      );
    }

    final notesText = _customer!.notes;

    return Scaffold(
      appBar: AppBar(
        title: Text(_customer!.fullName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: Text(_customer!.fullName),
                subtitle: Text('Telefon: ${_customer!.phone}\nAdres: ${_customer!.address}'),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.build),
                title: Text(_device?.brandModel != null && _device!.brandModel.isNotEmpty
                    ? _device!.brandModel
                    : 'Cihaz Tanımlı Değil'),
                subtitle: Text('Bakım Periyodu: ${_device?.filterChangePeriodMonths ?? 6} Ayda Bir'),
              ),
            ),
            if (notesText != null && notesText.isNotEmpty) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Notlar: $notesText'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
