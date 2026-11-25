// file: lib/model/petugas.dart
import 'orang.dart';
import 'sipir.dart';
import 'kepala_sipir.dart';

/// Abstract Class Petugas mewarisi (Inheritance) kelas Orang.
/// Memenuhi pilar Inheritance dan Abstraction.
abstract class Petugas extends Orang {
  final int? id;
  final String _nip;
  final String _jabatan;
  final double _gaji;
  String _shift;
  String _blokJaga;
  String? _selJaga;
  String _statusTugas;

  Petugas({
    this.id,
    required String nip,
    required String nama,
    required String jabatan,
    double gaji = 0.0,
    required String shift,
    String blokJaga = '-',
    String? selJaga,
    String statusTugas = 'Tidak Bertugas',
    String? nik,
    DateTime? tanggalLahir,
  })  : _nip = nip,
        _jabatan = jabatan,
        _gaji = gaji,
        _shift = shift,
        _blokJaga = blokJaga,
        _selJaga = selJaga,
        _statusTugas = statusTugas,
        super(
          nik ?? nip,
          nama,
          tanggalLahir ?? DateTime(1985, 1, 1),
        );

  String get nip => _nip;
  String get jabatan => _jabatan;
  double get gaji => _gaji;
  String get shift => _shift;
  String get blokJaga => _blokJaga;
  String? get selJaga => _selJaga;
  String get statusTugas => _statusTugas;

  set shift(String nilai) => _shift = nilai;
  set statusTugas(String nilai) => _statusTugas = nilai;

  String getNip() => _nip;

  @override
  String info() => 'Petugas: $nama (NIP: $_nip) - Jabatan: $_jabatan';

  bool get isBertugas =>
      _blokJaga.trim().isNotEmpty && _blokJaga.trim() != '-';

  String get labelPenugasan {
    if (!isBertugas) return '-';
    if (_selJaga != null && _selJaga!.trim().isNotEmpty) {
      return '$_blokJaga / $_selJaga';
    }
    return _blokJaga;
  }

  void aturPenugasan({String? blok, String? sel}) {
    if (blok == null || blok.trim().isEmpty || blok.trim() == '-') {
      _blokJaga = '-';
      _selJaga = null;
      _statusTugas = 'Tidak Bertugas';
      return;
    }

    _blokJaga = blok.trim();
    _selJaga = (sel != null && sel.trim().isNotEmpty) ? sel.trim() : null;
    _statusTugas = 'Bertugas';
  }

  /// Method polimorfis yang WAJIB diimplementasikan oleh subclass (Sipir & KepalaLapas)
  void lakukanTugas();

  /// Deskripsi tugas spesifik sesuai peran
  String getDeskripsiTugas();

  /// Factory pattern untuk membuat instance konkret (Sipir / KepalaLapas) dari data SQLite Map
  factory Petugas.fromMap(Map<String, Object?> map) {
    final role = map['role']?.toString() ?? 'Sipir';
    final id = map['id'] as int?;
    final nip = map['nip']?.toString() ?? '';
    final nama = map['nama']?.toString() ?? '';
    final blok = map['blok']?.toString() ?? '-';

    String blokJaga = '-';
    String? selJaga;
    if (blok.contains(' / ')) {
      final parts = blok.split(' / ');
      blokJaga = parts[0].trim();
      selJaga = parts[1].trim();
    } else if (blok.isNotEmpty && blok != 'Tidak Bertugas') {
      blokJaga = blok.trim();
    }

    final statusTugas = (blokJaga != '-' && blokJaga.isNotEmpty)
        ? 'Bertugas'
        : 'Tidak Bertugas';

    if (role == 'Kepala Lapas') {
      return KepalaLapas(
        id: id,
        nip: nip,
        nama: nama,
        periodeJabatan: '2024-2029',
        unitKerja: 'Lapas Kelas IIA Suryatama',
        shift: 'Reguler',
        blokJaga: blokJaga,
        selJaga: selJaga,
        statusTugas: statusTugas,
      );
    } else {
      return Sipir(
        id: id,
        nip: nip,
        nama: nama,
        shift: 'Pagi',
        blokJaga: blokJaga,
        selJaga: selJaga,
        statusTugas: statusTugas,
      );
    }
  }

  Map<String, Object?> toMap({String? password}) {
    return {
      if (id != null) 'id': id,
      'nama': nama,
      'nip': nip,
      'role': jabatan,
      'blok': labelPenugasan,
      if (password != null) 'password': password,
    };
  }
}
