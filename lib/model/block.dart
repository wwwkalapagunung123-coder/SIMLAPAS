// file: lib/models/blok.dart
import 'sel.dart';

class Blok {
  final String kode;
  final String tingkatKeamanan;
  final List<Sel> _daftarSel = [];

  Blok({required this.kode, required this.tingkatKeamanan});
  List<Sel> get daftarSel => _daftarSel;

  // Menambahkan sel ke dalam blok
  void tambahSel(Sel sel) {
    _daftarSel.add(sel);
  }

  // Mengembalikan daftar sel yang masih kosong
  List<Sel> selKosong() {
    return _daftarSel.where((sel) => !sel.isPenuh()).toList();
  }

  // Menghitung total kapasitas seluruh sel di blok ini
  int totalKapasitasBlok() {
    int total = 0;
    for (var sel in _daftarSel) {
      total += sel.kapasitas;
    }
    return total;
  }

  // Menghitung total penghuni saat ini di blok ini
  int totalPenghuniBlok() {
    int total = 0;
    for (var sel in _daftarSel) {
      total += sel.penghuni.length;
    }
    return total;
  }
}
