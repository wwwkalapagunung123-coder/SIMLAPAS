import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
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
                  Expanded(child: _buildActivityPanel()),
                  const SizedBox(width: 20),
                  Expanded(child: _buildStatusPanel()),
                ],
              )
            : Column(
                children: [
                  _buildActivityPanel(),
                  const SizedBox(height: 16),
                  _buildStatusPanel(),
                ],
              );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
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
                'Pantau kondisi lapas, jumlah narapidana, kunjungan, dan persetujuan hari ini.',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
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
                      value: '144',
                      subtitle: 'Orang aktif dalam pembinaan',
                      icon: Icons.people,
                      color: Colors.teal,
                      onTap: () => onNavigate(1),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _buildInteractiveCard(
                      title: 'Kunjungan Hari Ini',
                      value: '12',
                      subtitle: 'Jadwal kunjungan hari ini',
                      icon: Icons.calendar_today,
                      color: Colors.blue,
                      onTap: () => onNavigate(5),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _buildInteractiveCard(
                      title: 'Persetujuan',
                      value: '5',
                      subtitle: 'Menunggu validasi Kalapas',
                      icon: Icons.check_circle_outline,
                      color: Colors.orange,
                      onTap: () => onNavigate(6),
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
  }

  Widget _buildActivityPanel() {
    return _panel(
      title: 'Aktivitas Lapas',
      child: Column(
        children: [
          _buildActivityRow(
            label: 'Pemeriksaan harian',
            value: '86%',
            color: const Color(0xFF0F766E),
          ),
          const SizedBox(height: 20),
          _buildActivityRow(
            label: 'Kegiatan pembinaan',
            value: '74%',
            color: const Color(0xFF2563EB),
          ),
          const SizedBox(height: 20),
          _buildActivityRow(
            label: 'Pemulangan berkas',
            value: '63%',
            color: const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPanel() {
    return _panel(
      title: 'Status terkini',
      child: Column(
        children: [
          _buildStatusItem('Petugas aktif', '28 orang', Colors.green),
          const SizedBox(height: 16),
          _buildStatusItem('Blok tersedia', '7 sel', Colors.blue),
          const SizedBox(height: 16),
          _buildStatusItem('Tunggu persetujuan', '5 item', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildShortcutsPanel() {
    return _panel(
      title: 'Aktivitas & Pintasan Sistem',
      child: Text(
        'Pilih kartu statistik di atas untuk membuka pengelolaan data terkait.',
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
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: _parseProgress(value),
            backgroundColor: Colors.grey[200],
            color: color,
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  double _parseProgress(String value) {
    final numericValue = value.replaceAll('%', '');
    return ((double.tryParse(numericValue) ?? 0) / 100).clamp(0, 1);
  }

  Widget _buildStatusItem(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: Colors.grey[700], fontSize: 13),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF101828),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildInteractiveCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: color.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 14,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF101828),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
