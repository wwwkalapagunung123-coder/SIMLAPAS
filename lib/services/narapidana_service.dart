// file: lib/services/narapidana_service.dart
import '../model/narapidana.dart';
import '../model/block.dart';
import '../model/sel.dart';
import '../model/kepala_sipir.dart';
import '../model/insiden.dart';
import '../repositories/narapidana_repository.dart';
import '../repositories/blok_repository.dart';

/// Service Layer: Menangani aturan bisnis narapidana, kapasitas sel, dan remisi.
class NarapidanaService {
  final NarapidanaRepository _napiRepo;
  final BlokRepository _blokRepo;

  NarapidanaService({NarapidanaRepository? napiRepo, BlokRepository? blokRepo})
    : _napiRepo = napiRepo ?? NarapidanaRepository(),
      _blokRepo = blokRepo ?? BlokRepository();

  /// Mengambil semua data narapidana dari SQLite
  Future<List<Narapidana>> ambilSemuaNarapidana() async {
    return _napiRepo.getAllNarapidana();
  }

  /// Mengambil data narapidana berdasarkan blok tertentu
  Future<List<Narapidana>> ambilNarapidanaBerdasarkanBlok(String blok) async {
    return _napiRepo.getNarapidanaByBlok(blok);
  }

  /// Pendaftaran Narapidana Baru dengan validasi aturan kapasitas sel & blok
  Future<bool> daftarkanNarapidanaBaru({
    required String nama,
    required String noReg,
    required String blokNama,
    required String selNomor,
    DateTime? estimasiBebas,
    String? keteranganInsiden,
    String? nipPetugas,
  }) async {
    if (nama.trim().isEmpty || noReg.trim().isEmpty) return false;

    // Cek batas kapasitas maksimum di database
    final jumlahPenghuni = await _blokRepo.getJumlahNapiByBlok(blokNama);
    final allBlok = await _blokRepo.getAllBlok();
    final blokTerpilih = allBlok.firstWhere(
      (b) => b.kode == blokNama,
      orElse: () => Blok(kode: blokNama, tingkatKeamanan: 'Menengah'),
    );

    if (jumlahPenghuni >= blokTerpilih.maksPenghuni) {
      throw StateError(
        'Kapasitas blok $blokNama sudah melebihi batas maksimal (${blokTerpilih.maksPenghuni} orang)!',
      );
    }

    // Instansiasi objek OOP Narapidana
    final napiBaru = Narapidana(
      nik: noReg,
      nama: nama,
      noRegistrasi: noReg,
      status: 'Aktif',
      blok: blokNama,
      selNomor: selNomor,
      tanggalMasuk: DateTime.now(),
      estimasiBebas:
          estimasiBebas ?? DateTime.now().add(const Duration(days: 730)),
    );

    await _napiRepo.insertNarapidanaWithInsiden(
      napiBaru,
      keteranganInsiden: keteranganInsiden,
      nipPetugas: nipPetugas,
    );
    return true;
  }

  /// Eksekusi persetujuan remisi oleh Kepala Lapas (OOP Method Execution)
  Future<bool> prosesRemisiOlehKalapas({
    required KepalaLapas kalapas,
    required Narapidana napi,
    required int jumlahHari,
  }) async {
    // 1. Eksekusi method OOP Kepala Lapas
    final disetujui = kalapas.setujuiRemisi(napi.nama, jumlahHari);
    if (!disetujui) return false;

    // 2. Potong estimasi bebas di model dan database
    await _napiRepo.kurangiEstimasiBebas(napi.noRegistrasi, jumlahHari);
    return true;
  }

  /// Eksekusi persetujuan pembebasan bersyarat oleh Kepala Lapas
  Future<bool> prosesPembebasanOlehKalapas({
    required KepalaLapas kalapas,
    required Narapidana napi,
  }) async {
    final disetujui = kalapas.setujuiPembebasan(napi.nama);
    if (!disetujui) return false;

    await _napiRepo.updateStatus(napi.noRegistrasi, 'Bebas Bersyarat');
    return true;
  }

  /// Memindahkan narapidana ke sel baru
  Future<bool> mutasiSelNarapidana({
    required Narapidana napi,
    required Sel selTujuan,
  }) async {
    if (selTujuan.isPenuh()) return false;

    selTujuan.masukkan(napi);
    await _napiRepo.updateNarapidana(napi);
    return true;
  }

  /// Mengubah data narapidana di SQLite
  Future<void> perbaruiNarapidana(Narapidana napi, {Insiden? insiden}) async {
    await _napiRepo.updateNarapidanaWithInsiden(napi, insiden: insiden);
  }

  /// Menghapus data narapidana
  Future<int> hapusNarapidana(int id) async {
    return _napiRepo.deleteNarapidana(id);
  }

  Future<void> ubahStatusNarapidana(String noReg, String status) {
    return _napiRepo.updateStatus(noReg, status);
  }

  /// Mengambil riwayat insiden narapidana
  Future<List<Insiden>> ambilInsidenNarapidana(String noReg) async {
    return _napiRepo.getInsidenByNapi(noReg);
  }
}
