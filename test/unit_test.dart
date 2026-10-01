import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:su_aritma_servis/models/customer.dart';
import 'package:su_aritma_servis/models/filter.dart';
import 'package:su_aritma_servis/models/payment.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Model Serialization Tests', () {
    test('Customer model fromMap and toMap consistency', () {
      final customerMap = {
        'id': 1,
        'full_name': 'Ahmet Yılmaz',
        'phone': '05321234567',
        'address': 'Yenişehir / Mersin',
        'city': 'Mersin',
        'district': 'Yenişehir',
        'notes': 'Test notu',
        'created_at': '2026-10-01',
      };

      final customer = Customer.fromMap(customerMap);
      expect(customer.fullName, 'Ahmet Yılmaz');
      expect(customer.phone, '05321234567');

      final mapResult = customer.toMap();
      expect(mapResult['full_name'], 'Ahmet Yılmaz');
      expect(mapResult['phone'], '05321234567');
      expect(mapResult['city'], 'Mersin');
    });

    test('Filter model fromMap and toMap consistency', () {
      final filterMap = {
        'id': 101,
        'name': 'Sediment Filtre',
        'type': ' Ön Filtre',
        'replacement_period_months': 6,
        'description': '5 Mikron tortu filtresi',
        'is_active': 1,
      };

      final filter = Filter.fromMap(filterMap);
      expect(filter.name, 'Sediment Filtre');
      expect(filter.replacementPeriodMonths, 6);

      final mapResult = filter.toMap();
      expect(mapResult['replacement_period_months'], 6);
      expect(mapResult['is_active'], 1);
    });

    test('Payment model fromMap and toMap consistency', () {
      final paymentMap = {
        'id': 1,
        'customer_id': 10,
        'service_id': 5,
        'amount': 1500.00,
        'payment_method': 'Nakit',
        'payment_date': '2026-10-01',
        'notes': 'Filtre değişimi ödemesi',
        'created_at': '2026-10-01T12:00:00',
      };

      final payment = Payment.fromMap(paymentMap);
      expect(payment.amount, 1500.00);
      expect(payment.paymentMethod, 'Nakit');

      final mapResult = payment.toMap();
      expect(mapResult['amount'], 1500.00);
      expect(mapResult['customer_id'], 10);
    });
  });
}
