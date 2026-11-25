// file: lib/repositories/penjara_repository.dart
import '../helpers/database_helper.dart';
import '../model/penjara.dart';
import '../model/block.dart';
import '../model/sel.dart';
import '../model/narapidana.dart';
import '../model/vonis.dart';

class PenjaraRepository {
  /// Membaca struktur lengkap objek Penjara dari SQLite secara dinamis
  static Future<Penjara> loadPenjaraFromDatabase({
    String nama = 'Lapas Kelas IIA Suryatama',
    String alamat = 'Jl. Pemasyarakatan No. 1, Suryatama',
  }) async {
    final lapas = Penjara(nama: nama, alamat: alamat);

    // 1. Ambil semua blok dari DB
    final listBlokMap = await DatabaseHelper.instance.getAllBlok();
    final listNapiMap = await DatabaseHelper.instance.getAllNarapidana();

    for (var bMap in listBlokMap) {
      final blok = Blok.fromMap(bMap);
      lapas.tambahBlok(blok);
    }

    // 2. Hubungkan napi ke sel masing-masing di dalam blok
    for (var nMap in listNapiMap) {
      final napi = Narapidana.fromMap(nMap);
      for (var blok in lapas.daftarBlok) {
        if (blok.kode == napi.blok) {
          // Cari atau tambahkan sel
          Sel? targetSel;
          for (var sel in blok.daftarSel) {
            if (sel.nomor == napi.selNomor) {
              targetSel = sel;
              break;
            }
          }
          if (targetSel == null) {
            targetSel = Sel(nomor: napi.selNomor, kapasitas: 6);
            blok.tambahSel(targetSel);
          }
          targetSel.masukkan(napi);
          break;
        }
      }
    }

    return lapas;
  }

  /// Menyediakan dummy data statis untuk pengujian cepat
  static Penjara getDummyData() {
    Penjara lapas = Penjara(
      nama: 'Lapas Kelas IIA Suryatama',
      alamat: 'Jl. Pemasyarakatan No. 1',
    );

    Blok blokA = Blok(kode: 'Blok A', tingkatKeamanan: 'Menengah');
    lapas.tambahBlok(blokA);

    Sel sel01 = Sel(nomor: 'Blok A-01', kapasitas: 6);
    blokA.tambahSel(sel01);

    Narapidana napi1 = Narapidana(
      nik: '3201123456780001',
      nama: 'Arif Setiawan',
      tanggalLahir: DateTime(1995, 5, 12),
      noRegistrasi: 'REG-2024-0018',
      status: 'Narapidana',
      blok: 'Blok A',
      selNomor: 'Blok A-01',
    );

    Vonis vonis1 = Vonis(
      noPerkara: 'PERKARA/2024/001',
      jenisKejahatan: 'Penggelapan',
      lamaHukuman: 365,
      tanggalMulai: DateTime(2024, 1, 1),
    );

    napi1.tambahVonis(vonis1);
    sel01.masukkan(napi1);

    return lapas;
  }
}
