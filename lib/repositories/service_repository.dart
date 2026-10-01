import '../core/database_helper.dart';
import '../models/service_record.dart';
import '../models/payment.dart';

class ServiceRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<ServiceRecord>> getUpcomingServices({int? daysAhead}) async {
    final db = await _dbHelper.database;
    final maps = await db.query('service_records', orderBy: 'next_service_date ASC');
    return maps.map((map) => ServiceRecord.fromMap(map)).toList();
  }

  Future<int> insertServiceRecord(ServiceRecord record) async {
    final db = await _dbHelper.database;
    return await db.insert('service_records', record.toMap());
  }

  Future<int> insertPayment(Payment payment) async {
    final db = await _dbHelper.database;
    return await db.insert('payments', payment.toMap());
  }
}
