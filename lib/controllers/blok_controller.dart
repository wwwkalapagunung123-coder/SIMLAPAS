// file: lib/controllers/blok_controller.dart
import '../model/block.dart';
import '../repositories/blok_repository.dart';

/// Controller: Menjembatani BlokSelScreen dengan BlokRepository dan SQLite.
class BlokController {
  final BlokRepository _blokRepo;

  BlokController({BlokRepository? blokRepo})
      : _blokRepo = blokRepo ?? BlokRepository();

  Future<List<Blok>> muatSemuaBlok() {
    return _blokRepo.getAllBlok();
  }

  Future<int> tambahBlokBaru({
    required String namaBlok,
    required int kapasitasSel,
    required int maksPenghuni,
    required String tingkatKeamanan,
  }) {
    final blok = Blok(
      kode: namaBlok,
      kapasitasSel: kapasitasSel,
      maksPenghuni: maksPenghuni,
      tingkatKeamanan: tingkatKeamanan,
    );
    return _blokRepo.insertBlok(blok);
  }

  Future<int> hitungPenghuniBlok(String namaBlok) {
    return _blokRepo.getJumlahNapiByBlok(namaBlok);
  }
}
