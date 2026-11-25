import 'package:flutter/material.dart';

import '../../controllers/narapidana_controller.dart';
import '../../model/insiden.dart';
import '../../model/narapidana.dart';

class DetailNarapidanaScreen extends StatelessWidget {
  const DetailNarapidanaScreen({super.key, required this.narapidana});

  final Narapidana narapidana;

  @override
  Widget build(BuildContext context) {
    final controller = NarapidanaController();
    final nama = narapidana.nama;
    final noReg = narapidana.noRegistrasi;
    final blokSel = '${narapidana.blok} / ${narapidana.selNomor}';
    final tglMasuk = narapidana.tanggalMasuk.toIso8601String().substring(0, 10);
    final estimasiBebas = narapidana.estimasiBebas.toIso8601String().substring(
      0,
      10,
    );
    final status = narapidana.status;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Narapidana - $nama'),
        backgroundColor: const Color(0xFF0F766E),
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
                Expanded(
                  flex: compact ? 2 : 1,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: _panelDecoration(),
                    child: ListView(
                      children: [
                        const Text(
                          'Informasi Narapidana',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF101828),
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
                  ),
                ),
                SizedBox(width: compact ? 0 : 24, height: compact ? 16 : 0),
                Expanded(
                  flex: compact ? 3 : 2,
                  child: Container(
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
                            color: Color(0xFF101828),
                          ),
                        ),
                        const Divider(height: 24),
                        Expanded(
                          child: FutureBuilder<List<Insiden>>(
                            future: controller.muatInsiden(noReg),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
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
                                  child: Text(
                                    'Belum ada catatan insiden untuk narapidana ini.',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 13,
                                    ),
                                  ),
                                );
                              }
                              return ListView.builder(
                                itemCount: listInsiden.length,
                                itemBuilder: (context, index) {
                                  final insiden = listInsiden[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.red[100]!,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Wrap(
                                          spacing: 16,
                                          runSpacing: 4,
                                          children: [
                                            Text(
                                              'Tanggal: ${insiden.tanggal}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red[800],
                                              ),
                                            ),
                                            Text(
                                              'Petugas: ${insiden.nipPetugas}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          insiden.keterangan,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF101828),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF101828),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
