import 'package:flutter/material.dart';
import '../../models/service_record.dart';
import '../../repositories/service_repository.dart';
import '../customer/customer_list_screen.dart';
import '../customer/customer_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _serviceRepo = ServiceRepository();
  List<ServiceRecord> _upcomingServices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    final upcoming = await _serviceRepo.getUpcomingServices(daysAhead: 30);
    setState(() {
      _upcomingServices = upcoming;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Su Arıtma Servis Takip'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Hızlı Menü Kartları
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CustomerListScreen()),
                      );
                    },
                    child: Card(
                      color: Colors.blue.shade700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
                        child: Column(
                          children: [
                            Icon(Icons.people, size: 36, color: Colors.white),
                            SizedBox(height: 8),
                            Text(
                              'Müşteriler',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Yaklaşan / Günü Gelen Bakımlar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text('${_upcomingServices.length} Müşteri'),
                  backgroundColor: Colors.orange.shade100,
                ),
              ],
            ),
            const Divider(),
            if (_isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
            else if (_upcomingServices.isEmpty)
              const Padding(
                padding: EdgeInsets.all(30.0),
                child: Center(
                  child: Text(
                    'Önümüzdeki 30 gün içinde bakımı gelen müşteri bulunmuyor.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _upcomingServices.length,
                itemBuilder: (context, index) {
                  final service = _upcomingServices[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.orange,
                        child: Icon(Icons.build, color: Colors.white),
                      ),
                      title: Text('Müşteri ID: #${service.customerId}'),
                      subtitle: Text(
                        'Tarih: ${service.nextServiceDate.day}.${service.nextServiceDate.month}.${service.nextServiceDate.year}',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CustomerDetailScreen(customerId: service.customerId),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
