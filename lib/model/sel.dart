// file: lib/models/sel.dart
import 'narapidana.dart';

class Sel {
  String nomor;
  final int kapasitas;
  final List<Narapidana> _penghuni = [];

  Sel({required this.nomor, required this.kapasitas});

  List<Narapidana> get penghuni => _penghuni;

  // Metode untuk mengecek apakah sel penuh
  bool isPenuh() {
    return _penghuni.length >= kapasitas;
  }

  // Metode memasukkan narapidana ke sel
  bool masukkan(Narapidana napi) {
    if (!isPenuh()) {
      _penghuni.add(napi);
      napi.pindahSel(this); // Mengubah referensi sel pada napi
      return true;
    }
    return false; // Gagal karena penuh
  }

  // Metode mengeluarkan narapidana dari sel
  void keluarkan(Narapidana napi) {
    _penghuni.remove(napi);
  }
}
