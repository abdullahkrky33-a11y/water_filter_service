import 'package:flutter/material.dart';
import '../../models/customer.dart';
import '../../models/device.dart';
import '../../repositories/customer_repository.dart';

class CustomerFormScreen extends StatefulWidget {
  final Customer? customer;

  const CustomerFormScreen({super.key, this.customer});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerRepo = CustomerRepository();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _districtController;
  late TextEditingController _addressController;
  late TextEditingController _notesController;
  late TextEditingController _deviceBrandController;

  int _filterPeriodMonths = 6;
  DateTime _installationDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.fullName ?? '');
    _phoneController = TextEditingController(text: widget.customer?.phone ?? '');
    _cityController = TextEditingController(text: widget.customer?.city ?? 'Mersin');
    _districtController = TextEditingController(text: widget.customer?.district ?? '');
    _addressController = TextEditingController(text: widget.customer?.address ?? '');
    _notesController = TextEditingController(text: widget.customer?.notes ?? '');
    _deviceBrandController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _deviceBrandController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    final customer = Customer(
      id: widget.customer?.id,
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      city: _cityController.text.trim(),
      district: _districtController.text.trim(),
      address: _addressController.text.trim(),
      notes: _notesController.text.trim(),
      createdAt: widget.customer?.createdAt ?? DateTime.now(),
    );

    if (widget.customer == null) {
      final newId = await _customerRepo.insertCustomer(customer);
      if (_deviceBrandController.text.isNotEmpty) {
        final device = Device(
          customerId: newId,
          brandModel: _deviceBrandController.text.trim(),
          installationDate: _installationDate,
          filterChangePeriodMonths: _filterPeriodMonths,
        );
        await _customerRepo.insertDevice(device);
      }
    } else {
      await _customerRepo.updateCustomer(customer);
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.customer != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Müşteri Düzenle' : 'Yeni Müşteri Ekle'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Ad Soyad *',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Ad Soyad giriniz' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Telefon Numarası *',
                hintText: '05XXXXXXXXX',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().length < 10) ? 'Geçerli bir telefon giriniz' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'İl',
                      prefixIcon: Icon(Icons.location_city),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _districtController,
                    decoration: const InputDecoration(
                      labelText: 'İlçe',
                      prefixIcon: Icon(Icons.map),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Açık Adres',
                prefixIcon: Icon(Icons.home),
                border: OutlineInputBorder(),
              ),
            ),
            if (!isEdit) ...[
              const SizedBox(height: 20),
              const Text(
                'Cihaz Bilgileri',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
              const Divider(),
              const SizedBox(height: 8),
              TextFormField(
                controller: _deviceBrandController,
                decoration: const InputDecoration(
                  labelText: 'Cihaz Marka / Modeli',
                  hintText: 'Örn: 5 Aşamalı Pompasız',
                  prefixIcon: Icon(Icons.water_drop),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _filterPeriodMonths,
                decoration: const InputDecoration(
                  labelText: 'Filtre Değişim Periyodu',
                  prefixIcon: Icon(Icons.timer),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 3, child: Text('3 Ayda Bir')),
                  DropdownMenuItem(value: 6, child: Text('6 Ayda Bir (Standart)')),
                  DropdownMenuItem(value: 12, child: Text('12 Ayda Bir (Yıllık)')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _filterPeriodMonths = val);
                },
              ),
            ],
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Özel Notlar',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.save),
              label: Text(
                isEdit ? 'GÜNCELLE' : 'KAYDET',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: _saveCustomer,
            ),
          ],
        ),
      ),
    );
  }
}
