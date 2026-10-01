import '../core/database_helper.dart';
import '../models/customer.dart';
import '../models/device.dart';

class CustomerRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insertCustomer(Customer customer) async {
    final db = await _dbHelper.database;

    return db.insert(
      'customers',
      customer.toMap(includeId: false),
    );
  }

  Future<int> updateCustomer(Customer customer) async {
    if (customer.id == null) {
      throw ArgumentError('Güncellenecek müşterinin ID bilgisi olmalıdır.');
    }

    final db = await _dbHelper.database;

    return db.update(
      'customers',
      customer.toMap(includeId: false),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> deleteCustomer(int customerId) async {
    final db = await _dbHelper.database;

    return db.delete(
      'customers',
      where: 'id = ?',
      whereArgs: [customerId],
    );
  }

  Future<Customer?> getCustomerById(int id) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Customer.fromMap(maps.first);
  }

  Future<List<Customer>> getAllCustomers() async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'customers',
      orderBy: 'id DESC',
    );

    return maps.map(Customer.fromMap).toList();
  }

  Future<List<Customer>> getActiveCustomers() async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'customers',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'full_name COLLATE NOCASE ASC',
    );

    return maps.map(Customer.fromMap).toList();
  }

  Future<List<Customer>> searchCustomers(String query) async {
    final db = await _dbHelper.database;

    final normalizedQuery = query.trim();

    if (normalizedQuery.isEmpty) {
      return getAllCustomers();
    }

    final pattern = '%$normalizedQuery%';

    final maps = await db.query(
      'customers',
      where: '''
        full_name LIKE ?
        OR phone LIKE ?
        OR secondary_phone LIKE ?
        OR address LIKE ?
        OR district LIKE ?
        OR city LIKE ?
      ''',
      whereArgs: [
        pattern,
        pattern,
        pattern,
        pattern,
        pattern,
        pattern,
      ],
      orderBy: 'full_name COLLATE NOCASE ASC',
    );

    return maps.map(Customer.fromMap).toList();
  }

  Future<int> insertDevice(Device device) async {
    final db = await _dbHelper.database;

    return db.insert(
      'devices',
      device.toMap(includeId: false),
    );
  }

  Future<int> updateDevice(Device device) async {
    if (device.id == null) {
      throw ArgumentError('Güncellenecek cihazın ID bilgisi olmalıdır.');
    }

    final db = await _dbHelper.database;

    return db.update(
      'devices',
      device.toMap(includeId: false),
      where: 'id = ?',
      whereArgs: [device.id],
    );
  }

  Future<int> deleteDevice(int deviceId) async {
    final db = await _dbHelper.database;

    return db.delete(
      'devices',
      where: 'id = ?',
      whereArgs: [deviceId],
    );
  }

  Future<Device?> getDeviceById(int deviceId) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'devices',
      where: 'id = ?',
      whereArgs: [deviceId],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Device.fromMap(maps.first);
  }

  Future<List<Device>> getDevicesByCustomerId(int customerId) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'devices',
      where: 'customer_id = ?',
      whereArgs: [customerId],
      orderBy: 'id DESC',
    );

    return maps.map(Device.fromMap).toList();
  }

  Future<List<Device>> getActiveDevicesByCustomerId(int customerId) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'devices',
      where: 'customer_id = ? AND is_active = ?',
      whereArgs: [customerId, 1],
      orderBy: 'id DESC',
    );

    return maps.map(Device.fromMap).toList();
  }

  Future<Device?> getDeviceByCustomerId(int customerId) async {
    final devices = await getActiveDevicesByCustomerId(customerId);

    if (devices.isEmpty) {
      return null;
    }

    return devices.first;
  }
}
