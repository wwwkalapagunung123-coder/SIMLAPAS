import 'package:flutter/material.dart';

/// Halaman Persetujuan Kepala Lapas
///
/// Menampilkan daftar usulan remisi dan pembebasan bersyarat narapidana,
/// serta panel tinjauan detail untuk pengambilan keputusan oleh Kepala Lapas.
class PersetujuanScreen extends StatelessWidget {
  const PersetujuanScreen({super.key});

  // Konstanta Warna Tema Halaman
  static const Color _primaryColor = Color(0xFF0F766E);
  static const Color _textDarkColor = Color(0xFF101828);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header & Breadcrumb
          _buildHeader(),
          const SizedBox(height: 24),

          // 2. Tab Kategori Usulan
          _buildCategoryTabs(),
          const SizedBox(height: 16),

          // 3. Konten Utama: Daftar Usulan & Panel Detail
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildProposalList()),
                const SizedBox(width: 16),
                Expanded(flex: 3, child: _buildDetailReviewPanel()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SUB-KOMPONEN UI (Modular & Reusable)
  // ==========================================

  /// Header judul dan deskripsi halaman
  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SIMLAPAS / Persetujuan',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        SizedBox(height: 4),
        Text(
          'Persetujuan Kepala Lapas',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _textDarkColor,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Tinjau usulan remisi dan pembebasan. Keputusan hanya dilakukan oleh Kepala Lapas.',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }

  /// Pilihan tab kategori usulan
  Widget _buildCategoryTabs() {
    return Row(
      children: [
        _buildTabButton('Remisi (3)', true),
        const SizedBox(width: 12),
        _buildTabButton('Pembebasan (2)', false),
        const SizedBox(width: 12),
        _buildTabButton('Riwayat keputusan', false),
      ],
    );
  }

  /// Tombol tab individual
  Widget _buildTabButton(String title, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? _primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isActive ? _primaryColor : Colors.grey[400]!),
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

  /// Kolom Kiri: Daftar kartu usulan remisi
  Widget _buildProposalList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Usulan remisi',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          _buildUsulanCard(
            name: 'Arif Setiawan',
            reg: 'REG-2024-0018',
            detail: '30 hari',
            status: 'Perlu ditinjau',
            isSelected: true,
          ),
          _buildUsulanCard(
            name: 'Rizky Saputra',
            reg: 'REG-2024-0026',
            detail: '15 hari',
            status: 'Perlu ditinjau',
            isSelected: false,
          ),
          _buildUsulanCard(
            name: 'Hendra Wijaya',
            reg: 'REG-2024-0045',
            detail: '20 hari',
            status: 'Perlu ditinjau',
            isSelected: false,
          ),
        ],
      ),
    );
  }

  /// Kartu usulan narapidana
  Widget _buildUsulanCard({
    required String name,
    required String reg,
    required String detail,
    required String status,
    required bool isSelected,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.teal[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? _primaryColor : Colors.transparent,
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
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                detail,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(reg, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 8),
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
              const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  /// Kolom Kanan: Panel tinjauan detail dan tombol keputusan
  Widget _buildDetailReviewPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Tinjauan & Nomor Registrasi Usulan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tinjauan usulan remisi',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                'RM-2026-0108',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Profil Narapidana yang Ditinjau
          const Text(
            'Arif Setiawan',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            'REG-2024-0018 · Blok A / A-03',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const Divider(height: 24),

          // Perbandingan Masa Tahanan
          _buildSentenceComparison(),
          const Spacer(),

          // Tombol Keputusan (Tolak / Setujui)
          _buildActionButtons(),
        ],
      ),
    );
  }

  /// Kotak perbandingan masa tahanan sebelum dan sesudah remisi
  Widget _buildSentenceComparison() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildInfoVonisBox(
          label: 'Remisi diusulkan',
          value: '30 hari',
          bgColor: Colors.teal[50]!,
          textColor: Colors.teal[800]!,
        ),
        _buildInfoVonisBox(
          label: 'Sisa saat ini',
          value: '185 hari',
          bgColor: Colors.grey[100]!,
          textColor: Colors.grey[800]!,
        ),
        _buildInfoVonisBox(
          label: 'Sisa jika disetujui',
          value: '155 hari',
          bgColor: Colors.blue[50]!,
          textColor: Colors.blue[800]!,
        ),
      ],
    );
  }

  /// Tombol aksi keputusan Kepala Lapas
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () {
            // Logika tolak usulan remisi
          },
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Tolak'),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {
            // Logika setujui usulan remisi (contoh: kepalaLapas.setujuiRemisi(...))
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('✓ Setujui remisi'),
        ),
      ],
    );
  }

  /// Widget box statistik / info vonis
  Widget _buildInfoVonisBox({
    required String label,
    required String value,
    required Color bgColor,
    required Color textColor,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
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
            const SizedBox(height: 6),
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
