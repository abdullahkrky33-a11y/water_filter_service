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
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _notesController = TextEditingController();

  final CustomerRepository _repository = CustomerRepository();

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _nameController.text = widget.customer!.fullName;
      _phoneController.text = widget.customer!.phone;
      _addressController.text = widget.customer!.address;
      _cityController.text = widget.customer!.city ?? '';
      _districtController.text = widget.customer!.district ?? '';
      _notesController.text = widget.customer!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomer() async {
    if (_formKey.currentState!.validate()) {
      final customer = Customer(
        id: widget.customer?.id,
        fullName: _nameController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        city: _cityController.text,
        district: _districtController.text,
        notes: _notesController.text,
        createdAt: widget.customer?.createdAt ?? DateTime.now().toIso8601String(),
      );

      if (widget.customer == null) {
        await _repository.insertCustomer(customer);
      } else {
        await _repository.updateCustomer(customer);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer == null ? 'Yeni Müşteri' : 'Müşteri Düzenle'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Ad Soyad'),
              validator: (v) => v == null || v.isEmpty ? 'Gerekli alan' : null,
            ),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Telefon'),
              keyboardType: TextInputType.phone,
              validator: (v) => v == null || v.isEmpty ? 'Gerekli alan' : null,
            ),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Adres'),
              validator: (v) => v == null || v.isEmpty ? 'Gerekli alan' : null,
            ),
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(labelText: 'Şehir'),
            ),
            TextFormField(
              controller: _districtController,
              decoration: const InputDecoration(labelText: 'İlçe'),
            ),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notlar'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveCustomer,
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
