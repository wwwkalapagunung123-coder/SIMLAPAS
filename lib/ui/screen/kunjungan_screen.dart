import 'package:flutter/material.dart';

/// Halaman Kunjungan Lapas
///
/// Mengelola jadwal harian kunjungan, identitas pengunjung dan narapidana tujuan,
/// serta pemantauan status sesi kunjungan secara terstruktur.
class KunjunganScreen extends StatelessWidget {
  const KunjunganScreen({super.key});

  static const Color _textDarkColor = Color(0xFF101828);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header & Tombol Cetak
          _buildHeader(),
          const SizedBox(height: 24),

          // 2. Daftar Jadwal Kunjungan Hari Ini
          Expanded(child: _buildScheduleContainer()),
        ],
      ),
    );
  }

  // ==========================================
  // SUB-KOMPONEN UI
  // ==========================================

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SIMLAPAS / Kunjungan',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            SizedBox(height: 4),
            Text(
              'Kunjungan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _textDarkColor,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Kelola jadwal harian, data pengunjung, dan ketersediaan sesi kunjungan.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.print, size: 16),
          label: const Text('Cetak jadwal'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: _textDarkColor,
            side: BorderSide(color: Colors.grey[300]!),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Jadwal Hari Ini (Senin, 12 Oktober 2026)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 16),
          _buildKunjunganRow(
            pengunjung: 'Sari Lestari',
            hubungan: 'Istri',
            napi: 'Arif Setiawan (REG-2024-0018)',
            waktu: '10.00 - 10.30',
            status: 'Terjadwal',
            bgColor: Colors.amber[50]!,
            textColor: Colors.amber[800]!,
          ),
          _buildKunjunganRow(
            pengunjung: 'Dewi Santoso',
            hubungan: 'Istri',
            napi: 'Bima Santoso (REG-2023-0041)',
            waktu: '08.00 - 08.30',
            status: 'Selesai',
            bgColor: Colors.grey[100]!,
            textColor: Colors.grey[700]!,
          ),
          _buildKunjunganRow(
            pengunjung: 'Lina Nugraha',
            hubungan: 'Ibu',
            napi: 'Fajar Nugraha (REG-2025-0007)',
            waktu: '09.20 - 10.00',
            status: 'Berlangsung',
            bgColor: Colors.teal[50]!,
            textColor: Colors.teal[800]!,
          ),
        ],
      ),
    );
  }

  Widget _buildKunjunganRow({
    required String pengunjung,
    required String hubungan,
    required String napi,
    required String waktu,
    required String status,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
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
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
