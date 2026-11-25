import 'package:flutter/material.dart';
import '../../controllers/laporan_controller.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  final LaporanController _controller = LaporanController();
  String? _hasilLaporanPolimorfis;
  bool _isLoading = false;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _muatStatistikLaporan();
  }

  Future<void> _muatStatistikLaporan() async {
    final stats = await _controller.muatRingkasanLaporan();
    if (mounted) {
      setState(() {
        _stats = stats;
      });
    }
  }

  Future<void> _generateLaporan() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Pemanggilan method polimorfis dari Interface Laporan via Controller
      final laporan = await _controller.buatLaporanResmi();
      if (!mounted) return;
      setState(() {
        _hasilLaporanPolimorfis = laporan;
        _isLoading = false;
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF0F766E)),
              SizedBox(width: 8),
              Text('Laporan Resmi Berhasil Dibuat'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hasil eksekusi method polimorfis (Interface Laporan -> Penjara.buatLaporan()):',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  laporan,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat laporan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final penghuniAktif = '${_stats['totalNapiAktif'] ?? 0} orang';
    final kapasitas = '${_stats['totalKapasitas'] ?? 0} tempat';
    final okupansi = '${_stats['okupansiPersen'] ?? 0}%';
    final petugasBertugas = '${_stats['petugasBertugas'] ?? 0} / ${_stats['totalPetugas'] ?? 0}';

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
                    'SIMLAPAS / Laporan Lapas',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Laporan lapas',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF101828),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Data diolah riil dari SQLite via LaporanController & Interface Laporan.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _generateLaporan,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.download, size: 16),
                label: const Text('Buat laporan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F766E),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Area Pratinjau Laporan
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
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
                      const Text(
                        'LAPAS KELAS IIA SURYATAMA',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.teal[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _hasilLaporanPolimorfis != null ? 'Laporan Terkini' : 'Siap unduh',
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
                    'Jl. Pemasyarakatan No. 1, Suryatama, Jawa Tengah 50200',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const Divider(height: 32),
                  const Text(
                    'Laporan Operasional Lapas (Interface Laporan)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    'Tanggal: ${DateTime.now().toLocal().toString().substring(0, 10)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 24),

                  if (_hasilLaporanPolimorfis != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.teal[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF0F766E).withAlpha(80)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ringkasan Polimorfisme (Penjara.buatLaporan()):',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F766E)),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _hasilLaporanPolimorfis!,
                            style: const TextStyle(fontSize: 14, color: Color(0xFF101828)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Ringkasan Data Riil dalam Laporan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildLaporanInfoBox('Penghuni aktif (DB)', penghuniAktif),
                      _buildLaporanInfoBox('Kapasitas Total', kapasitas),
                      _buildLaporanInfoBox('Tingkat Okupansi', okupansi),
                      _buildLaporanInfoBox('Petugas bertugas', petugasBertugas),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Penanggung jawab laporan:\nMaya Pramesti, Bc.IP., S.H. · Kepala Lapas',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      Text(
                        'Sumber Data: SQLite (Clean MVC Architecture)',
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
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Color(0xFF101828),
          ),
        ),
      ],
    );
  }
}
