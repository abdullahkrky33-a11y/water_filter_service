import '../database/database_helper.dart';
import '../models/customer.dart';

class CustomerRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insertCustomer(Customer customer) async {
    final db = await _dbHelper.database;
    return await db.insert('customers', customer.toMap());
  }

  Future<List<Customer>> getAllCustomers() async {
    final db = await _dbHelper.database;
    final result = await db.query('customers', where: 'is_active = 1', orderBy: 'first_name ASC');
    return result.map((json) => Customer.fromMap(json)).toList();
  }

  Future<Customer?> getCustomerById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Customer.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Customer>> searchCustomers(String query) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'customers',
      where: '(first_name LIKE ? OR last_name LIKE ? OR phone LIKE ? OR address LIKE ?) AND is_active = 1',
      whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%'],
    );
    return result.map((json) => Customer.fromMap(json)).toList();
  }

  Future<int> updateCustomer(Customer customer) async {
    final db = await _dbHelper.database;
    return await db.update(
      'customers',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> deleteCustomer(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'customers',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
