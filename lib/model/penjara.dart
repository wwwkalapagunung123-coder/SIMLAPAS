// file: lib/models/penjara.dart
import 'block.dart';
import 'narapidana.dart';
import 'laporan.dart';

class Penjara implements Laporan {
  String nama;
  final String alamat;
  List<Blok> daftarBlok = [];

  Penjara({required this.nama, required this.alamat});

  void tambahBlok(Blok blok) {
    daftarBlok.add(blok);
  }

  Narapidana? cariNarapidana(String noReg) {
    for (var blok in daftarBlok) {
      for (var sel in blok.daftarSel) {
        for (var napi in sel.penghuni) {
          if (napi.noRegistrasi == noReg) return napi;
        }
      }
    }
    return null;
  }

  int totalPenghuni() {
    int total = 0;
    for (var blok in daftarBlok) {
      for (var sel in blok.daftarSel) {
        total += sel.penghuni.length;
      }
    }
    return total;
  }

  @override
  String buatLaporan() {
    return 'Laporan Resmi Penjara $nama. Total Penghuni: ${totalPenghuni()} orang.';
  }
}
