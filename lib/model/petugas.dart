// Superclass Petugas (Mengandung atribut dasar petugas)
class Petugas {
  String nip;
  String nama;
  String jabatan;
  String shift;
  String blokJaga;
  String statusTugas;

  Petugas({
    required this.nip,
    required this.nama,
    required this.jabatan,
    required this.shift,
    required this.blokJaga,
    required this.statusTugas,
  });
}
