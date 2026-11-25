// file: lib/model/orang.dart

/// Abstract Class Orang sebagai representasi entitas manusia dalam sistem.
/// Menerapkan prinsip Abstraction dan Encapsulation.
abstract class Orang {
  final String _nik;
  final String _nama;
  final DateTime _tanggalLahir;

  Orang(this._nik, this._nama, this._tanggalLahir);

  String get nik => _nik;
  String get nama => _nama;
  DateTime get tanggalLahir => _tanggalLahir;

  String getNama() => _nama;

  /// Method polimorfis untuk menampilkan informasi dasar objek
  String info() {
    return 'Nama: $_nama, NIK: $_nik';
  }
}
