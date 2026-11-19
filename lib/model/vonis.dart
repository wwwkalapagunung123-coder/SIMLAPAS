// file: lib/models/vonis.dart

class Vonis {
  String noPerkara;
  String jenisKejahatan;
  final int lamaHukuman; // dalam hari atau bulan
  final DateTime tanggalMulai;

  Vonis({
    required this.noPerkara,
    required this.jenisKejahatan,
    required this.lamaHukuman,
    required this.tanggalMulai,
  });

  // Menghitung perkiraan tanggal bebas berdasarkan lama hukuman
  DateTime tanggalBebas() {
    return tanggalMulai.add(Duration(days: lamaHukuman));
  }
}
