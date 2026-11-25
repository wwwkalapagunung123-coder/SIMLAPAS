// file: lib/services/operasional_lapas_service.dart
import '../model/sipir.dart';
import '../model/narapidana.dart';
import '../model/insiden.dart';
import '../repositories/narapidana_repository.dart';
import '../repositories/blok_repository.dart';
import '../repositories/petugas_repository.dart';
import '../repositories/kunjungan_repository.dart';
import '../repositories/penjara_repository.dart';

/// Service Layer: Menangani operasional penjara, pencatatan insiden oleh sipir, dan pelaporan polimorfis.
class OperasionalLapasService {
  final NarapidanaRepository _napiRepo;
  final BlokRepository _blokRepo;
  final PetugasRepository _petugasRepo;
  final KunjunganRepository _kunjunganRepo;

  OperasionalLapasService({
    NarapidanaRepository? napiRepo,
    BlokRepository? blokRepo,
    PetugasRepository? petugasRepo,
    KunjunganRepository? kunjunganRepo,
  })  : _napiRepo = napiRepo ?? NarapidanaRepository(),
        _blokRepo = blokRepo ?? BlokRepository(),
        _petugasRepo = petugasRepo ?? PetugasRepository(),
        _kunjunganRepo = kunjunganRepo ?? KunjunganRepository();

  /// Pencatatan insiden pelanggaran narapidana oleh Sipir (OOP Method Execution)
  Future<void> catatInsidenOlehSipir({
    required Sipir sipir,
    required Narapidana napi,
    required String keterangan,
  }) async {
    // 1. Eksekusi method OOP milik Sipir
    sipir.catatInsiden(napi, keterangan);

    // 2. Catat ke database SQLite
    final insiden = Insiden(
      noReg: napi.noRegistrasi,
      namaNapi: napi.nama,
      nipPetugas: sipir.nip,
      keterangan: keterangan,
      tanggal: DateTime.now().toIso8601String().substring(0, 10),
    );
    await _napiRepo.insertInsiden(insiden);
  }

  /// Pembuatan Laporan Resmi Lapas (Polimorfisme Interface Laporan)
  Future<String> buatLaporanResmiLapas() async {
    // Membaca relasi OOP Penjara -> Blok -> Sel -> Narapidana langsung dari SQLite
    final penjara = await PenjaraRepository.loadPenjaraFromDatabase();

    // Memanggil method polimorfis dari Interface Laporan
    return penjara.buatLaporan();
  }

  /// Menghitung ringkasan statistik terkini dari database SQLite
  Future<Map<String, dynamic>> hitungStatistikLapas() async {
    final listNapi = await _napiRepo.getAllNarapidana();
    final allBlok = await _blokRepo.getAllBlok();
    final allPetugas = await _petugasRepo.getAllPetugas();
    final allKunjungan = await _kunjunganRepo.getAllKunjungan();

    final napiAktif = listNapi.where((n) => n.status == 'Aktif').length;
    int totalKapasitas = 0;
    for (var b in allBlok) {
      totalKapasitas += b.maksPenghuni;
    }

    final petugasBertugas = allPetugas.where((p) => p.isBertugas).length;
    final kunjunganHariIni = allKunjungan.where((k) => k.status != 'Selesai').length;

    final double okupansi = totalKapasitas > 0
        ? (napiAktif / totalKapasitas) * 100
        : 0.0;

    return {
      'totalNapiAktif': napiAktif,
      'totalBlok': allBlok.length,
      'totalKapasitas': totalKapasitas,
      'okupansiPersen': okupansi.toStringAsFixed(1),
      'petugasBertugas': petugasBertugas,
      'totalPetugas': allPetugas.length,
      'kunjunganHariIni': kunjunganHariIni,
      'usulanRemisi': napiAktif,
    };
  }
}
