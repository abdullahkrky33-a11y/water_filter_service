import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../core/constants/app_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Customers Table
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        phone TEXT NOT NULL,
        secondary_phone TEXT,
        address TEXT NOT NULL,
        district TEXT NOT NULL,
        city TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // 2. Devices Table
    await db.execute('''
      CREATE TABLE devices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        brand TEXT NOT NULL,
        model TEXT NOT NULL,
        serial_number TEXT,
        installation_date TEXT NOT NULL,
        device_type TEXT NOT NULL,
        tank_capacity TEXT,
        pump_type TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE
      )
    ''');

    // 3. Filters Table
    await db.execute('''
      CREATE TABLE filters (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        replacement_period_months INTEGER NOT NULL,
        description TEXT,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // 4. Service Records Table
    await db.execute('''
      CREATE TABLE service_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        device_id INTEGER NOT NULL,
        service_date TEXT NOT NULL,
        service_type TEXT NOT NULL,
        description TEXT,
        total_amount REAL NOT NULL,
        payment_status TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE,
        FOREIGN KEY (device_id) REFERENCES devices (id) ON DELETE CASCADE
      )
    ''');

    // 5. Payments Table
    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        service_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        payment_method TEXT NOT NULL,
        payment_date TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE,
        FOREIGN KEY (service_id) REFERENCES service_records (id) ON DELETE CASCADE
      )
    ''');

    // Varsayılan Filtre Türlerini Ekleme
    await db.rawInsert('''
      INSERT INTO filters (name, type, replacement_period_months, description)
      VALUES 
        ('Sediment Filtre (5 Mikron)', 'Ön Filtre', 6, 'Kaba pislik ve tortuları tutar'),
        ('Granül Aktif Karbon (GAC)', 'Ön Filtre', 6, 'Klor ve organik maddeleri temizler'),
        ('Blok Karbon (CTO)', 'Ön Filtre', 6, 'Klor kokusunu ve kalan partikülleri süzer'),
        ('Membran Filtre (75 GPD)', 'Ana Filtre', 24, 'Ağır metalleri ve bakterileri ayırır'),
        ('Post Karbon (Tatlandırıcı)', 'Son Filtre', 12, 'Suyun tadını düzenler'),
        ('Mineral / Alkalin Filtre', 'Ekstra Filtre', 12, 'Suya faydalı mineraller kazandırır')
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
