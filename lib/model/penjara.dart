// file: lib/models/penjara.dart
import 'block.dart';
import 'narapidana.dart';
import 'laporan.dart';

class Penjara implements Laporan {
  String nama;
  final String alamat;
  final List<Blok> _daftarBlok = [];

  Penjara({required this.nama, required this.alamat});

  List<Blok> get daftarBlok => List.unmodifiable(_daftarBlok);

  void tambahBlok(Blok blok) {
    if (!_daftarBlok.contains(blok)) _daftarBlok.add(blok);
  }

  Narapidana? cariNarapidana(String noReg) {
    for (var blok in _daftarBlok) {
      for (var sel in blok.daftarSel) {
        for (var napi in sel.penghuni) {
          if (napi.noRegistrasi == noReg) return napi;
        }
      }
    }
    return null;
  }

  int totalPenghuni() => _daftarBlok
      .expand((blok) => blok.daftarSel)
      .fold(0, (total, sel) => total + sel.penghuni.length);

  @override
  String buatLaporan() {
    return 'Laporan Resmi Penjara $nama. Total Penghuni: ${totalPenghuni()} orang.';
  }
}
