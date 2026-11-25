// file: lib/controllers/kunjungan_controller.dart
import '../model/kunjungan.dart';
import '../model/narapidana.dart';
import '../services/kunjungan_service.dart';
import '../services/narapidana_service.dart';

/// Controller: Menjembatani KunjunganScreen dengan KunjunganService dan database SQLite.
class KunjunganController {
  final KunjunganService _kunjunganService;
  final NarapidanaService _napiService;

  KunjunganController({
    KunjunganService? kunjunganService,
    NarapidanaService? napiService,
  }) : _kunjunganService = kunjunganService ?? KunjunganService(),
       _napiService = napiService ?? NarapidanaService();

  /// Mengambil daftar semua jadwal kunjungan dari database
  Future<List<Kunjungan>> muatSemuaKunjungan() async {
    return _kunjunganService.ambilSemuaKunjungan();
  }

  /// Mengambil daftar narapidana dari database untuk pilihan dropdown pembesuk
  Future<List<Narapidana>> muatDaftarNarapidana() async {
    final list = await _napiService.ambilSemuaNarapidana();
    return list.where((n) => n.status == 'Aktif').toList();
  }

  /// Menambahkan jadwal kunjungan baru ke database
  Future<int> jadwalkanKunjungan({
    required String namaPengunjung,
    required String hubungan,
    required String noRegNapi,
    required String namaNapi,
    required String waktu,
  }) async {
    return _kunjunganService.jadwalkanKunjunganBaru(
      namaPengunjung: namaPengunjung,
      hubungan: hubungan,
      noRegNapi: noRegNapi,
      namaNapi: namaNapi,
      waktu: waktu,
    );
  }

  /// Mengubah status kunjungan di database
  Future<int> ubahStatus(int id, String statusBaru) async {
    return _kunjunganService.ubahStatusKunjungan(id, statusBaru);
  }

  /// Menghapus jadwal kunjungan
  Future<int> hapusKunjungan(int id) async {
    return _kunjunganService.batalkanKunjungan(id);
  }
}
