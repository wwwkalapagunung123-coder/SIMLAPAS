import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static Future<Database>? _databaseOpening;

  DatabaseHelper._init();

  Future<void> close() async {
    final db = _database;
    _database = null;
    _databaseOpening = null;
    await db?.close();
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    final opening = _databaseOpening;
    if (opening != null) return opening;

    final future = _initDB('simlapas.db');
    _databaseOpening = future;
    try {
      final db = await future;
      _database = db;
      return db;
    } catch (_) {
      _databaseOpening = null;
      rethrow;
    }
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(
      path,
      version: 2,
      onConfigure: (db) => db.execute('PRAGMA busy_timeout = 5000'),
      onCreate: (db, version) => _createTables(db),
      onUpgrade: (db, oldVersion, newVersion) => _createTables(db),
      onOpen: _ensureUserColumns,
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        nip TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        blok TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS narapidana (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        no_reg TEXT UNIQUE NOT NULL,
        nama TEXT NOT NULL,
        blok TEXT NOT NULL,
        sel TEXT NOT NULL,
        tanggal_masuk TEXT NOT NULL,
        estimasi_bebas TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS insiden (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        no_reg TEXT NOT NULL,
        nama_napi TEXT NOT NULL,
        nip_petugas TEXT NOT NULL,
        keterangan TEXT NOT NULL,
        tanggal TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS blok (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_blok TEXT UNIQUE NOT NULL,
        kapasitas_sel INTEGER NOT NULL,
        maks_penghuni INTEGER NOT NULL,
        tingkat_keamanan TEXT NOT NULL
      )
    ''');
  }

  Future<void> _ensureUserColumns(Database db) async {
    final columns = await db.rawQuery('PRAGMA table_info(users)');
    final existingColumns = columns
        .map((column) => column['name'] as String)
        .toSet();
    const requiredColumns = <String, String>{
      'nama': "TEXT NOT NULL DEFAULT ''",
      'nip': "TEXT NOT NULL DEFAULT ''",
      'password': "TEXT NOT NULL DEFAULT ''",
      'role': "TEXT NOT NULL DEFAULT 'Sipir'",
      'blok': "TEXT",
    };

    for (final entry in requiredColumns.entries) {
      if (!existingColumns.contains(entry.key)) {
        await db.execute(
          'ALTER TABLE users ADD COLUMN ${entry.key} ${entry.value}',
        );
      }
    }
  }

  Future<int> registerUser({
    required String nama,
    required String nip,
    required String password,
    required String role,
    String? blok,
  }) async {
    final db = await database;
    final normalizedNip = nip.trim();
    final existingUsers = await db.query(
      'users',
      columns: ['id'],
      where: 'nip = ?',
      whereArgs: [normalizedNip],
      limit: 1,
    );
    if (existingUsers.isNotEmpty) {
      throw StateError('NIP sudah terdaftar.');
    }

    return db.insert('users', {
      'nama': nama.trim(),
      'nip': normalizedNip,
      'password': password,
      'role': role,
      'blok': blok ?? '-',
    });
  }

  Future<Map<String, Object?>?> loginUser(
    String username,
    String password,
  ) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: '(nip = ? OR nama = ?) AND password = ?',
      whereArgs: [username, username, password],
      limit: 1,
    );

    return result.isEmpty ? null : result.first;
  }

  Future<List<Map<String, Object?>>> getAllUsers() async {
    final db = await database;
    return db.query('users');
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateUser({
    required int id,
    required String nama,
    required String nip,
    required String password,
    required String role,
    String? blok,
  }) async {
    final db = await database;
    return db.update(
      'users',
      {
        'nama': nama,
        'nip': nip,
        'password': password,
        'role': role,
        'blok': blok ?? '-',
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertNarapidana(Map<String, Object?> row) async {
    final db = await database;
    return db.insert('narapidana', row);
  }

  Future<void> insertNarapidanaWithInsiden(
    Map<String, Object?> narapidana, {
    Map<String, Object?>? insiden,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert('narapidana', narapidana);
      if (insiden != null) {
        await txn.insert('insiden', insiden);
      }
    });
  }

  Future<List<Map<String, Object?>>> getAllNarapidana() async {
    final db = await database;
    return db.query('narapidana', orderBy: 'id DESC');
  }

  Future<List<Map<String, Object?>>> getNarapidanaByBlok(String blok) async {
    final db = await database;
    return db.query(
      'narapidana',
      where: 'blok = ?',
      whereArgs: [blok],
      orderBy: 'id DESC',
    );
  }

  Future<int> updateNarapidana(Map<String, Object?> row) async {
    final db = await database;
    final id = row['id'] as int;
    return db.update('narapidana', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateNarapidanaWithInsiden(
    Map<String, Object?> narapidana, {
    Map<String, Object?>? insiden,
  }) async {
    final db = await database;
    final id = narapidana['id'] as int;
    await db.transaction((txn) async {
      final updated = await txn.update(
        'narapidana',
        narapidana,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (updated == 0) {
        throw StateError('Data narapidana tidak ditemukan.');
      }
      if (insiden != null) {
        final insidenId = insiden['id'] as int;
        final noReg = insiden['no_reg'] as String;
        final insidenUpdated = await txn.update(
          'insiden',
          Map<String, Object?>.from(insiden)..remove('id'),
          where: 'id = ? AND no_reg = ?',
          whereArgs: [insidenId, noReg],
        );
        if (insidenUpdated == 0) {
          throw StateError('Catatan insiden tidak ditemukan.');
        }
      }
    });
  }

  Future<int> deleteNarapidana(int id) async {
    final db = await database;
    return db.delete('narapidana', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, Object?>>> getInsidenByNapi(String noReg) async {
    final db = await database;
    return db.query(
      'insiden',
      where: 'no_reg = ?',
      whereArgs: [noReg],
      orderBy: 'id DESC',
    );
  }

  Future<int> insertInsiden(Map<String, Object?> row) async {
    final db = await database;
    return db.insert('insiden', row);
  }

  Future<List<Map<String, Object?>>> getAllBlok() async {
    final db = await database;
    return db.query('blok', orderBy: 'nama_blok');
  }

  Future<int> insertBlok(Map<String, Object?> row) async {
    final db = await database;
    return db.insert('blok', row);
  }

  Future<int> getJumlahNapiByBlok(String namaBlok) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as total FROM narapidana WHERE blok = ?',
      [namaBlok],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
