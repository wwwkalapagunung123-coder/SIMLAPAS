// file: lib/controllers/login_controller.dart
import '../model/petugas.dart';
import '../services/petugas_service.dart';

/// Controller: Menjembatani LoginScreen dengan PetugasService.
class LoginController {
  final PetugasService _petugasService;

  LoginController({PetugasService? petugasService})
      : _petugasService = petugasService ?? PetugasService();

  Future<Petugas?> prosesLogin(String username, String password) {
    return _petugasService.autentikasiPetugas(username, password);
  }

  Future<int> prosesRegister({
    required String nama,
    required String nip,
    required String password,
    required String role,
    String? blok,
  }) {
    return _petugasService.daftarkanPetugasBaru(
      nama: nama,
      nip: nip,
      password: password,
      role: role,
      blok: blok,
    );
  }
}
