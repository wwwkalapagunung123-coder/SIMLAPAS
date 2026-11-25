// file: lib/controllers/petugas_controller.dart
import '../model/petugas.dart';
import '../services/petugas_service.dart';

/// Controller: Menjembatani PetugasScreen dengan PetugasService.
class PetugasController {
  final PetugasService _petugasService;

  PetugasController({PetugasService? petugasService})
      : _petugasService = petugasService ?? PetugasService();

  Future<List<Petugas>> muatSemuaPetugas() async {
    return _petugasService.ambilSemuaPetugas();
  }

  Future<int> perbaruiPenugasanBlok({
    required int id,
    required String penugasan,
  }) async {
    return _petugasService.perbaruiPenugasanBlok(id: id, penugasan: penugasan);
  }

  Future<int> perbaruiProfilPetugas({
    required int id,
    required String nama,
    required String nip,
    required String password,
    required String role,
    String? blok,
  }) async {
    return _petugasService.perbaruiProfilPetugas(
      id: id,
      nama: nama,
      nip: nip,
      password: password,
      role: role,
      blok: blok,
    );
  }

  Future<int> hapusPetugas(int id) async {
    return _petugasService.hapusPetugas(id);
  }
}
