// file: lib/model/insiden.dart

/// Class Insiden merepresentasikan riwayat insiden / pelanggaran oleh narapidana.
class Insiden {
  final int? id;
  final String noReg;
  final String namaNapi;
  final String nipPetugas;
  final String keterangan;
  final String tanggal;

  Insiden({
    this.id,
    required this.noReg,
    required this.namaNapi,
    required this.nipPetugas,
    required this.keterangan,
    required this.tanggal,
  });

  factory Insiden.fromMap(Map<String, Object?> map) {
    return Insiden(
      id: map['id'] as int?,
      noReg: map['no_reg']?.toString() ?? '',
      namaNapi: map['nama_napi']?.toString() ?? '',
      nipPetugas: map['nip_petugas']?.toString() ?? '',
      keterangan: map['keterangan']?.toString() ?? '',
      tanggal: map['tanggal']?.toString() ?? '',
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'no_reg': noReg,
      'nama_napi': namaNapi,
      'nip_petugas': nipPetugas,
      'keterangan': keterangan,
      'tanggal': tanggal,
    };
  }
}
