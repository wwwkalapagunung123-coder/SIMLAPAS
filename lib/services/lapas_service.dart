// file: lib/services/lapas_service.dart
import '../model/narapidana.dart';
import '../model/sipir.dart';
import '../model/kepala_sipir.dart';
import 'narapidana_service.dart';
import 'operasional_lapas_service.dart';

/// Facade Service: Menyediakan akses terpadu ke NarapidanaService dan OperasionalLapasService.
class LapasService {
  final NarapidanaService _napiService;
  final OperasionalLapasService _operasionalService;

  LapasService({
    NarapidanaService? napiService,
    OperasionalLapasService? operasionalService,
  }) : _napiService = napiService ?? NarapidanaService(),
       _operasionalService = operasionalService ?? OperasionalLapasService();

  Future<bool> daftarkanNarapidana({
    required String nama,
    required String noReg,
    required String blokNama,
    required String selNomor,
    DateTime? estimasiBebas,
    String? keteranganInsiden,
    String? nipPetugas,
  }) {
    return _napiService.daftarkanNarapidanaBaru(
      nama: nama,
      noReg: noReg,
      blokNama: blokNama,
      selNomor: selNomor,
      estimasiBebas: estimasiBebas,
      keteranganInsiden: keteranganInsiden,
      nipPetugas: nipPetugas,
    );
  }

  Future<bool> setujuiRemisiNarapidana({
    required KepalaLapas kalapas,
    required Narapidana napi,
    required int jumlahHari,
  }) {
    return _napiService.prosesRemisiOlehKalapas(
      kalapas: kalapas,
      napi: napi,
      jumlahHari: jumlahHari,
    );
  }

  Future<bool> setujuiPembebasanNarapidana({
    required KepalaLapas kalapas,
    required Narapidana napi,
  }) {
    return _napiService.prosesPembebasanOlehKalapas(
      kalapas: kalapas,
      napi: napi,
    );
  }

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

  Future<String> buatLaporanLapas() {
    return _operasionalService.buatLaporanResmiLapas();
  }

  Future<Map<String, dynamic>> getStatistikDashboard() {
    return _operasionalService.hitungStatistikLapas();
  }
}
