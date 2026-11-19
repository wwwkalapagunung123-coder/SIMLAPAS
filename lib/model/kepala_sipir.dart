import 'petugas.dart';
import 'dart:developer' as developer;

class KepalaLapas extends Petugas {
  String periodeJabatan;
  String unitKerja;

  KepalaLapas({
    required super.nip,
    required super.nama,
    required this.periodeJabatan,
    required this.unitKerja,
  }) : super(
         jabatan: 'Kepala Lapas',
         shift: 'Reguler',
         blokJaga: 'Seluruh',
         statusTugas: 'Bertugas',
       );

  // Method khusus OOP untuk Kepala Lapas
  void setujuiRemisi(String namaNarapidana, int jumlahHari) {
    developer.log(
      'Kepala Lapas $nama menyetujui remisi $jumlahHari hari untuk $namaNarapidana.',
    );
  }

  void setujuiPembebasan(String namaNarapidana) {
    developer.log(
      'Kepala Lapas $nama menyetujui surat pembebasan untuk $namaNarapidana.',
    );
  }
}
