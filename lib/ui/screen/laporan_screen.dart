import 'package:flutter/material.dart';

/// Halaman Laporan Operasional Lapas
///
/// Menyajikan ringkasan statistik okupansi, jumlah penghuni, kapasitas sel,
/// dan kehadiran petugas dalam format pratinjau siap unduh/cetak.
class LaporanScreen extends StatelessWidget {
  const LaporanScreen({super.key});

  static const Color _primaryColor = Color(0xFF0F766E);
  static const Color _textDarkColor = Color(0xFF101828);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header & Tombol Buat Laporan
          _buildHeader(),
          const SizedBox(height: 24),

          // 2. Lembar Pratinjau Dokumen Laporan
          Expanded(child: _buildReportPreviewCard()),
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
              'SIMLAPAS / Laporan Lapas',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            SizedBox(height: 4),
            Text(
              'Laporan lapas',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _textDarkColor,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Susun laporan operasional dengan ringkasan yang dapat ditinjau sebelum diunduh.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download, size: 16),
          label: const Text('Buat laporan'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildReportPreviewCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInstitutionHeader(),
          const Divider(height: 32),
          const Text(
            'Laporan Operasional Lapas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(
            'Periode 01 - 12 Oktober 2026',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(height: 24),

          // Ringkasan 4 Metrik Operasional
          _buildMetricsRow(),
          const Spacer(),

          // Footer Dokumen & Penanggung Jawab
          _buildDocumentFooter(),
        ],
      ),
    );
  }

  Widget _buildInstitutionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'LAPAS KELAS IIA SURYATAMA',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              'Jl. Dharma Bakti No. 12, Suryatama, Jawa Tengah 50200',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
    );
  }

  Widget _buildMetricsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLaporanInfoBox('Penghuni aktif', '144 orang'),
        _buildLaporanInfoBox('Kapasitas', '192 tempat'),
        _buildLaporanInfoBox('Okupansi', '75%'),
        _buildLaporanInfoBox('Petugas bertugas', '18 / 36'),
      ],
    );
  }

  Widget _buildDocumentFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Penanggung jawab laporan:\nMaya Pramesti · Kepala Lapas',
          style: TextStyle(color: Colors.grey[700], fontSize: 12, height: 1.4),
        ),
        Text(
          'Dibuat: 12 Oktober 2026 · 09.42 WIB',
          style: TextStyle(color: Colors.grey[500], fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildLaporanInfoBox(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: _textDarkColor,
          ),
        ),
      ],
    );
  }
}
