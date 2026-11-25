// file: lib/model/narapidana.dart
import 'orang.dart';
import 'sel.dart';
import 'vonis.dart';

/// Class Narapidana mewarisi (Inheritance) kelas Orang.
class Narapidana extends Orang {
  final int? id;
  final String noRegistrasi;
  String status; // 'Aktif', 'Bebas', 'Tahanan', 'Narapidana'
  String blok;
  String selNomor;
  final DateTime tanggalMasuk;
  DateTime estimasiBebas;
  Sel? _sel;
  final List<Vonis> _daftarVonis = [];

  Narapidana({
    this.id,
    required String nik,
    required String nama,
    DateTime? tanggalLahir,
    required this.noRegistrasi,
    required this.status,
    this.blok = 'Blok A',
    this.selNomor = 'A-01',
    DateTime? tanggalMasuk,
    DateTime? estimasiBebas,
    Sel? sel,
  }) : tanggalMasuk = tanggalMasuk ?? DateTime.now(),
       estimasiBebas = estimasiBebas ?? DateTime(2028, 1, 1),
       super(nik, nama, tanggalLahir ?? DateTime(1990, 1, 1)) {
    if (sel != null) sel.masukkan(this);
  }

  Sel? get sel => _sel;
  List<Vonis> get daftarVonis => List.unmodifiable(_daftarVonis);

  void tambahVonis(Vonis vonis) {
    _daftarVonis.add(vonis);
  }

  bool pindahSel(Sel selBaru) => selBaru.masukkan(this);

  /// Dipanggil oleh Sel saat relasi penghuni berubah.
  void perbaruiSel(Sel? sel) {
    _sel = sel;
    selNomor = sel?.nomor ?? '';
  }

  int sisaMasaTahanan() {
    final totalHari = _daftarVonis.fold(
      0,
      (total, vonis) => total + vonis.lamaHukuman,
    );
    if (totalHari == 0) {
      // Hitung selisih dari tanggal hari ini ke estimasi bebas
      final diff = estimasiBebas.difference(DateTime.now()).inDays;
      return diff > 0 ? diff : 0;
    }
    return totalHari;
  }

  /// Memotong masa tahanan (remisi)
  void potongMasaTahanan(int hari) {
    if (hari <= 0) return;
    estimasiBebas = estimasiBebas.subtract(Duration(days: hari));
  }

  @override
  String info() {
    return 'Napi: ${getNama()} [Reg: $noRegistrasi] - Blok/Sel: $blok/$selNomor - Status: $status';
  }

  /// Konversi dari Map SQLite ke Objek Narapidana
  factory Narapidana.fromMap(Map<String, Object?> map) {
    final tglMasukStr = map['tanggal_masuk']?.toString();
    final tglBebasStr = map['estimasi_bebas']?.toString();

    DateTime tglMasuk;
    try {
      tglMasuk = tglMasukStr != null
          ? DateTime.parse(tglMasukStr)
          : DateTime.now();
    } catch (_) {
      tglMasuk = DateTime.now();
    }

    DateTime tglBebas;
    try {
      tglBebas = tglBebasStr != null
          ? DateTime.parse(tglBebasStr)
          : DateTime(2028, 1, 1);
    } catch (_) {
      tglBebas = DateTime(2028, 1, 1);
    }

    return Narapidana(
      id: map['id'] as int?,
      nik: map['no_reg']?.toString() ?? '-',
      nama: map['nama']?.toString() ?? '',
      noRegistrasi: map['no_reg']?.toString() ?? '',
      status: map['status']?.toString() ?? 'Aktif',
      blok: map['blok']?.toString() ?? 'Blok A',
      selNomor: map['sel']?.toString() ?? 'A-01',
      tanggalMasuk: tglMasuk,
      estimasiBebas: tglBebas,
    );
  }

  /// Konversi dari Objek Narapidana ke Map SQLite
  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'no_reg': noRegistrasi,
      'nama': nama,
      'blok': blok,
      'sel': selNomor,
      'tanggal_masuk': tanggalMasuk.toIso8601String().substring(0, 10),
      'estimasi_bebas': estimasiBebas.toIso8601String().substring(0, 10),
      'status': status,
    };
  }
}
