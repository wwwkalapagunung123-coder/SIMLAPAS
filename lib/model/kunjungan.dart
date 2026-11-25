// file: lib/model/kunjungan.dart

/// Class Kunjungan merepresentasikan sesi kunjungan warga binaan ke Lapas.
class Kunjungan {
  final int? id;
  String namaPengunjung;
  String hubungan;
  String noRegNarapidana;
  String namaNarapidana;
  String waktu;
  String status; // 'Terjadwal', 'Berlangsung', 'Selesai'

  Kunjungan({
    this.id,
    required this.namaPengunjung,
    required this.hubungan,
    required this.noRegNarapidana,
    required this.namaNarapidana,
    required this.waktu,
    this.status = 'Terjadwal',
  });

  bool jadwalkan(String waktuBaru) {
    waktu = waktuBaru;
    return true;
  }

  void selesaikan() {
    status = 'Selesai';
  }

  void mulai() {
    status = 'Berlangsung';
  }

  String info() =>
      'Kunjungan: $namaPengunjung ($hubungan) menjenguk $namaNarapidana [$status] pada $waktu';

  factory Kunjungan.fromMap(Map<String, Object?> map) {
    return Kunjungan(
      id: map['id'] as int?,
      namaPengunjung: map['nama_pengunjung']?.toString() ?? '',
      hubungan: map['hubungan']?.toString() ?? '',
      noRegNarapidana: map['no_reg_napi']?.toString() ?? '',
      namaNarapidana: map['nama_napi']?.toString() ?? '',
      waktu: map['waktu']?.toString() ?? '',
      status: map['status']?.toString() ?? 'Terjadwal',
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'nama_pengunjung': namaPengunjung,
      'hubungan': hubungan,
      'no_reg_napi': noRegNarapidana,
      'nama_napi': namaNarapidana,
      'waktu': waktu,
      'status': status,
    };
  }
}
