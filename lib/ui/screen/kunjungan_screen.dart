import 'package:flutter/material.dart';

class KunjunganScreen extends StatelessWidget {
  const KunjunganScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SIMLAPAS / Kunjungan',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Kunjungan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF101828),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Kelola jadwal harian, data pengunjung, dan ketersediaan sesi kunjungan.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.print, size: 16),
                label: Text('Cetak jadwal'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xFF101828),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Tabel Jadwal Kunjungan
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  Text(
                    'Jadwal Hari Ini (Senin, 12 Oktober 2026)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  SizedBox(height: 16),
                  _buildKunjunganRow(
                    'Sari Lestari',
                    'Istri',
                    'Arif Setiawan (REG-2024-0018)',
                    '10.00 - 10.30',
                    'Terjadwal',
                    Colors.amber[50]!,
                    Colors.amber[800]!,
                  ),
                  _buildKunjunganRow(
                    'Dewi Santoso',
                    'Istri',
                    'Bima Santoso (REG-2023-0041)',
                    '08.00 - 08.30',
                    'Selesai',
                    Colors.grey[100]!,
                    Colors.grey[700]!,
                  ),
                  _buildKunjunganRow(
                    'Lina Nugraha',
                    'Ibu',
                    'Fajar Nugraha (REG-2025-0007)',
                    '09.20 - 10.00',
                    'Berlangsung',
                    Colors.teal[50]!,
                    Colors.teal[800]!,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKunjunganRow(
    String pengunjung,
    String hubungan,
    String napi,
    String waktu,
    String status,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$pengunjung ($hubungan)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              SizedBox(height: 2),
              Text(
                'Tujuan: $napi',
                style: TextStyle(color: Colors.grey[600], fontSize: 11),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                waktu,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
