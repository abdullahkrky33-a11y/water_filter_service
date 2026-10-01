import 'package:flutter/material.dart';

import '../../models/customer.dart';
import '../../repositories/customer_repository.dart';
import '../../services/phone_service.dart';
import '../customer/customer_detail_screen.dart';
import '../customer/customer_form_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final CustomerRepository _repository = CustomerRepository();
  final TextEditingController _searchController = TextEditingController();

  List<Customer> _customers = [];
  bool _isLoading = true;
  bool _showInactive = false;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final customers = await _repository.getAllCustomers();

      if (!mounted) return;

      setState(() {
        _customers = customers;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage('Müşteriler yüklenirken bir hata oluştu.');
    }
  }

  List<Customer> get _filteredCustomers {
    final query = _searchController.text.trim().toLowerCase();

    var result = _customers.where((customer) {
      if (!_showInactive && !customer.isActive) {
        return false;
      }

      return true;
    }).toList();

    if (query.isEmpty) {
      return result;
    }

    result = result.where((customer) {
      final name = customer.fullName.toLowerCase();
      final phone = customer.phone.toLowerCase();
      final secondaryPhone =
          customer.secondaryPhone?.toLowerCase() ?? '';
      final address = customer.address.toLowerCase();
      final district = customer.district?.toLowerCase() ?? '';
      final city = customer.city?.toLowerCase() ?? '';

      return name.contains(query) ||
          phone.contains(query) ||
          secondaryPhone.contains(query) ||
          address.contains(query) ||
          district.contains(query) ||
          city.contains(query);
    }).toList();

    return result;
  }

  Future<void> _openNewCustomer() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CustomerFormScreen(),
      ),
    );

    if (result == true) {
      await _loadCustomers();
    }
  }

  Future<void> _openCustomer(Customer customer) async {
    if (customer.id == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerDetailScreen(
          customerId: customer.id!,
        ),
      ),
    );

    await _loadCustomers();
  }

  Future<void> _editCustomer(Customer customer) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerFormScreen(
          customer: customer,
        ),
      ),
    );

    if (result == true) {
      await _loadCustomers();
    }
  }

  Future<void> _toggleCustomerStatus(Customer customer) async {
    if (customer.id == null) return;

    final newStatus = !customer.isActive;

    try {
      await _repository.updateCustomer(
        customer.copyWith(
          isActive: newStatus,
          updatedAt: DateTime.now().toIso8601String(),
        ),
      );

      await _loadCustomers();

      if (!mounted) return;

      _showMessage(
        newStatus
            ? 'Müşteri tekrar aktif edildi.'
            : 'Müşteri pasifleştirildi.',
      );
    } catch (_) {
      if (!mounted) return;

      _showMessage('Müşteri durumu güncellenemedi.');
    }
  }

  Future<void> _confirmStatusChange(Customer customer) async {
    final action =
        customer.isActive ? 'pasifleştirmek' : 'aktif etmek';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            customer.isActive
                ? 'Müşteriyi Pasifleştir'
                : 'Müşteriyi Aktif Et',
          ),
          content: Text(
            '${customer.fullName} müşterisini $action istediğinize emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Onayla'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _toggleCustomerStatus(customer);
    }
  }

  void _showCustomerActions(Customer customer) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Müşteri Detayı'),
                  onTap: () {
                    Navigator.pop(context);
                    _openCustomer(customer);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Müşteriyi Düzenle'),
                  onTap: () {
                    Navigator.pop(context);
                    _editCustomer(customer);
                  },
                ),
                ListTile(
                  leading: Icon(
                    customer.isActive
                        ? Icons.person_off_outlined
                        : Icons.person_outline,
                  ),
                  title: Text(
                    customer.isActive
                        ? 'Müşteriyi Pasifleştir'
                        : 'Müşteriyi Aktif Et',
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmStatusChange(customer);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  String _locationText(Customer customer) {
    final parts = <String>[];

    if (customer.district?.trim().isNotEmpty == true) {
      parts.add(customer.district!.trim());
    }

    if (customer.city?.trim().isNotEmpty == true) {
      parts.add(customer.city!.trim());
    }

    return parts.isEmpty ? 'Adres bilgisi yok' : parts.join(' / ');
  }

  @override
  Widget build(BuildContext context) {
    final customers = _filteredCustomers;
    final activeCount =
        _customers.where((customer) => customer.isActive).length;
    final inactiveCount =
        _customers.where((customer) => !customer.isActive).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Müşteriler',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Yenile',
            onPressed: _loadCustomers,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewCustomer,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Yeni Müşteri'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadCustomers,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _buildSummaryCard(
                  activeCount,
                  inactiveCount,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText:
                        'İsim, telefon veya adres ara...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                                icon: const Icon(Icons.clear),
                              )
                            : null,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Row(
                  children: [
                    FilterChip(
                      selected: !_showInactive,
                      label: const Text('Aktif müşteriler'),
                      avatar: const Icon(
                        Icons.check_circle_outline,
                        size: 18,
                      ),
                      onSelected: (_) {
                        setState(() {
                          _showInactive = false;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      selected: _showInactive,
                      label: const Text('Pasifler dahil'),
                      avatar: const Icon(
                        Icons.people_outline,
                        size: 18,
                      ),
                      onSelected: (_) {
                        setState(() {
                          _showInactive = true;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (customers.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  4,
                  16,
                  100,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final customer = customers[index];

                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: 10),
                        child: _buildCustomerCard(customer),
                      );
                    },
                    childCount: customers.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    int activeCount,
    int inactiveCount,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF00A3E0).withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.people_outline,
                color: Color(0xFF00A3E0),
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Müşteri Portföyü',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$activeCount aktif müşteri'
                    '${inactiveCount > 0 ? ' • $inactiveCount pasif' : ''}',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${_customers.length}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0A2540),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(Customer customer) {
    final initials = customer.fullName.trim().isEmpty
        ? '?'
        : customer.fullName.trim().substring(0, 1).toUpperCase();

    return Card(
      child: InkWell(
        onTap: () => _openCustomer(customer),
        onLongPress: () => _showCustomerActions(customer),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: customer.isActive
                    ? const Color(0xFF00A3E0).withOpacity(0.12)
                    : const Color(0xFF94A3B8).withOpacity(0.15),
                foregroundColor: customer.isActive
                    ? const Color(0xFF0085B8)
                    : const Color(0xFF64748B),
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            customer.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (!customer.isActive)
                          const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Chip(
                              label: Text('Pasif'),
                              visualDensity:
                                  VisualDensity.compact,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    _smallInfoRow(
                      Icons.phone_outlined,
                      customer.phone,
                    ),
                    const SizedBox(height: 4),
                    _smallInfoRow(
                      Icons.location_on_outlined,
                      _locationText(customer),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                tooltip: 'Müşteri işlemleri',
                onSelected: (value) {
                  if (value == 'detail') {
                    _openCustomer(customer);
                  } else if (value == 'edit') {
                    _editCustomer(customer);
                  } else if (value == 'status') {
                    _confirmStatusChange(customer);
                  } else if (value == 'call') {
                    PhoneService.makePhoneCall(
                      customer.phone,
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'detail',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.person_outline),
                      title: Text('Detay'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Düzenle'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'call',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.phone_outlined),
                      title: Text('Ara'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'status',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        customer.isActive
                            ? Icons.person_off_outlined
                            : Icons.person_outline,
                      ),
                      title: Text(
                        customer.isActive
                            ? 'Pasifleştir'
                            : 'Aktif Et',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _smallInfoRow(
    IconData icon,
    String text,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFF64748B),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final hasSearch =
        _searchController.text.trim().isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasSearch
                  ? Icons.search_off
                  : Icons.people_outline,
              size: 64,
              color: const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 16),
            Text(
              hasSearch
                  ? 'Aramanızla eşleşen müşteri bulunamadı.'
                  : _showInactive
                      ? 'Henüz müşteri bulunmuyor.'
                      : 'Henüz aktif müşteri bulunmuyor.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            if (!hasSearch)
              const Text(
                'İlk müşterinizi ekleyerek servis kayıtlarını '
                'tutmaya başlayabilirsiniz.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
            if (!hasSearch) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _openNewCustomer,
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Yeni Müşteri Ekle'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
