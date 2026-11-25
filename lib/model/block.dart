// file: lib/model/block.dart
import 'sel.dart';

/// Class Blok merepresentasikan blok hunian di dalam penjara (Komposisi & Agregasi).
class Blok {
  final int? id;
  final String _kode;
  final String _tingkatKeamanan;
  final int kapasitasSel;
  final int maksPenghuni;
  final List<Sel> _daftarSel = [];

  Blok({
    this.id,
    required String kode,
    required String tingkatKeamanan,
    this.kapasitasSel = 8,
    this.maksPenghuni = 48,
  }) : _kode = kode,
       _tingkatKeamanan = tingkatKeamanan {
    buatDaftarSel(kapasitasSel);
  }

  String get kode => _kode;
  String get tingkatKeamanan => _tingkatKeamanan;
  List<Sel> get daftarSel => List.unmodifiable(_daftarSel);

  void tambahSel(Sel sel) {
    if (!_daftarSel.contains(sel)) _daftarSel.add(sel);
  }

  void buatDaftarSel(int jumlahSel, {int kapasitasPerSel = 6}) {
    _daftarSel.clear();
    if (_kode.isEmpty || jumlahSel <= 0) return;

    for (var i = 0; i < jumlahSel; i++) {
      final nomorSel = '$_kode-${(i + 1).toString().padLeft(2, '0')}';
      _daftarSel.add(Sel(nomor: nomorSel, kapasitas: kapasitasPerSel));
    }
  }

  List<Sel> selKosong() {
    return _daftarSel.where((sel) => !sel.isPenuh()).toList();
  }

  int totalKapasitasBlok() {
    final total = _daftarSel.fold(0, (jumlah, sel) => jumlah + sel.kapasitas);
    return total > 0 ? total : maksPenghuni;
  }

  int totalPenghuniBlok() =>
      _daftarSel.fold(0, (jumlah, sel) => jumlah + sel.penghuni.length);

  /// Konversi dari Map SQLite ke Objek Blok
  factory Blok.fromMap(Map<String, Object?> map) {
    return Blok(
      id: map['id'] as int?,
      kode: map['nama_blok']?.toString() ?? '',
      tingkatKeamanan: map['tingkat_keamanan']?.toString() ?? 'Menengah',
      kapasitasSel: int.tryParse(map['kapasitas_sel']?.toString() ?? '8') ?? 8,
      maksPenghuni:
          int.tryParse(map['maks_penghuni']?.toString() ?? '48') ?? 48,
    );
  }

  /// Konversi dari Objek Blok ke Map SQLite
  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'nama_blok': _kode,
      'kapasitas_sel': kapasitasSel,
      'maks_penghuni': maksPenghuni,
      'tingkat_keamanan': _tingkatKeamanan,
    };
  }
}
