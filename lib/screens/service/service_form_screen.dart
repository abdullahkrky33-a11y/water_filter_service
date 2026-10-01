import 'package:flutter/material.dart';
import '../../models/service_record.dart';
import '../../models/payment.dart';
import '../../models/filter.dart';
import '../../repositories/service_repository.dart';

class ServiceFormScreen extends StatefulWidget {
  final int customerId;

  const ServiceFormScreen({super.key, required this.customerId});

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serviceRepo = ServiceRepository();

  final _notesController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _paidAmountController = TextEditingController();

  DateTime _serviceDate = DateTime.now();
  int _nextPeriodMonths = 6;

  final List<FilterItem> _availableFilters = FilterItem.standardFilters;
  final List<String> _selectedFilterNames = [];

  @override
  void dispose() {
    _notesController.dispose();
    _totalAmountController.dispose();
    _paidAmountController.dispose();
    super.dispose();
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) return;

    final double totalAmount = double.tryParse(_totalAmountController.text) ?? 0.0;
    final double paidAmount = double.tryParse(_paidAmountController.text) ?? 0.0;
    final double remainingDebt = totalAmount - paidAmount;

    final nextServiceDate = DateTime(
      _serviceDate.year,
      _serviceDate.month + _nextPeriodMonths,
      _serviceDate.day,
    );

    final record = ServiceRecord(
      customerId: widget.customerId,
      serviceDate: _serviceDate,
      nextServiceDate: nextServiceDate,
      changedFilters: _selectedFilterNames.join(', '),
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      remainingDebt: remainingDebt,
      notes: _notesController.text.trim(),
    );

    final serviceId = await _serviceRepo.insertServiceRecord(record);

    if (paidAmount > 0) {
      final payment = Payment(
        customerId: widget.customerId,
        serviceRecordId: serviceId,
        amount: paidAmount,
        paymentDate: _serviceDate,
        notes: 'Servis anında yapılan tahsilat',
      );
      await _serviceRepo.insertPayment(payment);
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Servis / Bakım Kaydı'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Text(
              'Değişen Filtreler',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: _availableFilters.map((filter) {
                final isSelected = _selectedFilterNames.contains(filter.name);
                return FilterChip(
                  label: Text(filter.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedFilterNames.add(filter.name);
                      } else {
                        _selectedFilterNames.remove(filter.name);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const Divider(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _totalAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Toplam Tutar (TL) *',
                      prefixIcon: Icon(Icons.payments),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Tutar giriniz' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _paidAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Alınan Ücret (TL)',
                      prefixIcon: Icon(Icons.money),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _nextPeriodMonths,
              decoration: const InputDecoration(
                labelText: 'Sonraki Bakım Zamanı',
                prefixIcon: Icon(Icons.event_repeat),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 3, child: Text('3 Ay Sonra')),
                DropdownMenuItem(value: 6, child: Text('6 Ay Sonra (Standart)')),
                DropdownMenuItem(value: 12, child: Text('1 Yıl Sonra')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _nextPeriodMonths = val);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Servis Notu / Açıklama',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.check_circle),
              label: const Text(
                'SERVISİ KAYDET VE BİTİR',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: _saveService,
            ),
          ],
        ),
      ),
    );
  }
}
