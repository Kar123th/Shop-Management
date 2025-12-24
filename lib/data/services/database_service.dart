import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shop_management_app/data/models/product_model.dart';
import 'package:shop_management_app/data/models/sale_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'shop_management.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE sales(
          id TEXT PRIMARY KEY,
          user_id TEXT,
          customer_id TEXT,
          customer_name TEXT,
          customer_phone TEXT,
          sub_total REAL,
          discount REAL,
          tax_amount REAL,
          total_amount REAL,
          payment_method TEXT,
          created_at TEXT,
          is_synced INTEGER DEFAULT 0
        )
      ''');

      await db.execute('''
        CREATE TABLE sale_items(
          id TEXT PRIMARY KEY,
          sale_id TEXT,
          product_id TEXT,
          product_name TEXT,
          quantity REAL,
          unit_price REAL,
          gst_rate REAL,
          total REAL,
          FOREIGN KEY (sale_id) REFERENCES sales (id) ON DELETE CASCADE
        )
      ''');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products(
        id TEXT PRIMARY KEY,
        user_id TEXT,
        category_id TEXT,
        name TEXT NOT NULL,
        description TEXT,
        barcode TEXT,
        sku TEXT,
        hsn_code TEXT,
        unit TEXT,
        sale_price REAL,
        purchase_price REAL,
        gst_rate REAL,
        stock_quantity REAL,
        low_stock_alert REAL,
        image_url TEXT,
        is_active INTEGER,
        created_at TEXT,
        updated_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE sales(
        id TEXT PRIMARY KEY,
        user_id TEXT,
        customer_id TEXT,
        customer_name TEXT,
        customer_phone TEXT,
        sub_total REAL,
        discount REAL,
        tax_amount REAL,
        total_amount REAL,
        payment_method TEXT,
        created_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE sale_items(
        id TEXT PRIMARY KEY,
        sale_id TEXT,
        product_id TEXT,
        product_name TEXT,
        quantity REAL,
        unit_price REAL,
        gst_rate REAL,
        total REAL,
        FOREIGN KEY (sale_id) REFERENCES sales (id) ON DELETE CASCADE
      )
    ''');
  }

  // --- Product Methods ---
  
  Future<void> reduceProductStock(String productId, double quantity) async {
    final db = await database;
    await db.execute(
      'UPDATE products SET stock_quantity = stock_quantity - ? WHERE id = ?',
      [quantity, productId],
    );
  }

  // --- Sale Methods ---

  Future<void> insertSale(Sale sale) async {
    final db = await database;
    await db.transaction((txn) async {
      // 1. Insert Sale
      final saleMap = sale.toMap();
      saleMap['is_synced'] = 0;
      await txn.insert('sales', saleMap);

      // 2. Insert Sale Items and Reduce Stock
      for (var item in sale.items) {
        await txn.insert('sale_items', item.toMap());
        
        // Reduce stock in the same transaction
        await txn.execute(
          'UPDATE products SET stock_quantity = stock_quantity - ? WHERE id = ?',
          [item.quantity, item.productId],
        );
      }
    });
  }

  Future<List<Sale>> getSales() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('sales', orderBy: 'created_at DESC');

    List<Sale> sales = [];
    for (var map in maps) {
      final itemMaps = await db.query('sale_items', where: 'sale_id = ?', whereArgs: [map['id']]);
      final items = itemMaps.map((m) => SaleItem.fromMap(m)).toList();
      sales.add(Sale.fromMap(map, items));
    }
    return sales;
  }

  // Generic Insert
  Future<void> insertProduct(Product product) async {
    final db = await database;
    final map = product.toMap();
    // Convert boolean to integer for SQL
    map['is_active'] = product.isActive ? 1 : 0;
    map['is_synced'] = 0; // Local insert starts as unsynced
    
    await db.insert(
      'products',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products', orderBy: 'updated_at DESC');

    return List.generate(maps.length, (i) {
      final map = Map<String, dynamic>.from(maps[i]);
      map['is_active'] = map['is_active'] == 1;
      return Product.fromMap(map);
    });
  }

  Future<void> updateSyncStatus(String id, bool synced) async {
    final db = await database;
    await db.update(
      'products',
      {'is_synced': synced ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateSaleSyncStatus(String id, bool synced) async {
    final db = await database;
    await db.update(
      'sales',
      {'is_synced': synced ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Product>> getUnsyncedProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products', where: 'is_synced = ?', whereArgs: [0]);

    return List.generate(maps.length, (i) {
      final map = Map<String, dynamic>.from(maps[i]);
      map['is_active'] = map['is_active'] == 1;
      return Product.fromMap(map);
    });
  }

  Future<List<Sale>> getUnsyncedSales() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('sales', where: 'is_synced = ?', whereArgs: [0]);

    List<Sale> sales = [];
    for (var map in maps) {
      final itemMaps = await db.query('sale_items', where: 'sale_id = ?', whereArgs: [map['id']]);
      final items = itemMaps.map((m) => SaleItem.fromMap(m)).toList();
      sales.add(Sale.fromMap(map, items));
    }
    return sales;
  }
}
