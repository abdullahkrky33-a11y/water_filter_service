import '../core/database_helper.dart';
import '../models/device_filter.dart';
import '../models/filter.dart';
import '../models/service_filter.dart';

class FilterRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insertFilter(Filter filter) async {
    final db = await _dbHelper.database;

    return db.insert(
      'filters',
      filter.toMap(includeId: false),
    );
  }

  Future<int> updateFilter(Filter filter) async {
    if (filter.id == null) {
      throw ArgumentError(
        'Güncellenecek filtrenin ID bilgisi olmalıdır.',
      );
    }

    final db = await _dbHelper.database;

    return db.update(
      'filters',
      filter.toMap(includeId: false),
      where: 'id = ?',
      whereArgs: [filter.id],
    );
  }

  Future<int> deleteFilter(int filterId) async {
    final db = await _dbHelper.database;

    return db.update(
      'filters',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [filterId],
    );
  }

  Future<Filter?> getFilterById(int filterId) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'filters',
      where: 'id = ?',
      whereArgs: [filterId],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Filter.fromMap(maps.first);
  }

  Future<List<Filter>> getAllFilters({
    bool activeOnly = true,
  }) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'filters',
      where: activeOnly ? 'is_active = ?' : null,
      whereArgs: activeOnly ? [1] : null,
      orderBy: 'name COLLATE NOCASE ASC',
    );

    return maps.map(Filter.fromMap).toList();
  }

  Future<int> insertDeviceFilter(DeviceFilter deviceFilter) async {
    final db = await _dbHelper.database;

    return db.insert(
      'device_filters',
      deviceFilter.toMap(includeId: false),
    );
  }

  Future<int> updateDeviceFilter(DeviceFilter deviceFilter) async {
    if (deviceFilter.id == null) {
      throw ArgumentError(
        'Güncellenecek cihaz filtresinin ID bilgisi olmalıdır.',
      );
    }

    final db = await _dbHelper.database;

    return db.update(
      'device_filters',
      deviceFilter.toMap(includeId: false),
      where: 'id = ?',
      whereArgs: [deviceFilter.id],
    );
  }

  Future<int> deactivateDeviceFilter(int deviceFilterId) async {
    final db = await _dbHelper.database;

    return db.update(
      'device_filters',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [deviceFilterId],
    );
  }

  Future<List<DeviceFilter>> getDeviceFilters(
    int deviceId, {
    bool activeOnly = true,
  }) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'device_filters',
      where: activeOnly
          ? 'device_id = ? AND is_active = ?'
          : 'device_id = ?',
      whereArgs: activeOnly ? [deviceId, 1] : [deviceId],
      orderBy: 'id ASC',
    );

    return maps.map(DeviceFilter.fromMap).toList();
  }

  Future<DeviceFilter?> getDeviceFilterById(
    int deviceFilterId,
  ) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'device_filters',
      where: 'id = ?',
      whereArgs: [deviceFilterId],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return DeviceFilter.fromMap(maps.first);
  }

  Future<List<DeviceFilter>> getDueDeviceFilters({
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
      'device_filters',
      where: '''
        is_active = ?
        AND next_change_date IS NOT NULL
        AND next_change_date >= ?
        AND next_change_date <= ?
      ''',
      whereArgs: [1, today, endDate],
      orderBy: 'next_change_date ASC, id ASC',
    );

    return maps.map(DeviceFilter.fromMap).toList();
  }

  Future<List<DeviceFilter>> getOverdueDeviceFilters() async {
    final db = await _dbHelper.database;

    final today = _dateOnly(DateTime.now());

    final maps = await db.query(
      'device_filters',
      where: '''
        is_active = ?
        AND next_change_date IS NOT NULL
        AND next_change_date < ?
      ''',
      whereArgs: [1, today],
      orderBy: 'next_change_date ASC, id ASC',
    );

    return maps.map(DeviceFilter.fromMap).toList();
  }

  Future<int> insertServiceFilter(ServiceFilter serviceFilter) async {
    final db = await _dbHelper.database;

    return db.insert(
      'service_filters',
      serviceFilter.toMap(includeId: false),
    );
  }

  Future<int> updateServiceFilter(ServiceFilter serviceFilter) async {
    if (serviceFilter.id == null) {
      throw ArgumentError(
        'Güncellenecek servis filtresinin ID bilgisi olmalıdır.',
      );
    }

    final db = await _dbHelper.database;

    return db.update(
      'service_filters',
      serviceFilter.toMap(includeId: false),
      where: 'id = ?',
      whereArgs: [serviceFilter.id],
    );
  }

  Future<int> deleteServiceFilter(int serviceFilterId) async {
    final db = await _dbHelper.database;

    return db.delete(
      'service_filters',
      where: 'id = ?',
      whereArgs: [serviceFilterId],
    );
  }

  Future<List<ServiceFilter>> getServiceFilters(
    int serviceId,
  ) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'service_filters',
      where: 'service_id = ?',
      whereArgs: [serviceId],
      orderBy: 'id ASC',
    );

    return maps.map(ServiceFilter.fromMap).toList();
  }

  Future<double> getServiceFilterTotal(int serviceId) async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(total_price), 0) AS total
      FROM service_filters
      WHERE service_id = ?
      ''',
      [serviceId],
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
