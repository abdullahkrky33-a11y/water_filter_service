import 'package:flutter/material.dart';
import '../../repositories/customer_repository.dart';
import '../../models/customer.dart';
import '../customer/customer_form_screen.dart';
import '../customer/customer_detail_screen.dart';
import '../service/service_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final CustomerRepository _repo = CustomerRepository();
  int _totalCustomers = 0;
  List<Customer> _recentCustomers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final customers = await _repo.getAllCustomers();
    setState(() {
      _totalCustomers = customers.length;
      _recentCustomers = customers.take(5).toList();
      _isLoading = false;
    });
  }

  void _openCustomerForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CustomerFormScreen()),
    );
    if (result == true) {
      _loadDashboardData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Su Arıtma Servis', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0A2540),
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bugünün Özeti', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildStatCard('👥 Toplam Müşteri', '$_totalCustomers', Colors.blue),
                  _buildStatCard('🔧 Bugünkü Bakım', '0', Colors.orange),
                  _buildStatCard('⚠️ Geciken Bakım', '0', Colors.red),
                  _buildStatCard('💰 Bekleyen Tahsilat', '₺0', Colors.green),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Hızlı İşlemler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF0A2540),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _openCustomerForm,
                      icon: const Icon(Icons.person_add),
                      label: const Text('+ Yeni Müşteri'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF00A3E0),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ServiceFormScreen()),
                        );
                      },
                      icon: const Icon(Icons.build),
                      label: const Text('🔧 Yeni Servis'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Yaklaşan Bakımlar / Son Müşteriler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_recentCustomers.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const Icon(Icons.people_outline, size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        const Text('Henüz müşteri bulunmuyor.', style: TextStyle(fontWeight: FontWeight.bold)),
                        const Text('İlk müşterinizi ekleyerek başlayın.', style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _openCustomerForm,
                          child: const Text('+ İlk Müşteriyi Ekle'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _recentCustomers.length,
                  itemBuilder: (context, index) {
                    final customer = _recentCustomers[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF00A3E0),
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(customer.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('📞 ${customer.phone}\n📍 ${customer.district ?? ''} / ${customer.city ?? ''}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CustomerDetailScreen(customerId: customer.id!),
                            ),
                          ).then((_) => _loadDashboardData());
                        },
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 13, color: Colors.black87)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
