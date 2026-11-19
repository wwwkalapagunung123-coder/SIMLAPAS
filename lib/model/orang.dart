// file: lib/models/orang.dart
abstract class Orang {
  final String _nik;
  final String _nama;
  final DateTime _tanggalLahir;

  Orang(this._nik, this._nama, this._tanggalLahir);

  String get nama => _nama;
  String get nik => _nik;
  DateTime get tanggalLahir => _tanggalLahir;

  String getNama() => _nama;

  String info() {
    return 'Nama: $_nama, NIK: $_nik';
  }
}
