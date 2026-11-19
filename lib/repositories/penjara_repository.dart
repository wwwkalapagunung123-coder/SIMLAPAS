import '../model/penjara.dart';
import '../model/block.dart';
import '../model/sel.dart';
import '../model/narapidana.dart';
import '../model/vonis.dart';

class PenjaraRepository {
  static Penjara getDummyData() {
    // 1. Inisialisasi Penjara Utama
    Penjara lapas = Penjara(
      nama: 'Lapas Kelas IIA Suryutama',
      alamat: 'Jl. Pemasyarakatan No. 1',
    );

    // 2. Buat Blok dan masukkan ke Penjara
    Blok blokA = Blok(kode: 'Blok A', tingkatKeamanan: 'Menengah');
    lapas.tambahBlok(blokA);

    // 3. Buat Sel di dalam Blok A
    Sel sel01 = Sel(nomor: '01', kapasitas: 6);
    blokA.tambahSel(sel01);

    // 4. Buat Narapidana dan Vonisnya
    Narapidana napi1 = Narapidana(
      nik: '3201123456780001',
      nama: 'Arif Setiawan',
      tanggalLahir: DateTime(1995, 5, 12),
      noRegistrasi: 'REG-2024-0018',
      status: 'Narapidana',
    );

    Vonis vonis1 = Vonis(
      noPerkara: 'PERKARA/2024/001',
      jenisKejahatan: 'Penggelapan',
      lamaHukuman: 365, // dalam hari
      tanggalMulai: DateTime(2024, 1, 1),
    );

    napi1.tambahVonis(vonis1);

    // Masukkan Napi ke Sel
    sel01.masukkan(napi1);

    return lapas;
  }
}
