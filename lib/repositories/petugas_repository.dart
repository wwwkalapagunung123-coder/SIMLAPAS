// file: lib/repositories/petugas_repository.dart
import '../helpers/database_helper.dart';
import '../model/petugas.dart';

/// Repository Pattern: Mengabstraksi akses data user/petugas dan mengubahnya menjadi Objek Petugas (Sipir / KepalaLapas).
class PetugasRepository {
  final DatabaseHelper _dbHelper;

  PetugasRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// Mengambil seluruh petugas dalam bentuk List<Petugas>
  Future<List<Petugas>> getAllPetugas() async {
    final listMap = await _dbHelper.getAllUsers();
    return listMap.map((map) => Petugas.fromMap(map)).toList();
  }

  /// Autentikasi user dan mengembalikan objek turunan Petugas konkret
  Future<Petugas?> login(String username, String password) async {
    final userMap = await _dbHelper.loginUser(username, password);
    if (userMap == null) return null;
    return Petugas.fromMap(userMap);
  }

  /// Pendaftaran user / petugas baru
  Future<int> register({
    required String nama,
    required String nip,
    required String password,
    required String role,
    String? blok,
  }) async {
    return _dbHelper.registerUser(
      nama: nama,
      nip: nip,
      password: password,
      role: role,
      blok: blok,
    );
  }

  /// Memperbarui informasi petugas
  Future<int> updatePetugas({
    required int id,
    required String nama,
    required String nip,
    required String password,
    required String role,
    String? blok,
  }) async {
    return _dbHelper.updateUser(
      id: id,
      nama: nama,
      nip: nip,
      password: password,
      role: role,
      blok: blok,
    );
  }

  /// Memperbarui penugasan blok petugas saja
  Future<int> updatePenugasanBlok({
    required int id,
    required String penugasan,
  }) async {
    return _dbHelper.updateUserBlok(id: id, blok: penugasan);
  }

  /// Menghapus petugas berdasarkan ID
  Future<int> deletePetugas(int id) async {
    return _dbHelper.deleteUser(id);
  }
}
