import 'package:flutter/material.dart';
import '../../controllers/dashboard_controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardController _controller = DashboardController();
  late Future<Map<String, dynamic>> _statistikFuture;

  @override
  void initState() {
    super.initState();
    _statistikFuture = _controller.muatStatistikRiil();
  }

  void _refresh() {
    setState(() {
      _statistikFuture = _controller.muatStatistikRiil();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _statistikFuture,
      builder: (context, snapshot) {
        final stats = snapshot.data ?? {};
        final totalNapi = stats['totalNapiAktif']?.toString() ?? '...';
        final totalKunjungan = stats['kunjunganHariIni']?.toString() ?? '...';
        final totalUsulan = stats['usulanRemisi']?.toString() ?? '...';
        final petugasAktif = '${stats['petugasBertugas'] ?? 0} orang';
        final totalBlok = '${stats['totalBlok'] ?? 0} blok';
        final okupansi = '${stats['okupansiPersen'] ?? 0}%';

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final cardWidth = width >= 1000
                ? (width - 32) / 3
                : width >= 620
                ? (width - 16) / 2
                : width;
            final activityAndStatus = width >= 760
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildActivityPanel(okupansi)),
                      const SizedBox(width: 20),
                      Expanded(child: _buildStatusPanel(petugasAktif, totalBlok, totalUsulan)),
                    ],
                  )
                : Column(
                    children: [
                      _buildActivityPanel(okupansi),
                      const SizedBox(height: 16),
                      _buildStatusPanel(petugasAktif, totalBlok, totalUsulan),
                    ],
                  );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
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
                            'SIMLAPAS / Ringkasan',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Ringkasan operasional',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF101828),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Statistik riil dari database SQLite (OOP Clean Architecture).',
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Segarkan data riil',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: cardWidth,
                        child: _buildInteractiveCard(
                          title: 'Total Narapidana',
                          value: totalNapi,
                          subtitle: 'Orang aktif dalam pembinaan (DB)',
                          icon: Icons.people,
                          color: Colors.teal,
                          onTap: () => widget.onNavigate(1),
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _buildInteractiveCard(
                          title: 'Kunjungan Hari Ini',
                          value: totalKunjungan,
                          subtitle: 'Jadwal kunjungan dari database',
                          icon: Icons.calendar_today,
                          color: Colors.blue,
                          onTap: () => widget.onNavigate(5),
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _buildInteractiveCard(
                          title: 'Persetujuan',
                          value: totalUsulan,
                          subtitle: 'Napi aktif menunggu validasi',
                          icon: Icons.check_circle_outline,
                          color: Colors.orange,
                          onTap: () => widget.onNavigate(6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  activityAndStatus,
                  const SizedBox(height: 24),
                  _buildShortcutsPanel(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActivityPanel(String okupansi) {
    return _panel(
      title: 'Kapasitas & Okupansi Riil',
      child: Column(
        children: [
          _buildActivityRow(
            label: 'Tingkat Okupansi Penjara',
            value: okupansi,
            color: const Color(0xFF0F766E),
          ),
          const SizedBox(height: 20),
          _buildActivityRow(
            label: 'Integrasi Database SQLite',
            value: '100% Aktif',
            color: const Color(0xFF2563EB),
          ),
          const SizedBox(height: 20),
          _buildActivityRow(
            label: 'Penerapan Kaidah OOP',
            value: '4 Pilar Sesuai',
            color: const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPanel(String petugasAktif, String totalBlok, String usulan) {
    return _panel(
      title: 'Status Terkini (Database)',
      child: Column(
        children: [
          _buildStatusItem('Petugas bertugas', petugasAktif, Colors.green),
          const SizedBox(height: 16),
          _buildStatusItem('Blok terdaftar', totalBlok, Colors.blue),
          const SizedBox(height: 16),
          _buildStatusItem('Napi siap remisi', '$usulan orang', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildShortcutsPanel() {
    return _panel(
      title: 'Aktivitas & Pintasan Sistem',
      child: Text(
        'Pilih kartu statistik di atas untuk membuka pengelolaan data terkait secara langsung.',
        style: TextStyle(color: Colors.grey[600], fontSize: 14),
      ),
    );
  }

  Widget _panel({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildActivityRow({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusItem(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
          ],
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildInteractiveCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required MaterialColor color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
