import 'package:flutter/material.dart';

class ServiceFormScreen extends StatefulWidget {
  const ServiceFormScreen({super.key});

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _noteController = TextEditingController();

  bool _sediment = false;
  bool _preCarbon = false;
  bool _ctoCarbon = false;
  bool _membrane = false;
  bool _t33PostCarbon = false;
  bool _mineralFilter = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Servis Kaydı', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0A2540),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Değiştirilecek / Takılacak Parçalar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    CheckboxListTile(
                      title: const Text('Sediment Filtre (5 Mikron)'),
                      value: _sediment,
                      onChanged: (val) => setState(() => _sediment = val ?? false),
                    ),
                    CheckboxListTile(
                      title: const Text('Pre-Carbon (Granül Aktif Karbon)'),
                      value: _preCarbon,
                      onChanged: (val) => setState(() => _preCarbon = val ?? false),
                    ),
                    CheckboxListTile(
                      title: const Text('CTO Blok Karbon Filtre'),
                      value: _ctoCarbon,
                      onChanged: (val) => setState(() => _ctoCarbon = val ?? false),
                    ),
                    CheckboxListTile(
                      title: const Text('Membran Filtre'),
                      value: _membrane,
                      onChanged: (val) => setState(() => _membrane = val ?? false),
                    ),
                    CheckboxListTile(
                      title: const Text('Tatlandırıcı (Post Karbon / T33)'),
                      value: _t33PostCarbon,
                      onChanged: (val) => setState(() => _t33PostCarbon = val ?? false),
                    ),
                    CheckboxListTile(
                      title: const Text('Mineral / Alkali Filtre'),
                      value: _mineralFilter,
                      onChanged: (val) => setState(() => _mineralFilter = val ?? false),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Servis Notları ve Açıklama', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Müşteri şikayeti, arıza veya ek işlemler...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A2540),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Servis kaydı başarıyla oluşturuldu!')),
                    );
                  },
                  child: const Text('SERVİSİ KAYDET', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
