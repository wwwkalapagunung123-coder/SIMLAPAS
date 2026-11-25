// file: lib/models/sel.dart
import 'narapidana.dart';

class Sel {
  String nomor;
  final int kapasitas;
  final List<Narapidana> _penghuni = [];

  Sel({required this.nomor, required this.kapasitas});

  List<Narapidana> get penghuni => List.unmodifiable(_penghuni);

  bool isPenuh() => _penghuni.length >= kapasitas;

  bool masukkan(Narapidana napi) {
    if (_penghuni.contains(napi)) return true;
    if (isPenuh()) return false;

    napi.sel?.keluarkan(napi);
    _penghuni.add(napi);
    napi.perbaruiSel(this);
    return true;
  }

  void keluarkan(Narapidana napi) {
    _penghuni.remove(napi);
    if (identical(napi.sel, this)) napi.perbaruiSel(null);
  }
}
