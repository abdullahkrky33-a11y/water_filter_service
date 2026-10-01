import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:su_aritma_servis/models/customer.dart';
import 'package:su_aritma_servis/models/device.dart';
import 'package:su_aritma_servis/models/device_filter.dart';
import 'package:su_aritma_servis/models/filter.dart';
import 'package:su_aritma_servis/models/payment.dart';
import 'package:su_aritma_servis/models/service_filter.dart';
import 'package:su_aritma_servis/models/service_record.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Model Serialization Tests', () {
    test('Customer model fromMap and toMap consistency', () {
      final customerMap = {
        'id': 1,
        'full_name': 'Ahmet Yılmaz',
        'phone': '05321234567',
        'secondary_phone': '05551234567',
        'address': 'Yenişehir / Mersin',
        'city': 'Mersin',
        'district': 'Yenişehir',
        'notes': 'Test notu',
        'created_at': '2026-10-01',
        'updated_at': '2026-10-01',
        'is_active': 1,
      };

      final customer = Customer.fromMap(customerMap);

      expect(customer.fullName, 'Ahmet Yılmaz');
      expect(customer.phone, '05321234567');
      expect(customer.secondaryPhone, '05551234567');

      final mapResult = customer.toMap();

      expect(mapResult['full_name'], 'Ahmet Yılmaz');
      expect(mapResult['phone'], '05321234567');
      expect(mapResult['secondary_phone'], '05551234567');
      expect(mapResult['city'], 'Mersin');
      expect(mapResult['is_active'], 1);
    });

    test('Device model fromMap and toMap consistency', () {
      final deviceMap = {
        'id': 10,
        'customer_id': 1,
        'brand': 'Aqua',
        'model': 'RO 500',
        'serial_number': 'SN123456',
        'installation_date': '2026-01-15',
        'device_type': 'Ters Ozmoz',
        'tank_capacity': '8 L',
        'pump_type': 'Pompalı',
        'created_at': '2026-01-15',
        'updated_at': '2026-10-01',
        'is_active': 1,
      };

      final device = Device.fromMap(deviceMap);

      expect(device.id, 10);
      expect(device.customerId, 1);
      expect(device.brand, 'Aqua');
      expect(device.model, 'RO 500');
      expect(device.brandModel, 'Aqua RO 500');
      expect(device.serialNumber, 'SN123456');
      expect(device.deviceType, 'Ters Ozmoz');
      expect(device.tankCapacity, '8 L');
      expect(device.pumpType, 'Pompalı');

      final mapResult = device.toMap();

      expect(mapResult['customer_id'], 1);
      expect(mapResult['brand'], 'Aqua');
      expect(mapResult['model'], 'RO 500');
      expect(mapResult['serial_number'], 'SN123456');
      expect(mapResult['is_active'], 1);
    });

    test('Filter model fromMap and toMap consistency', () {
      final filterMap = {
        'id': 101,
        'name': 'Sediment Filtre',
        'type': 'PP',
        'replacement_period_months': 6,
        'default_price': 250.0,
        'description': '5 Mikron tortu filtresi',
        'is_active': 1,
      };

      final filter = Filter.fromMap(filterMap);

      expect(filter.name, 'Sediment Filtre');
      expect(filter.type, 'PP');
      expect(filter.replacementPeriodMonths, 6);
      expect(filter.defaultPrice, 250.0);

      final mapResult = filter.toMap();

      expect(mapResult['replacement_period_months'], 6);
      expect(mapResult['default_price'], 250.0);
      expect(mapResult['is_active'], 1);
    });

    test('DeviceFilter model fromMap and toMap consistency', () {
      final deviceFilterMap = {
        'id': 201,
        'device_id': 10,
        'filter_id': 101,
        'installed_at': '2026-04-01',
        'last_changed_at': '2026-04-01',
        'next_change_date': '2026-10-01',
        'current_price': 250.0,
        'is_active': 1,
        'notes': 'Standart sediment filtre',
      };

      final deviceFilter = DeviceFilter.fromMap(deviceFilterMap);

      expect(deviceFilter.id, 201);
      expect(deviceFilter.deviceId, 10);
      expect(deviceFilter.filterId, 101);
      expect(deviceFilter.currentPrice, 250.0);
      expect(deviceFilter.isActive, true);
      expect(deviceFilter.nextChangeDate, '2026-10-01');

      final mapResult = deviceFilter.toMap();

      expect(mapResult['device_id'], 10);
      expect(mapResult['filter_id'], 101);
      expect(mapResult['current_price'], 250.0);
      expect(mapResult['is_active'], 1);
    });

    test('ServiceRecord model fromMap and toMap consistency', () {
      final serviceMap = {
        'id': 301,
        'customer_id': 1,
        'device_id': 10,
        'service_date': '2026-10-01',
        'next_service_date': '2027-04-01',
        'service_type': 'Filtre Değişimi',
        'description': '4 filtre değiştirildi',
        'total_amount': 1750.0,
        'payment_status': 'Ödendi',
        'notes': 'Müşteri memnun',
        'created_at': '2026-10-01T12:00:00',
      };

      final service = ServiceRecord.fromMap(serviceMap);

      expect(service.id, 301);
      expect(service.customerId, 1);
      expect(service.deviceId, 10);
      expect(service.serviceDate, '2026-10-01');
      expect(service.nextServiceDate, '2027-04-01');
      expect(service.serviceType, 'Filtre Değişimi');
      expect(service.totalAmount, 1750.0);
      expect(service.paymentStatus, 'Ödendi');

      final mapResult = service.toMap();

      expect(mapResult['customer_id'], 1);
      expect(mapResult['device_id'], 10);
      expect(mapResult['service_date'], '2026-10-01');
      expect(mapResult['next_service_date'], '2027-04-01');
      expect(mapResult['total_amount'], 1750.0);
      expect(mapResult['payment_status'], 'Ödendi');
    });

    test('ServiceFilter calculates total price correctly', () {
      final serviceFilter = ServiceFilter(
        serviceId: 301,
        filterId: 101,
        quantity: 2,
        unitPrice: 250.0,
      );

      final mapResult = serviceFilter.toMap();

      expect(mapResult['service_id'], 301);
      expect(mapResult['filter_id'], 101);
      expect(mapResult['quantity'], 2);
      expect(mapResult['unit_price'], 250.0);
      expect(mapResult['total_price'], 500.0);
    });

    test('ServiceFilter fromMap and toMap consistency', () {
      final serviceFilterMap = {
        'id': 401,
        'service_id': 301,
        'filter_id': 101,
        'quantity': 2,
        'unit_price': 250.0,
        'total_price': 500.0,
        'notes': '2 adet değiştirildi',
      };

      final serviceFilter = ServiceFilter.fromMap(serviceFilterMap);

      expect(serviceFilter.id, 401);
      expect(serviceFilter.serviceId, 301);
      expect(serviceFilter.filterId, 101);
      expect(serviceFilter.quantity, 2);
      expect(serviceFilter.unitPrice, 250.0);
      expect(serviceFilter.totalPrice, 500.0);

      final mapResult = serviceFilter.toMap();

      expect(mapResult['service_id'], 301);
      expect(mapResult['filter_id'], 101);
      expect(mapResult['quantity'], 2);
      expect(mapResult['total_price'], 500.0);
    });

    test('Payment model fromMap and toMap consistency', () {
      final paymentMap = {
        'id': 501,
        'customer_id': 10,
        'service_id': 301,
        'amount': 1500.00,
        'payment_method': 'Nakit',
        'payment_date': '2026-10-01',
        'notes': 'Filtre değişimi ödemesi',
        'created_at': '2026-10-01T12:00:00',
      };

      final payment = Payment.fromMap(paymentMap);

      expect(payment.amount, 1500.00);
      expect(payment.paymentMethod, 'Nakit');
      expect(payment.serviceId, 301);

      final mapResult = payment.toMap();

      expect(mapResult['amount'], 1500.00);
      expect(mapResult['customer_id'], 10);
      expect(mapResult['service_id'], 301);
    });
  });
}
