import 'package:aplikasi_lapas/model/narapidana.dart';
import 'package:aplikasi_lapas/model/sel.dart';
import 'package:flutter_test/flutter_test.dart';

Narapidana _narapidana(String noReg) => Narapidana(
  nik: noReg,
  nama: 'Narapidana Uji',
  noRegistrasi: noReg,
  status: 'Aktif',
);

void main() {
  test('sel keeps its occupant list encapsulated', () {
    final sel = Sel(nomor: 'A-01', kapasitas: 2);

    expect(
      () => sel.penghuni.add(_narapidana('REG-1')),
      throwsUnsupportedError,
    );
  });

  test('moving a prisoner keeps both cell references in sync', () {
    final selLama = Sel(nomor: 'A-01', kapasitas: 2);
    final selBaru = Sel(nomor: 'A-02', kapasitas: 2);
    final napi = _narapidana('REG-1');

    expect(selLama.masukkan(napi), isTrue);
    expect(selBaru.masukkan(napi), isTrue);

    expect(selLama.penghuni, isEmpty);
    expect(selBaru.penghuni, contains(napi));
    expect(napi.sel, same(selBaru));
    expect(napi.selNomor, 'A-02');
  });

  test('a full target cell rejects a move without changing the old cell', () {
    final selLama = Sel(nomor: 'A-01', kapasitas: 2);
    final selPenuh = Sel(nomor: 'A-02', kapasitas: 1);
    final napi = _narapidana('REG-1');
    final penghuniSelPenuh = _narapidana('REG-2');

    expect(selLama.masukkan(napi), isTrue);
    expect(selPenuh.masukkan(penghuniSelPenuh), isTrue);

    expect(napi.pindahSel(selPenuh), isFalse);
    expect(selLama.penghuni, contains(napi));
    expect(napi.sel, same(selLama));
  });

  test('removing a prisoner clears its cell reference', () {
    final sel = Sel(nomor: 'A-01', kapasitas: 2);
    final napi = _narapidana('REG-1');
    sel.masukkan(napi);

    sel.keluarkan(napi);

    expect(sel.penghuni, isEmpty);
    expect(napi.sel, isNull);
    expect(napi.selNomor, isEmpty);
  });
}
