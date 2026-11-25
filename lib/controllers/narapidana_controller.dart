// file: lib/controllers/narapidana_controller.dart
import '../model/narapidana.dart';
import '../model/insiden.dart';
import '../services/narapidana_service.dart';

/// Controller: Menjembatani NarapidanaScreen dengan NarapidanaService.
class NarapidanaController {
  final NarapidanaService _napiService;

  NarapidanaController({NarapidanaService? napiService})
    : _napiService = napiService ?? NarapidanaService();

  Future<List<Narapidana>> muatSemuaNarapidana() async {
    return _napiService.ambilSemuaNarapidana();
  }

  Future<List<Narapidana>> muatNarapidanaByBlok(String blok) async {
    return _napiService.ambilNarapidanaBerdasarkanBlok(blok);
  }

  Future<bool> daftarkanNarapidana({
    required String nama,
    required String noReg,
    required String blokNama,
    required String selNomor,
    DateTime? estimasiBebas,
    String? keteranganInsiden,
    String? nipPetugas,
  }) async {
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

  Future<void> perbaruiNarapidana(Narapidana napi, {Insiden? insiden}) async {
    return _napiService.perbaruiNarapidana(napi, insiden: insiden);
  }

  Future<void> perbaruiDataNarapidana({
    required Narapidana dataLama,
    required String nama,
    required String blok,
    required String sel,
    required DateTime estimasiBebas,
    Insiden? insidenTerpilih,
    String? keteranganInsiden,
  }) {
    final napi = Narapidana(
      id: dataLama.id,
      nik: dataLama.nik,
      nama: nama,
      noRegistrasi: dataLama.noRegistrasi,
      status: dataLama.status,
      blok: blok,
      selNomor: sel,
      tanggalMasuk: dataLama.tanggalMasuk,
      estimasiBebas: estimasiBebas,
    );
    final insiden = insidenTerpilih == null
        ? null
        : Insiden(
            id: insidenTerpilih.id,
            noReg: dataLama.noRegistrasi,
            namaNapi: insidenTerpilih.namaNapi,
            nipPetugas: insidenTerpilih.nipPetugas,
            keterangan: keteranganInsiden?.trim() ?? '',
            tanggal: insidenTerpilih.tanggal,
          );

    return perbaruiNarapidana(napi, insiden: insiden);
  }

  Future<int> hapusNarapidana(int id) async {
    return _napiService.hapusNarapidana(id);
  }

  Future<List<Insiden>> muatInsiden(String noReg) async {
    return _napiService.ambilInsidenNarapidana(noReg);
  }
}
