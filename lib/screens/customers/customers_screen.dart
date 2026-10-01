import 'package:flutter/material.dart';
import '../../repositories/customer_repository.dart';
import '../../models/customer.dart';
import '../../services/phone_service.dart';
import '../customer/customer_form_screen.dart';
import '../customer/customer_detail_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final CustomerRepository _repo = CustomerRepository();
  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final customers = await _repo.getAllCustomers();
    setState(() {
      _customers = customers;
      _filteredCustomers = customers;
      _isLoading = false;
    });
  }

  void _filterCustomers(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredCustomers = _customers;
      });
    } else {
      setState(() {
        _filteredCustomers = _customers.where((c) {
          return c.fullName.toLowerCase().contains(query.toLowerCase()) ||
              c.phone.contains(query);
        }).toList();
      });
    }
  }

  void _openCustomerForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CustomerFormScreen()),
    );
    if (result == true) {
      _loadCustomers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Müşteriler', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0A2540),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterCustomers,
              decoration: InputDecoration(
                hintText: '🔎 Müşteri ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A2540),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _openCustomerForm,
                icon: const Icon(Icons.add),
                label: const Text('+ Yeni Müşteri'),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCustomers.isEmpty
                    ? const Center(child: Text('Henüz müşteri yok.', style: TextStyle(fontSize: 16)))
                    : ListView.builder(
                        itemCount: _filteredCustomers.length,
                        itemBuilder: (context, index) {
                          final customer = _filteredCustomers[index];
                          return Card(
                            child: ListTile(
                              title: Text(customer.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('📞 ${customer.phone}'),
                                  Text('📍 ${customer.district ?? ''} / ${customer.city ?? ''}'),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.phone, color: Colors.green, size: 28),
                                onPressed: () => PhoneService.makePhoneCall(customer.phone),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CustomerDetailScreen(customerId: customer.id!),
                                  ),
                                ).then((_) => _loadCustomers());
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
