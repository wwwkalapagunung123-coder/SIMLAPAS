// file: lib/model/kepala_sipir.dart
import 'dart:developer' as developer;
import 'petugas.dart';

/// Subclass KepalaLapas mewarisi Petugas
class KepalaLapas extends Petugas {
  final String _periodeJabatan;
  final String _unitKerja;

  KepalaLapas({
    super.id,
    required super.nip,
    required super.nama,
    super.gaji = 12000000.0,
    required String periodeJabatan,
    required String unitKerja,
    super.shift = 'Reguler',
    super.blokJaga = 'Seluruh',
    super.selJaga,
    super.statusTugas = 'Bertugas',
  })  : _periodeJabatan = periodeJabatan,
        _unitKerja = unitKerja,
        super(jabatan: 'Kepala Lapas');

  String get periodeJabatan => _periodeJabatan;
  String get unitKerja => _unitKerja;

  @override
  void lakukanTugas() {
    developer.log('Kepala Lapas $nama memimpin evaluasi operasional dan persetujuan hak integrasi.');
  }

  @override
  String getDeskripsiTugas() =>
      'Memimpin lapas, mengambil keputusan remisi, pembebasan bersyarat, dan pengawasan manajerial.';

  bool setujuiRemisi(String namaNarapidana, int hari) {
    if (hari <= 0) return false;
    developer.log(
      'Kepala Lapas $nama menyetujui remisi $hari hari untuk $namaNarapidana.',
    );
    return true;
  }

  bool setujuiPembebasan(String namaNarapidana) {
    developer.log(
      'Kepala Lapas $nama menyetujui pembebasan untuk $namaNarapidana.',
    );
    return true;
  }

  @override
  String info() =>
      'Kepala Lapas: $nama (NIP: $nip) - Periode: $_periodeJabatan - Unit: $_unitKerja';
}
