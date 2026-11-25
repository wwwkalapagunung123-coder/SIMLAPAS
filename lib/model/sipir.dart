// file: lib/model/sipir.dart
import 'dart:developer' as developer;
import 'block.dart';
import 'narapidana.dart';
import 'petugas.dart';

/// Subclass Sipir mewarisi Petugas
class Sipir extends Petugas {
  Blok? _blokObjek;

  Sipir({
    super.id,
    required super.nip,
    required super.nama,
    super.gaji = 4500000.0,
    required super.shift,
    super.blokJaga = '-',
    super.selJaga,
    super.statusTugas = 'Tidak Bertugas',
    Blok? blokObjek,
  })  : _blokObjek = blokObjek,
        super(jabatan: 'Sipir');

  Blok? get blokObjek => _blokObjek;

  void tetapkanBlokObjek(Blok? blok) {
    _blokObjek = blok;
    if (blok != null) {
      aturPenugasan(blok: blok.kode, sel: selJaga);
    }
  }

  @override
  void lakukanTugas() {
    developer.log('Sipir $nama sedang melaksanakan patroli keliling blok $blokJaga.');
  }

  @override
  String getDeskripsiTugas() =>
      'Menjaga keamanan, mengabsen warga binaan di $blokJaga, dan mencatat insiden.';

  List<Narapidana> absenNarapidana(Blok blok) {
    final hadir = <Narapidana>[];
    for (final sel in blok.daftarSel) {
      hadir.addAll(sel.penghuni);
    }
    developer.log(
      'Sipir $nama mengabsen ${hadir.length} narapidana di blok ${blok.kode}.',
    );
    return hadir;
  }

  void catatInsiden(Narapidana napi, String keterangan) {
    developer.log(
      'Sipir $nama mencatat insiden untuk ${napi.nama}: $keterangan',
    );
  }

  @override
  String info() =>
      'Sipir: $nama (NIP: $nip) - Shift: $shift - Penugasan: $labelPenugasan';
}
