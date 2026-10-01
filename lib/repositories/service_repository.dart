import '../database/database_helper.dart';
import '../models/service_record.dart';

class ServiceRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insertService(ServiceRecord service) async {
    final db = await _dbHelper.database;
    return await db.insert('service_records', service.toMap());
  }

  Future<List<ServiceRecord>> getServicesByCustomerId(int customerId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'service_records',
      where: 'customer_id = ?',
      whereArgs: [customerId],
      orderBy: 'service_date DESC',
    );
    return result.map((json) => ServiceRecord.fromMap(json)).toList();
  }

  Future<List<ServiceRecord>> getAllServices() async {
    final db = await _dbHelper.database;
    final result = await db.query('service_records', orderBy: 'service_date DESC');
    return result.map((json) => ServiceRecord.fromMap(json)).toList();
  }

  Future<int> updateServiceStatus(int serviceId, String status) async {
    final db = await _dbHelper.database;
    return await db.update(
      'service_records',
      {'payment_status': status},
      where: 'id = ?',
      whereArgs: [serviceId],
    );
  }
}
