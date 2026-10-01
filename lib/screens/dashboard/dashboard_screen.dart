import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/customer.dart';
import '../../models/service_record.dart';
import '../../repositories/customer_repository.dart';
import '../../repositories/filter_repository.dart';
import '../../repositories/service_repository.dart';
import '../customer/customer_detail_screen.dart';
import '../customer/customer_form_screen.dart';
import '../service/service_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final CustomerRepository _customerRepository = CustomerRepository();
  final ServiceRepository _serviceRepository = ServiceRepository();
  final FilterRepository _filterRepository = FilterRepository();

  bool _isLoading = true;

  int _totalCustomers = 0;
  int _todayServices = 0;
  int _overdueServices = 0;
  int _overdueFilters = 0;

  double _totalReceivable = 0;
  double _todayCollected = 0;

  List<Customer> _recentCustomers = [];
  List<ServiceRecord> _upcomingServices = [];

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 2,
  );

  final DateFormat _dateFormat = DateFormat(
    'dd.MM.yyyy',
    'tr_TR',
  );

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final customers = await _customerRepository.getAllCustomers();
      final services = await _serviceRepository.getAllServiceRecords();
      final payments = await _serviceRepository.getAllPayments();

      final upcomingServices =
          await _serviceRepository.getUpcomingServices(daysAhead: 30);

      final overdueServices =
          await _serviceRepository.getOverdueServices();

      final overdueFilters =
          await _filterRepository.getOverdueDeviceFilters();

      final now = DateTime.now();
      final today = _dateOnly(now);

      final todayServices = services.where((service) {
        return service.serviceDate == today;
      }).length;

      final todayCollected = payments
          .where((payment) => payment.paymentDate == today)
          .fold<double>(
            0,
            (total, payment) => total + payment.amount,
          );

      final totalServiceAmount = services.fold<double>(
        0,
        (total, service) => total + service.totalAmount,
      );

      final totalPayments = payments.fold<double>(
        0,
        (total, payment) => total + payment.amount,
      );

      final receivable = totalServiceAmount - totalPayments;

      if (!mounted) return;

      setState(() {
        _totalCustomers = customers.length;
        _todayServices = todayServices;
        _overdueServices = overdueServices.length;
        _overdueFilters = overdueFilters.length;
        _todayCollected = todayCollected;
        _totalReceivable = receivable > 0 ? receivable : 0;

        _recentCustomers = customers.take(5).toList();
        _upcomingServices = upcomingServices.take(5).toList();

        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Dashboard verileri yüklenemedi: $error',
          ),
        ),
      );
    }
  }

  Future<void> _openCustomerForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CustomerFormScreen(),
      ),
    );

    if (result == true) {
      await _loadDashboardData();
    }
  }

  Future<void> _openServiceForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ServiceFormScreen(),
      ),
    );

    if (result == true) {
      await _loadDashboardData();
    }
  }

  String _dateOnly(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  String _formatServiceDate(String value) {
    final parsed = DateTime.tryParse(value);

    if (parsed == null) {
      return value;
    }

    return _dateFormat.format(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboardData,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      _buildStatistics(),
                      const SizedBox(height: 22),
                      _buildQuickActions(),
                      const SizedBox(height: 22),
                      _buildUpcomingServices(),
                      const SizedBox(height: 22),
                      _buildRecentCustomers(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0A2540),
            Color(0xFF123D63),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.water_drop,
                  color: Colors.white,
                  size: 27,
                ),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Su Arıtma',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Servis Yönetimi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _loadDashboardData,
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                ),
                tooltip: 'Yenile',
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            'Bugün',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.70),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _dateFormat.format(now),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    if (_isLoading) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Genel Durum',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.42,
          children: [
            _buildStatCard(
              title: 'Müşteriler',
              value: '$_totalCustomers',
              icon: Icons.people_alt_outlined,
              iconColor: const Color(0xFF0A72B8),
              backgroundColor: const Color(0xFFE8F4FC),
            ),
            _buildStatCard(
              title: 'Bugünkü Servis',
              value: '$_todayServices',
              icon: Icons.build_circle_outlined,
              iconColor: const Color(0xFFB76E00),
              backgroundColor: const Color(0xFFFFF4DF),
            ),
            _buildStatCard(
              title: 'Bekleyen Alacak',
              value: _currencyFormat.format(_totalReceivable),
              icon: Icons.payments_outlined,
              iconColor: const Color(0xFF087F5B),
              backgroundColor: const Color(0xFFE8F8F2),
            ),
            _buildStatCard(
              title: 'Geciken İşler',
              value: '${_overdueServices + _overdueFilters}',
              icon: Icons.warning_amber_rounded,
              iconColor: const Color(0xFFC62828),
              backgroundColor: const Color(0xFFFFECEC),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.today_outlined,
                color: Color(0xFF00A3E0),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Bugünkü Tahsilat',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
              Text(
                _currencyFormat.format(_todayCollected),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0A2540),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 23,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hızlı İşlemler',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.person_add_alt_1,
                title: 'Yeni Müşteri',
                color: const Color(0xFF0A2540),
                onTap: _openCustomerForm,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.add_task,
                title: 'Yeni Servis',
                color: const Color(0xFF00A3E0),
                onTap: _openServiceForm,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 17,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 21,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingServices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Yaklaşan Servisler',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            if (_upcomingServices.isNotEmpty)
              Text(
                '${_upcomingServices.length} kayıt',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoading)
          const SizedBox.shrink()
        else if (_upcomingServices.isEmpty)
          _buildEmptyCard(
            icon: Icons.event_available_outlined,
            title: 'Yaklaşan servis bulunmuyor',
            subtitle: 'Önümüzdeki 30 gün içinde planlanmış servis yok.',
          )
        else
          ..._upcomingServices.map(_buildServiceCard),
      ],
    );
  }

  Widget _buildServiceCard(ServiceRecord service) {
    return FutureBuilder<Customer?>(
      future: _customerRepository.getCustomerById(service.customerId),
      builder: (context, snapshot) {
        final customerName =
            snapshot.data?.fullName ?? 'Müşteri #${service.customerId}';

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 7,
            ),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F4FC),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.build_outlined,
                color: Color(0xFF0A72B8),
              ),
            ),
            title: Text(
              customerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${service.serviceType} • '
                '${_formatServiceDate(service.nextServiceDate ?? service.serviceDate)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: Color(0xFF94A3B8),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CustomerDetailScreen(
                    customerId: service.customerId,
                  ),
                ),
              ).then((_) => _loadDashboardData());
            },
          ),
        );
      },
    );
  }

  Widget _buildRecentCustomers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Son Eklenen Müşteriler',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        if (_isLoading)
          const SizedBox.shrink()
        else if (_recentCustomers.isEmpty)
          _buildEmptyCard(
            icon: Icons.people_outline,
            title: 'Henüz müşteri bulunmuyor',
            subtitle: 'İlk müşterinizi ekleyerek başlayabilirsiniz.',
            action: _openCustomerForm,
          )
        else
          ..._recentCustomers.map(_buildCustomerCard),
      ],
    );
  }

  Widget _buildCustomerCard(Customer customer) {
    final location = [
      customer.district,
      customer.city,
    ].where((item) => item != null && item.trim().isNotEmpty).join(' / ');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 7,
        ),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFFE8F4FC),
          child: Text(
            customer.fullName.isEmpty
                ? '?'
                : customer.fullName.characters.first.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF0A72B8),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        title: Text(
          customer.fullName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            [
              customer.phone,
              if (location.isNotEmpty) location,
            ].join(' • '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Color(0xFF94A3B8),
        ),
        onTap: customer.id == null
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CustomerDetailScreen(
                      customerId: customer.id!,
                    ),
                  ),
                ).then((_) => _loadDashboardData());
              },
      ),
    );
  }

  Widget _buildEmptyCard({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? action,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 42,
            color: const Color(0xFF94A3B8),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: 15),
            OutlinedButton.icon(
              onPressed: action,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('İlk Müşteriyi Ekle'),
            ),
          ],
        ],
      ),
    );
  }
}
