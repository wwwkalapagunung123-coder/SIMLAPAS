// file: lib/models/narapidana.dart
import 'orang.dart';
import 'sel.dart';
import 'vonis.dart';

class Narapidana extends Orang {
  final String noRegistrasi;
  String status; // Tahanan / Narapidana
  Sel? _sel;
  final List<Vonis> _daftarVonis = [];

  Narapidana({
    required String nik,
    required String nama,
    required DateTime tanggalLahir,
    required this.noRegistrasi,
    required this.status,
  }) : super(nik, nama, tanggalLahir);

  Sel? get sel => _sel;
  List<Vonis> get daftarVonis => _daftarVonis;

  void tambahVonis(Vonis vonis) {
    _daftarVonis.add(vonis);
  }

  void pindahSel(Sel selBaru) {
    _sel = selBaru;
  }

  int sisaMasaTahanan() {
    // Logika perhitungan sisa hari berdasarkan vonis
    int totalHari = 0;
    for (var v in _daftarVonis) {
      totalHari += v.lamaHukuman;
    }
    return totalHari;
  }

  @override
  String info() {
    return 'Napi: ${getNama()} [Reg: $noRegistrasi] - Status: $status';
  }
}
