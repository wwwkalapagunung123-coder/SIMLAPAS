// file: lib/repositories/narapidana_repository.dart
import '../helpers/database_helper.dart';
import '../model/narapidana.dart';
import '../model/insiden.dart';

/// Repository Pattern: Mengabstraksi akses data SQLite dan mengubahnya menjadi Objek Narapidana & Insiden.
class NarapidanaRepository {
  final DatabaseHelper _dbHelper;

  NarapidanaRepository({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// Mengambil semua narapidana dalam bentuk List<Narapidana>
  Future<List<Narapidana>> getAllNarapidana() async {
    final listMap = await _dbHelper.getAllNarapidana();
    return listMap.map((map) => Narapidana.fromMap(map)).toList();
  }

  /// Mengambil narapidana berdasarkan nama blok
  Future<List<Narapidana>> getNarapidanaByBlok(String blok) async {
    final listMap = await _dbHelper.getNarapidanaByBlok(blok);
    return listMap.map((map) => Narapidana.fromMap(map)).toList();
  }

  /// Menyimpan narapidana baru beserta opsional catatan insiden
  Future<void> insertNarapidanaWithInsiden(
    Narapidana napi, {
    String? keteranganInsiden,
    String? nipPetugas,
  }) async {
    final tanggalHariIni = DateTime.now().toIso8601String().substring(0, 10);
    final insidenMap =
        (keteranganInsiden != null && keteranganInsiden.isNotEmpty)
        ? {
            'no_reg': napi.noRegistrasi,
            'nama_napi': napi.nama,
            'nip_petugas': nipPetugas ?? 'SIPIR-01',
            'keterangan': keteranganInsiden,
            'tanggal': tanggalHariIni,
          }
        : null;

    await _dbHelper.insertNarapidanaWithInsiden(
      napi.toMap(),
      insiden: insidenMap,
    );
  }

  /// Memperbarui data narapidana
  Future<int> updateNarapidana(Narapidana napi) async {
    return _dbHelper.updateNarapidana(napi.toMap());
  }

  /// Memperbarui data narapidana beserta catatan insiden
  Future<void> updateNarapidanaWithInsiden(
    Narapidana napi, {
    Insiden? insiden,
  }) async {
    await _dbHelper.updateNarapidanaWithInsiden(
      napi.toMap(),
      insiden: insiden?.toMap(),
    );
  }

  /// Menghapus narapidana berdasarkan ID
  Future<int> deleteNarapidana(int id) async {
    return _dbHelper.deleteNarapidana(id);
  }

  /// Mengambil seluruh riwayat insiden narapidana sebagai List<Insiden>
  Future<List<Insiden>> getInsidenByNapi(String noReg) async {
    final listMap = await _dbHelper.getInsidenByNapi(noReg);
    return listMap.map((map) => Insiden.fromMap(map)).toList();
  }

  /// Menambah catatan insiden baru
  Future<int> insertInsiden(Insiden insiden) async {
    return _dbHelper.insertInsiden(insiden.toMap());
  }

  /// Mengurangi estimasi tanggal bebas berdasarkan jumlah hari remisi
  Future<void> kurangiEstimasiBebas(String noReg, int jumlahHari) async {
    final list = await getAllNarapidana();
    final napi = list.firstWhere(
      (n) => n.noRegistrasi == noReg,
      orElse: () =>
          throw StateError('Narapidana dengan no_reg $noReg tidak ditemukan.'),
    );

    napi.potongMasaTahanan(jumlahHari);
    await updateNarapidana(napi);
  }

  /// Memperbarui status narapidana (misal: 'Bebas Bersyarat', 'Dipindahkan')
  Future<void> updateStatus(String noReg, String statusBaru) async {
    final list = await getAllNarapidana();
    final napi = list.firstWhere(
      (n) => n.noRegistrasi == noReg,
      orElse: () => throw StateError('Narapidana tidak ditemukan.'),
    );

    napi.status = statusBaru;
    await updateNarapidana(napi);
  }
}
