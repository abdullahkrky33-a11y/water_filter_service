import 'package:flutter/material.dart';

class ServiceFormScreen extends StatelessWidget {
  const ServiceFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Servis Kaydı')),
      body: const Center(child: Text('Servis Kayıt Formu')),
    );
  }
}
