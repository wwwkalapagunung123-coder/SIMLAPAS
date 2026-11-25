// file: lib/services/petugas_service.dart
import '../model/petugas.dart';
import '../repositories/petugas_repository.dart';

/// Service Layer: Menangani seluruh logika bisnis pengelolaan Petugas (Sipir & Kepala Lapas).
class PetugasService {
  final PetugasRepository _petugasRepo;
  Petugas? _petugasAktif;

  PetugasService({PetugasRepository? petugasRepo})
      : _petugasRepo = petugasRepo ?? PetugasRepository();

  Petugas? get petugasAktif => _petugasAktif;

  /// Autentikasi / Login Petugas (Sipir atau Kepala Lapas) dari SQLite
  Future<Petugas?> autentikasiPetugas(String username, String password) async {
    final petugas = await _petugasRepo.login(username, password);
    _petugasAktif = petugas;
    return petugas;
  }

  /// Pendaftaran akun Petugas baru ke SQLite
  Future<int> daftarkanPetugasBaru({
    required String nama,
    required String nip,
    required String password,
    required String role,
    String? blok,
  }) async {
    return _petugasRepo.register(
      nama: nama,
      nip: nip,
      password: password,
      role: role,
      blok: blok,
    );
  }

  /// Mengambil semua petugas yang terdaftar di SQLite
  Future<List<Petugas>> ambilSemuaPetugas() async {
    return _petugasRepo.getAllPetugas();
  }

  /// Memperbarui penugasan blok / sel bagi petugas
  Future<int> perbaruiPenugasanBlok({
    required int id,
    required String penugasan,
  }) async {
    return _petugasRepo.updatePenugasanBlok(id: id, penugasan: penugasan);
  }

  /// Memperbarui profil lengkap petugas
  Future<int> perbaruiProfilPetugas({
    required int id,
    required String nama,
    required String nip,
    required String password,
    required String role,
    String? blok,
  }) async {
    return _petugasRepo.updatePetugas(
      id: id,
      nama: nama,
      nip: nip,
      password: password,
      role: role,
      blok: blok,
    );
  }

  /// Menghapus petugas dari database
  Future<int> hapusPetugas(int id) async {
    return _petugasRepo.deletePetugas(id);
  }

  /// Keluar dari sesi aplikasi
  void keluarSesi() {
    _petugasAktif = null;
  }
}
