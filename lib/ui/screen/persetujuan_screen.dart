import 'package:flutter/material.dart';

class PersetujuanScreen extends StatelessWidget {
  const PersetujuanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Halaman Persetujuan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SIMLAPAS / Persetujuan',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Persetujuan Kepala Lapas',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF101828),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tinjau usulan remisi dan pembebasan. Keputusan hanya dilakukan oleh Kepala Lapas.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24),

          // Tab Kategori Usulan
          Row(
            children: [
              _buildTabButton('Remisi (3)', true),
              SizedBox(width: 12),
              _buildTabButton('Pembebasan (2)', false),
              SizedBox(width: 12),
              _buildTabButton('Riwayat keputusan', false),
            ],
          ),
          SizedBox(height: 16),

          // Konten Utama: Daftar Usulan & Panel Tinjauan Detail
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kolom Kiri: Daftar Usulan
                Expanded(
                  flex: 2,
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
                          'Usulan remisi',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 12),
                        _buildUsulanCard(
                          'Arif Setiawan',
                          'REG-2024-0018',
                          '30 hari',
                          'Perlu ditinjau',
                          true,
                        ),
                        _buildUsulanCard(
                          'Rizky Saputra',
                          'REG-2024-0026',
                          '15 hari',
                          'Perlu ditinjau',
                          false,
                        ),
                        _buildUsulanCard(
                          'Hendra Wijaya',
                          'REG-2024-0045',
                          '20 hari',
                          'Perlu ditinjau',
                          false,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16),

                // Kolom Kanan: Panel Detail & Tombol Keputusan (OOP KepalaLapas)
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: EdgeInsets.all(20),
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
                              'Tinjauan usulan remisi',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'RM-2026-0108',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Arif Setiawan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'REG-2024-0018 · Blok A / A-03',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        Divider(height: 24),

                        // Perbandingan Sasa Tahanan
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildInfoVonisBox(
                              'Remisi diusulkan',
                              '30 hari',
                              Colors.teal[50]!,
                              Colors.teal[800]!,
                            ),
                            _buildInfoVonisBox(
                              'Sisa saat ini',
                              '185 hari',
                              Colors.grey[100]!,
                              Colors.grey[800]!,
                            ),
                            _buildInfoVonisBox(
                              'Sisa jika disetujui',
                              '155 hari',
                              Colors.blue[50]!,
                              Colors.blue[800]!,
                            ),
                          ],
                        ),
                        Spacer(),

                        // Tombol Aksi Persetujuan (Eksekusi Method OOP)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                // Eksekusi logika tolak usulan
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: Text('Tolak'),
                            ),
                            SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () {
                                // Di sinilah method OOP dipanggil, contoh:
                                // kepalaLapas.setujuiRemisi(napiArif, 30);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF0F766E),
                                foregroundColor: Colors.white,
                              ),
                              child: Text('✓ Setujui remisi'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Color(0xFF0F766E) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? Color(0xFF0F766E) : Colors.grey[400]!,
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.grey[700],
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildUsulanCard(
    String name,
    String reg,
    String detail,
    String status,
    bool isSelected,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.teal[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Color(0xFF0F766E) : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                detail,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F766E),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(reg, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                status,
                style: TextStyle(
                  color: Colors.amber[800],
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.chevron_right, size: 16, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoVonisBox(
    String label,
    String value,
    Color bgColor,
    Color textColor,
  ) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
