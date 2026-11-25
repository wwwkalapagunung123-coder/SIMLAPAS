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
      version: 3,
      onConfigure: (db) => db.execute('PRAGMA busy_timeout = 5000'),
      onCreate: (db, version) async {
        await _createTables(db);
        await _seedInitialData(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _createTables(db);
      },
      onOpen: (db) async {
        await _createTables(db);
        await _ensureUserColumns(db);
        await _seedInitialData(db);
      },
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
    await db.execute('''
      CREATE TABLE IF NOT EXISTS kunjungan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_pengunjung TEXT NOT NULL,
        hubungan TEXT NOT NULL,
        no_reg_napi TEXT NOT NULL,
        nama_napi TEXT NOT NULL,
        waktu TEXT NOT NULL,
        status TEXT NOT NULL
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

  /// Mengisi data awal ke SQLite jika database masih kosong
  Future<void> _seedInitialData(Database db) async {
    // 1. Seed Blok jika kosong
    final countBlok = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM blok'),
    ) ?? 0;
    if (countBlok == 0) {
      await db.insert('blok', {
        'nama_blok': 'Blok A',
        'kapasitas_sel': 8,
        'maks_penghuni': 48,
        'tingkat_keamanan': 'Menengah',
      });
      await db.insert('blok', {
        'nama_blok': 'Blok B',
        'kapasitas_sel': 8,
        'maks_penghuni': 48,
        'tingkat_keamanan': 'Menengah',
      });
      await db.insert('blok', {
        'nama_blok': 'Blok C',
        'kapasitas_sel': 6,
        'maks_penghuni': 36,
        'tingkat_keamanan': 'Tinggi',
      });
      await db.insert('blok', {
        'nama_blok': 'Blok Isolasi',
        'kapasitas_sel': 4,
        'maks_penghuni': 12,
        'tingkat_keamanan': 'Maksimal',
      });
    }

    // 2. Seed Narapidana jika kosong
    final countNapi = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM narapidana'),
    ) ?? 0;
    if (countNapi == 0) {
      await db.insert('narapidana', {
        'no_reg': 'REG-2024-0018',
        'nama': 'Arif Setiawan',
        'blok': 'Blok A',
        'sel': 'Blok A-01',
        'tanggal_masuk': '2024-01-10',
        'estimasi_bebas': '2027-01-10',
        'status': 'Aktif',
      });
      await db.insert('narapidana', {
        'no_reg': 'REG-2024-0026',
        'nama': 'Rizky Saputra',
        'blok': 'Blok B',
        'sel': 'Blok B-01',
        'tanggal_masuk': '2024-02-15',
        'estimasi_bebas': '2026-08-15',
        'status': 'Aktif',
      });
      await db.insert('narapidana', {
        'no_reg': 'REG-2023-0041',
        'nama': 'Bima Santoso',
        'blok': 'Blok A',
        'sel': 'Blok A-02',
        'tanggal_masuk': '2023-05-20',
        'estimasi_bebas': '2026-11-20',
        'status': 'Aktif',
      });
      await db.insert('narapidana', {
        'no_reg': 'REG-2025-0007',
        'nama': 'Fajar Nugraha',
        'blok': 'Blok C',
        'sel': 'Blok C-01',
        'tanggal_masuk': '2025-03-01',
        'estimasi_bebas': '2028-03-01',
        'status': 'Aktif',
      });
    }

    // 3. Seed Kunjungan jika kosong
    final countKunjungan = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM kunjungan'),
    ) ?? 0;
    if (countKunjungan == 0) {
      await db.insert('kunjungan', {
        'nama_pengunjung': 'Sari Lestari',
        'hubungan': 'Istri',
        'no_reg_napi': 'REG-2024-0018',
        'nama_napi': 'Arif Setiawan',
        'waktu': '10.00 - 10.30',
        'status': 'Terjadwal',
      });
      await db.insert('kunjungan', {
        'nama_pengunjung': 'Dewi Santoso',
        'hubungan': 'Istri',
        'no_reg_napi': 'REG-2023-0041',
        'nama_napi': 'Bima Santoso',
        'waktu': '08.00 - 08.30',
        'status': 'Selesai',
      });
      await db.insert('kunjungan', {
        'nama_pengunjung': 'Lina Nugraha',
        'hubungan': 'Ibu',
        'no_reg_napi': 'REG-2025-0007',
        'nama_napi': 'Fajar Nugraha',
        'waktu': '09.20 - 10.00',
        'status': 'Berlangsung',
      });
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

  Future<int> updateUserBlok({
    required int id,
    required String blok,
  }) async {
    final db = await database;
    return db.update(
      'users',
      {'blok': blok},
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

  // --- QUERY KUNJUNGAN ---
  Future<List<Map<String, Object?>>> getAllKunjungan() async {
    final db = await database;
    return db.query('kunjungan', orderBy: 'id DESC');
  }

  Future<int> insertKunjungan(Map<String, Object?> row) async {
    final db = await database;
    return db.insert('kunjungan', row);
  }

  Future<int> updateKunjunganStatus(int id, String status) async {
    final db = await database;
    return db.update(
      'kunjungan',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteKunjungan(int id) async {
    final db = await database;
    return db.delete('kunjungan', where: 'id = ?', whereArgs: [id]);
  }
}
