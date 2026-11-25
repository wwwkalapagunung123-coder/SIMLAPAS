// file: lib/controllers/operasional_sipir_controller.dart
import '../services/operasional_lapas_service.dart';
import '../services/narapidana_service.dart';
import '../model/sipir.dart';
import '../model/narapidana.dart';

/// Controller: Menjembatani OperasionalSipirScreen dengan NarapidanaService dan OperasionalLapasService.
class OperasionalSipirController {
  final NarapidanaService _napiService;
  final OperasionalLapasService _operasionalService;

  OperasionalSipirController({
    NarapidanaService? napiService,
    OperasionalLapasService? operasionalService,
  }) : _napiService = napiService ?? NarapidanaService(),
       _operasionalService = operasionalService ?? OperasionalLapasService();

  /// Pendaftaran narapidana ke sel dari input user di screen operasional sipir
  Future<bool> simpanNarapidanaBaru({
    required String nama,
    required String noReg,
    required String blokNama,
    required String selNomor,
    String? keteranganInsiden,
    String? nipPetugas,
  }) {
    return _napiService.daftarkanNarapidanaBaru(
      nama: nama,
      noReg: noReg,
      blokNama: blokNama,
      selNomor: selNomor,
      keteranganInsiden: keteranganInsiden,
      nipPetugas: nipPetugas,
    );
  }

  Future<List<Narapidana>> muatNarapidanaByBlok(String blok) {
    return _napiService.ambilNarapidanaBerdasarkanBlok(blok);
  }

  Future<void> ubahStatusNarapidana(String noReg, String status) {
    return _napiService.ubahStatusNarapidana(noReg, status);
  }

  /// Pencatatan insiden oleh Sipir
  Future<void> catatInsidenOlehSipir({
    required Sipir sipir,
    required Narapidana napi,
    required String keterangan,
  }) {
    return _operasionalService.catatInsidenOlehSipir(
      sipir: sipir,
      napi: napi,
      keterangan: keterangan,
    );
  }
}
