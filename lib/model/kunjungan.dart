// file: lib/models/kunjungan.dart

class Kunjungan {
  String namaPengunjung;
  String hubungan;
  DateTime waktu;

  Kunjungan({
    required this.namaPengunjung,
    required this.hubungan,
    required this.waktu,
  });

  // Metode untuk menjadwalkan ulang atau menetapkan waktu kunjungan
  bool jadwalkan(DateTime waktuBaru) {
    waktu = waktuBaru;
    return true;
  }
}
