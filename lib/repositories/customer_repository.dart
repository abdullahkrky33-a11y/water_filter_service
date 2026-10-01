import 'package:sqflite/sqflite.dart';
import '../core/database_helper.dart';
import '../models/customer.dart';
import '../models/device.dart';

class CustomerRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insertCustomer(Customer customer) async {
    final db = await _dbHelper.database;
    return await db.insert('customers', customer.toMap());
  }

  Future<int> insertDevice(Device device) async {
    final db = await _dbHelper.database;
    return await db.insert('devices', device.toMap());
  }

  Future<List<Customer>> getAllCustomers() async {
    final db = await _dbHelper.database;
    final maps = await db.query('customers', orderBy: 'id DESC');
    return maps.map((map) => Customer.fromMap(map)).toList();
  }

  Future<Customer?> getCustomerById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('customers', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Customer.fromMap(maps.first);
    }
    return null;
  }

  Future<Device?> getDeviceByCustomerId(int customerId) async {
    final db = await _dbHelper.database;
    final maps = await db.query('devices', where: 'customer_id = ?', whereArgs: [customerId]);
    if (maps.isNotEmpty) {
      return Device.fromMap(maps.first);
    }
    return null;
  }
}
