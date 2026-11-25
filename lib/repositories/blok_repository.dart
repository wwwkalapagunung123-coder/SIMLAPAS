// file: lib/repositories/blok_repository.dart
import '../helpers/database_helper.dart';
import '../model/block.dart';

/// Repository Pattern: Mengabstraksi akses data SQLite dan mengubahnya menjadi Objek Blok.
class BlokRepository {
  final DatabaseHelper _dbHelper;

  BlokRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// Mengambil semua blok dalam bentuk List<Blok>
  Future<List<Blok>> getAllBlok() async {
    final listMap = await _dbHelper.getAllBlok();
    return listMap.map((map) => Blok.fromMap(map)).toList();
  }

  /// Menambahkan blok baru
  Future<int> insertBlok(Blok blok) async {
    return _dbHelper.insertBlok(blok.toMap());
  }

  /// Menghitung jumlah napi yang saat ini menghuni blok
  Future<int> getJumlahNapiByBlok(String namaBlok) async {
    return _dbHelper.getJumlahNapiByBlok(namaBlok);
  }
}
