import 'package:flutter/material.dart';

import '../../helpers/database_helper.dart';

/// Halaman Detail Narapidana
///
/// Menyajikan informasi lengkap data narapidana, penempatan blok/sel,
/// serta riwayat catatan pelanggaran atau insiden dari database.
class DetailNarapidanaScreen extends StatelessWidget {
  const DetailNarapidanaScreen({super.key, required this.narapidana});

  final Map<String, dynamic> narapidana;

  static const Color _primaryColor = Color(0xFF0F766E);
  static const Color _textDarkColor = Color(0xFF101828);

  @override
  Widget build(BuildContext context) {
    final nama = narapidana['nama']?.toString() ?? 'Tanpa Nama';
    final noReg = narapidana['no_reg']?.toString() ?? '-';
    final blokSel = '${narapidana['blok']} / ${narapidana['sel']}';
    final tglMasuk = narapidana['tanggal_masuk']?.toString() ?? '-';
    final estimasiBebas = narapidana['estimasi_bebas']?.toString() ?? '-';
    final status = narapidana['status']?.toString() ?? 'Aktif';

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Narapidana - $nama'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 800;
          return Padding(
            padding: EdgeInsets.all(compact ? 16 : 24),
            child: Flex(
              direction: compact ? Axis.vertical : Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Panel Informasi Pokok
                Expanded(
                  flex: compact ? 2 : 1,
                  child: _buildInfoPanel(
                    nama: nama,
                    noReg: noReg,
                    blokSel: blokSel,
                    tglMasuk: tglMasuk,
                    estimasiBebas: estimasiBebas,
                    status: status,
                  ),
                ),
                SizedBox(width: compact ? 0 : 24, height: compact ? 16 : 0),

                // 2. Panel Riwayat Insiden & Catatan Pelanggaran
                Expanded(
                  flex: compact ? 3 : 2,
                  child: _buildIncidentPanel(noReg),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // SUB-KOMPONEN UI
  // ==========================================

  Widget _buildInfoPanel({
    required String nama,
    required String noReg,
    required String blokSel,
    required String tglMasuk,
    required String estimasiBebas,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(),
      child: ListView(
        children: [
          const Text(
            'Informasi Narapidana',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: _textDarkColor,
            ),
          ),
          const Divider(height: 24),
          _buildInfoRow('No. Registrasi', noReg),
          _buildInfoRow('Nama Lengkap', nama),
          _buildInfoRow('Blok / Sel', blokSel),
          _buildInfoRow('Tanggal Masuk', tglMasuk),
          _buildInfoRow('Estimasi Bebas', estimasiBebas),
          _buildInfoRow('Status', status),
        ],
      ),
    );
  }

  Widget _buildIncidentPanel(String noReg) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Riwayat Insiden & Catatan Pelanggaran',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: _textDarkColor,
            ),
          ),
          const Divider(height: 24),
          Expanded(
            child: FutureBuilder<List<Map<String, Object?>>>(
              future: DatabaseHelper.instance.getInsidenByNapi(noReg),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Gagal memuat riwayat insiden: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                final listInsiden = snapshot.data ?? [];
                if (listInsiden.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 48,
                          color: Colors.teal[300],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Catatan Bersih',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                          ),
                        ),
                        Text(
                          'Tidak ada riwayat pelanggaran atau insiden tercatat.',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: listInsiden.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = listInsiden[index];
                    final tgl = item['tanggal']?.toString() ?? '-';
                    final ket = item['keterangan']?.toString() ?? '-';
                    final petugas = item['nip_petugas']?.toString() ?? '-';

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Colors.red[50],
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
                        ),
                      ),
                      title: Text(
                        ket,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Pencatat: NIP $petugas · Waktu: $tgl',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _panelDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[200]!),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: _textDarkColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
