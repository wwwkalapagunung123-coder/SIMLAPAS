import 'package:flutter/material.dart';

class LaporanScreen extends StatelessWidget {
  const LaporanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SIMLAPAS / Laporan Lapas',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Laporan lapas',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF101828),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Susun laporan operasional dengan ringkasan yang dapat ditinjau sebelum diunduh.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.download, size: 16),
                label: Text('Buat laporan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0F766E),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Area Pratinjau Laporan
          Expanded(
            child: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'LAPAS KELAS IIA SURYATAMA',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.teal[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Siap unduh',
                          style: TextStyle(
                            color: Colors.teal[800],
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Jl. Dharma Bakti No. 12, Suryatama, Jawa Tengah 50200',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Divider(height: 32),
                  Text(
                    'Laporan Operasional Lapas',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    'Periode 01 - 12 Oktober 2026',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  SizedBox(height: 24),

                  // Ringkasan Data dalam Laporan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildLaporanInfoBox('Penghuni aktif', '144 orang'),
                      _buildLaporanInfoBox('Kapasitas', '192 tempat'),
                      _buildLaporanInfoBox('Okupansi', '75%'),
                      _buildLaporanInfoBox('Petugas bertugas', '18 / 36'),
                    ],
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Penanggung jawab laporan:\nMaya Pramesti · Kepala Lapas',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      Text(
                        'Dibuat: 12 Oktober 2026 · 09.42 WIB',
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLaporanInfoBox(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Color(0xFF101828),
          ),
        ),
      ],
    );
  }
}
