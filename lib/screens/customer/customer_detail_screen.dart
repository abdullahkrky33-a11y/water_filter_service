import 'package:flutter/material.dart';

import '../../models/customer.dart';
import '../../models/device.dart';
import '../../models/device_filter.dart';
import '../../repositories/customer_repository.dart';
import '../../repositories/filter_repository.dart';

class CustomerDetailScreen extends StatefulWidget {
  final int customerId;

  const CustomerDetailScreen({
    super.key,
    required this.customerId,
  });

  @override
  State<CustomerDetailScreen> createState() =>
      _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  final CustomerRepository _customerRepo = CustomerRepository();
  final FilterRepository _filterRepo = FilterRepository();

  Customer? _customer;
  List<Device> _devices = [];
  final Map<int, List<DeviceFilter>> _deviceFilters = {};

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final customer =
          await _customerRepo.getCustomerById(widget.customerId);

      if (customer == null) {
        if (!mounted) return;

        setState(() {
          _customer = null;
          _devices = [];
          _isLoading = false;
        });

        return;
      }

      final devices =
          await _customerRepo.getDevicesByCustomerId(widget.customerId);

      final filters = <int, List<DeviceFilter>>{};

      for (final device in devices) {
        if (device.id == null) continue;

        filters[device.id!] =
            await _filterRepo.getDeviceFilters(device.id!);
      }

      if (!mounted) return;

      setState(() {
        _customer = customer;
        _devices = devices;
        _deviceFilters
          ..clear()
          ..addAll(filters);
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Müşteri bilgileri yüklenemedi.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Müşteri Detayı'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tekrar Dene'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_customer == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Müşteri Detayı'),
        ),
        body: const Center(
          child: Text('Müşteri bulunamadı.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_customer!.fullName),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildCustomerCard(),
            const SizedBox(height: 12),
            _buildDevicesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard() {
    final customer = _customer!;

    final addressParts = [
      if (customer.address.trim().isNotEmpty) customer.address.trim(),
      if (customer.district?.trim().isNotEmpty == true)
        customer.district!.trim(),
      if (customer.city?.trim().isNotEmpty == true) customer.city!.trim(),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(
                    customer.fullName.isNotEmpty
                        ? customer.fullName
                            .trim()
                            .substring(0, 1)
                            .toUpperCase()
                        : '?',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    customer.fullName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _infoRow(
              Icons.phone_outlined,
              'Telefon',
              customer.phone,
            ),
            if (customer.secondaryPhone?.trim().isNotEmpty == true)
              _infoRow(
                Icons.phone_android_outlined,
                'İkinci Telefon',
                customer.secondaryPhone!,
              ),
            if (addressParts.isNotEmpty)
              _infoRow(
                Icons.location_on_outlined,
                'Adres',
                addressParts.join(', '),
              ),
            if (customer.notes?.trim().isNotEmpty == true)
              _infoRow(
                Icons.notes_outlined,
                'Not',
                customer.notes!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevicesSection() {
    if (_devices.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(
                Icons.water_drop_outlined,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'Bu müşteriye henüz cihaz tanımlanmamış.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Cihazlar',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(width: 8),
            Chip(
              label: Text('${_devices.length}'),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._devices.map(_buildDeviceCard),
      ],
    );
  }

  Widget _buildDeviceCard(Device device) {
    final deviceId = device.id;
    final filters =
        deviceId == null ? <DeviceFilter>[] : _deviceFilters[deviceId] ?? [];

    final activeFilters =
        filters.where((filter) => filter.isActive).toList();

    final nextChangeDates = activeFilters
        .map((filter) => filter.nextChangeDate)
        .whereType<String>()
        .where((date) => date.trim().isNotEmpty)
        .toList()
      ..sort();

    final nextChange =
        nextChangeDates.isEmpty ? null : nextChangeDates.first;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.water_drop_outlined),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    device.brandModel.isEmpty
                        ? 'Cihaz'
                        : device.brandModel,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (!device.isActive)
                  const Chip(
                    label: Text('Pasif'),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _deviceInfoGrid(device),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(
                  Icons.filter_alt_outlined,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${activeFilters.length} aktif filtre',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            if (nextChange != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.event_outlined,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'En yakın filtre değişimi: $nextChange',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _deviceInfoGrid(Device device) {
    final items = <MapEntry<String, String>>[
      if (device.serialNumber?.trim().isNotEmpty == true)
        MapEntry('Seri No', device.serialNumber!),
      if (device.deviceType?.trim().isNotEmpty == true)
        MapEntry('Cihaz Tipi', device.deviceType!),
      if (device.tankCapacity?.trim().isNotEmpty == true)
        MapEntry('Tank', device.tankCapacity!),
      if (device.pumpType?.trim().isNotEmpty == true)
        MapEntry('Pompa', device.pumpType!),
      if (device.installationDate?.trim().isNotEmpty == true)
        MapEntry('Kurulum', device.installationDate!),
    ];

    if (items.isEmpty) {
      return const Text('Ek cihaz bilgisi bulunmuyor.');
    }

    return Wrap(
      spacing: 16,
      runSpacing: 10,
      children: items.map((item) {
        return SizedBox(
          width: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.key,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 2),
              Text(item.value),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 2),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
