// file: lib/services/kunjungan_service.dart
import '../model/kunjungan.dart';
import '../repositories/kunjungan_repository.dart';

/// Service Layer: Menangani aturan penjadwalan dan pemantauan kunjungan besuk.
class KunjunganService {
  final KunjunganRepository _kunjunganRepo;

  KunjunganService({KunjunganRepository? kunjunganRepo})
      : _kunjunganRepo = kunjunganRepo ?? KunjunganRepository();

  /// Mengambil semua jadwal kunjungan dari database SQLite
  Future<List<Kunjungan>> ambilSemuaKunjungan() async {
    return _kunjunganRepo.getAllKunjungan();
  }

  /// Pendaftaran jadwal kunjungan baru
  Future<int> jadwalkanKunjunganBaru({
    required String namaPengunjung,
    required String hubungan,
    required String noRegNapi,
    required String namaNapi,
    required String waktu,
  }) async {
    final kunjungan = Kunjungan(
      namaPengunjung: namaPengunjung,
      hubungan: hubungan,
      noRegNarapidana: noRegNapi,
      namaNarapidana: namaNapi,
      waktu: waktu,
      status: 'Terjadwal',
    );
    return _kunjunganRepo.insertKunjungan(kunjungan);
  }

  /// Memperbarui status kunjungan (misal: 'Berlangsung', 'Selesai')
  Future<int> ubahStatusKunjungan(int id, String statusBaru) async {
    return _kunjunganRepo.updateStatus(id, statusBaru);
  }

  /// Menghapus atau membatalkan sesi kunjungan
  Future<int> batalkanKunjungan(int id) async {
    return _kunjunganRepo.deleteKunjungan(id);
  }
}
