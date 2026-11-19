import 'petugas.dart';
import 'dart:developer' as developer;

class Sipir extends Petugas {
  Sipir({
    required super.nip,
    required super.nama,
    required super.shift,
    required super.blokJaga,
    required super.statusTugas,
  }) : super(jabatan: 'Sipir');

  // Method khusus OOP untuk Sipir
  void updateAbsensiBlok(String blok) {
    developer.log('Sipir $nama memperbarui data absensi harian untuk $blok.');
  }

  void catatInsiden(String narapidana, String keterangan) {
    developer.log(
      'Sipir $nama mencatat insiden untuk $narapidana: $keterangan',
    );
  }
}
