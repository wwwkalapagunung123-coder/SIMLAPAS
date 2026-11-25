// file: lib/repositories/kunjungan_repository.dart
import '../helpers/database_helper.dart';
import '../model/kunjungan.dart';

/// Repository Pattern: Mengambil data kunjungan dari SQLite dan mengubahnya menjadi Objek Kunjungan.
class KunjunganRepository {
  final DatabaseHelper _dbHelper;

  KunjunganRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// Mengambil semua jadwal kunjungan dari database
  Future<List<Kunjungan>> getAllKunjungan() async {
    final listMap = await _dbHelper.getAllKunjungan();
    return listMap.map((map) => Kunjungan.fromMap(map)).toList();
  }

  /// Menambahkan kunjungan baru ke database
  Future<int> insertKunjungan(Kunjungan kunjungan) async {
    return _dbHelper.insertKunjungan(kunjungan.toMap());
  }

  /// Memperbarui status sesi kunjungan
  Future<int> updateStatus(int id, String status) async {
    return _dbHelper.updateKunjunganStatus(id, status);
  }

  /// Menghapus kunjungan berdasarkan ID
  Future<int> deleteKunjungan(int id) async {
    return _dbHelper.deleteKunjungan(id);
  }
}
