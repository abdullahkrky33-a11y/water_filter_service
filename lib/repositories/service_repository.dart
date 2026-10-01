import '../core/database_helper.dart';
import '../models/payment.dart';
import '../models/service_record.dart';

class ServiceRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insertServiceRecord(ServiceRecord record) async {
    final db = await _dbHelper.database;

    return db.insert(
      'service_records',
      record.toMap(includeId: false),
    );
  }

  Future<int> updateServiceRecord(ServiceRecord record) async {
    if (record.id == null) {
      throw ArgumentError(
        'Güncellenecek servis kaydının ID bilgisi olmalıdır.',
      );
    }

    final db = await _dbHelper.database;

    return db.update(
      'service_records',
      record.toMap(includeId: false),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> deleteServiceRecord(int serviceId) async {
    final db = await _dbHelper.database;

    return db.delete(
      'service_records',
      where: 'id = ?',
      whereArgs: [serviceId],
    );
  }

  Future<ServiceRecord?> getServiceRecordById(int serviceId) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'service_records',
      where: 'id = ?',
      whereArgs: [serviceId],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return ServiceRecord.fromMap(maps.first);
  }

  Future<List<ServiceRecord>> getAllServiceRecords() async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'service_records',
      orderBy: 'service_date DESC, id DESC',
    );

    return maps.map(ServiceRecord.fromMap).toList();
  }

  Future<List<ServiceRecord>> getServicesByCustomerId(
    int customerId,
  ) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'service_records',
      where: 'customer_id = ?',
      whereArgs: [customerId],
      orderBy: 'service_date DESC, id DESC',
    );

    return maps.map(ServiceRecord.fromMap).toList();
  }

  Future<List<ServiceRecord>> getServicesByDeviceId(
    int deviceId,
  ) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'service_records',
      where: 'device_id = ?',
      whereArgs: [deviceId],
      orderBy: 'service_date DESC, id DESC',
    );

    return maps.map(ServiceRecord.fromMap).toList();
  }

  Future<List<ServiceRecord>> getUpcomingServices({
    int daysAhead = 30,
  }) async {
    if (daysAhead < 0) {
      throw ArgumentError('daysAhead negatif olamaz.');
    }

    final db = await _dbHelper.database;

    final now = DateTime.now();
    final today = _dateOnly(now);
    final endDate = _dateOnly(
      now.add(Duration(days: daysAhead)),
    );

    final maps = await db.query(
      'service_records',
      where: '''
        next_service_date IS NOT NULL
        AND next_service_date >= ?
        AND next_service_date <= ?
      ''',
      whereArgs: [today, endDate],
      orderBy: 'next_service_date ASC, id ASC',
    );

    return maps.map(ServiceRecord.fromMap).toList();
  }

  Future<List<ServiceRecord>> getOverdueServices() async {
    final db = await _dbHelper.database;

    final today = _dateOnly(DateTime.now());

    final maps = await db.query(
      'service_records',
      where: '''
        next_service_date IS NOT NULL
        AND next_service_date < ?
      ''',
      whereArgs: [today],
      orderBy: 'next_service_date ASC, id ASC',
    );

    return maps.map(ServiceRecord.fromMap).toList();
  }

  Future<int> insertPayment(Payment payment) async {
    final db = await _dbHelper.database;

    return db.insert(
      'payments',
      payment.toMap(includeId: false),
    );
  }

  Future<int> updatePayment(Payment payment) async {
    if (payment.id == null) {
      throw ArgumentError(
        'Güncellenecek ödeme kaydının ID bilgisi olmalıdır.',
      );
    }

    final db = await _dbHelper.database;

    return db.update(
      'payments',
      payment.toMap(includeId: false),
      where: 'id = ?',
      whereArgs: [payment.id],
    );
  }

  Future<int> deletePayment(int paymentId) async {
    final db = await _dbHelper.database;

    return db.delete(
      'payments',
      where: 'id = ?',
      whereArgs: [paymentId],
    );
  }

  Future<List<Payment>> getAllPayments() async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'payments',
      orderBy: 'payment_date DESC, id DESC',
    );

    return maps.map(Payment.fromMap).toList();
  }

  Future<List<Payment>> getPaymentsByCustomerId(
    int customerId,
  ) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'payments',
      where: 'customer_id = ?',
      whereArgs: [customerId],
      orderBy: 'payment_date DESC, id DESC',
    );

    return maps.map(Payment.fromMap).toList();
  }

  Future<List<Payment>> getPaymentsByServiceId(
    int serviceId,
  ) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'payments',
      where: 'service_id = ?',
      whereArgs: [serviceId],
      orderBy: 'payment_date DESC, id DESC',
    );

    return maps.map(Payment.fromMap).toList();
  }

  Future<double> getTotalPayments() async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) AS total FROM payments',
    );

    final value = result.first['total'];

    if (value is num) {
      return value.toDouble();
    }

    return 0;
  }

  Future<double> getCustomerTotalPayments(int customerId) async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(amount), 0) AS total
      FROM payments
      WHERE customer_id = ?
      ''',
      [customerId],
    );

    final value = result.first['total'];

    if (value is num) {
      return value.toDouble();
    }

    return 0;
  }

  String _dateOnly(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}
