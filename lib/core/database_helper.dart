import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('su_aritma.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(
      path,
      version: 2,
      onConfigure: _onConfigure,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        first_name TEXT,
        last_name TEXT,
        full_name TEXT NOT NULL,
        phone TEXT NOT NULL,
        secondary_phone TEXT,
        address TEXT NOT NULL,
        district TEXT,
        city TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE devices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        brand TEXT NOT NULL,
        model TEXT NOT NULL,
        serial_number TEXT,
        installation_date TEXT,
        device_type TEXT,
        tank_capacity TEXT,
        pump_type TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (customer_id)
          REFERENCES customers (id)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE filters (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        replacement_period_months INTEGER NOT NULL DEFAULT 6,
        default_price REAL NOT NULL DEFAULT 0,
        description TEXT,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE device_filters (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        device_id INTEGER NOT NULL,
        filter_id INTEGER NOT NULL,
        installed_at TEXT,
        last_changed_at TEXT,
        next_change_date TEXT,
        current_price REAL NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        notes TEXT,
        FOREIGN KEY (device_id)
          REFERENCES devices (id)
          ON DELETE CASCADE,
        FOREIGN KEY (filter_id)
          REFERENCES filters (id)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE service_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        device_id INTEGER,
        service_date TEXT NOT NULL,
        next_service_date TEXT,
        service_type TEXT NOT NULL DEFAULT 'Bakım',
        description TEXT,
        total_amount REAL NOT NULL DEFAULT 0,
        payment_status TEXT NOT NULL DEFAULT 'Ödenmedi',
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (customer_id)
          REFERENCES customers (id)
          ON DELETE CASCADE,
        FOREIGN KEY (device_id)
          REFERENCES devices (id)
          ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE service_filters (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        service_id INTEGER NOT NULL,
        filter_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        unit_price REAL NOT NULL DEFAULT 0,
        total_price REAL NOT NULL DEFAULT 0,
        notes TEXT,
        FOREIGN KEY (service_id)
          REFERENCES service_records (id)
          ON DELETE CASCADE,
        FOREIGN KEY (filter_id)
          REFERENCES filters (id)
          ON DELETE RESTRICT
      )
    ''');

    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        service_id INTEGER,
        amount REAL NOT NULL,
        payment_method TEXT NOT NULL,
        payment_date TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (customer_id)
          REFERENCES customers (id)
          ON DELETE CASCADE,
        FOREIGN KEY (service_id)
          REFERENCES service_records (id)
          ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        expense_date TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await _createIndexes(db);
    await _seedDefaultFilters(db);
  }

  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE devices
        ADD COLUMN is_active INTEGER NOT NULL DEFAULT 1
      ''');

      await db.execute('''
        ALTER TABLE filters
        ADD COLUMN default_price REAL NOT NULL DEFAULT 0
      ''');

      await db.execute('''
        CREATE TABLE device_filters (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          device_id INTEGER NOT NULL,
          filter_id INTEGER NOT NULL,
          installed_at TEXT,
          last_changed_at TEXT,
          next_change_date TEXT,
          current_price REAL NOT NULL DEFAULT 0,
          is_active INTEGER NOT NULL DEFAULT 1,
          notes TEXT,
          FOREIGN KEY (device_id)
            REFERENCES devices (id)
            ON DELETE CASCADE,
          FOREIGN KEY (filter_id)
            REFERENCES filters (id)
            ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE service_filters (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          service_id INTEGER NOT NULL,
          filter_id INTEGER NOT NULL,
          quantity INTEGER NOT NULL DEFAULT 1,
          unit_price REAL NOT NULL DEFAULT 0,
          total_price REAL NOT NULL DEFAULT 0,
          notes TEXT,
          FOREIGN KEY (service_id)
            REFERENCES service_records (id)
            ON DELETE CASCADE,
          FOREIGN KEY (filter_id)
            REFERENCES filters (id)
            ON DELETE RESTRICT
        )
      ''');

      await db.execute('''
        CREATE TABLE expenses (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          category TEXT NOT NULL,
          amount REAL NOT NULL,
          expense_date TEXT NOT NULL,
          notes TEXT,
          created_at TEXT NOT NULL
        )
      ''');

      await db.execute('''
        UPDATE customers
        SET full_name = TRIM(
          COALESCE(first_name, '') || ' ' || COALESCE(last_name, '')
        )
        WHERE full_name IS NULL
           OR TRIM(full_name) = ''
      ''');

      await _createIndexes(db);
      await _seedDefaultFilters(db);
    }
  }

  Future<void> _createIndexes(Database db) async {
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_customers_phone
      ON customers(phone)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_customers_name
      ON customers(full_name)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_devices_customer
      ON devices(customer_id)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_device_filters_device
      ON device_filters(device_id)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_device_filters_next_change
      ON device_filters(next_change_date)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_service_records_customer
      ON service_records(customer_id)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_service_records_device
      ON service_records(device_id)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_service_records_date
      ON service_records(service_date)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_service_filters_service
      ON service_filters(service_id)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_payments_customer
      ON payments(customer_id)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_payments_service
      ON payments(service_id)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_payments_date
      ON payments(payment_date)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_expenses_date
      ON expenses(expense_date)
    ''');
  }

  Future<void> _seedDefaultFilters(Database db) async {
    final existing = await db.query(
      'filters',
      columns: ['id'],
      limit: 1,
    );

    if (existing.isNotEmpty) return;

    final defaultFilters = [
      {
        'name': 'Sediment Filtre',
        'type': 'PP',
        'replacement_period_months': 6,
        'default_price': 0.0,
        'description': 'Sediment ön filtre',
        'is_active': 1,
      },
      {
        'name': 'Karbon Filtre',
        'type': 'GAC',
        'replacement_period_months': 6,
        'default_price': 0.0,
        'description': 'Granül aktif karbon filtre',
        'is_active': 1,
      },
      {
        'name': 'Blok Karbon Filtre',
        'type': 'CTO',
        'replacement_period_months': 6,
        'default_price': 0.0,
        'description': 'Blok karbon filtre',
        'is_active': 1,
      },
      {
        'name': 'Membran',
        'type': 'RO',
        'replacement_period_months': 24,
        'default_price': 0.0,
        'description': 'Ters ozmoz membranı',
        'is_active': 1,
      },
      {
        'name': 'Post Karbon',
        'type': 'POST',
        'replacement_period_months': 12,
        'default_price': 0.0,
        'description': 'Son karbon filtre',
        'is_active': 1,
      },
      {
        'name': 'Mineral Filtre',
        'type': 'MINERAL',
        'replacement_period_months': 12,
        'default_price': 0.0,
        'description': 'Mineral filtre',
        'is_active': 1,
      },
    ];

    for (final filter in defaultFilters) {
      await db.insert('filters', filter);
    }
  }
}
