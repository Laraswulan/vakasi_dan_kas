import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/transaksi_vakasi.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('kas_vacasi.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transaksi(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        jenis TEXT NOT NULL,
        judul TEXT NOT NULL,
        nominal INTEGER,
        nama TEXT,
        tanggal TEXT
      )
    ''');
  }

  // Get semua data
  Future<List<TransaksiVacasi>> getAllData() async {
    final db = await instance.database;
    final result = await db.query('transaksi', orderBy: 'id DESC');
    return result.map((map) => TransaksiVacasi.fromMap(map)).toList();
  }

  // Insert
  Future<int> insertData(TransaksiVacasi data) async {
    final db = await instance.database;
    return await db.insert('transaksi', data.toMap());
  }

  // Update
  Future<int> updateData(TransaksiVacasi data) async {
    final db = await instance.database;
    return await db.update(
      'transaksi',
      data.toMap(),
      where: 'id = ?',
      whereArgs: [data.id],
    );
  }

  // Delete
  Future<int> deleteData(int id) async {
    final db = await instance.database;
    return await db.delete('transaksi', where: 'id = ?', whereArgs: [id]);
  }
}
