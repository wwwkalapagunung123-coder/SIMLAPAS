import 'package:flutter/material.dart';
import '../../controllers/persetujuan_controller.dart';
import '../../model/kepala_sipir.dart';
import '../../model/narapidana.dart';

class PersetujuanScreen extends StatefulWidget {
  const PersetujuanScreen({super.key});

  @override
  State<PersetujuanScreen> createState() => _PersetujuanScreenState();
}

class _PersetujuanScreenState extends State<PersetujuanScreen> {
  final PersetujuanController _controller = PersetujuanController();

  final KepalaLapas _kalapas = KepalaLapas(
    nip: '197508122000031001',
    nama: 'Maya Pramesti, Bc.IP., S.H.',
    periodeJabatan: '2024 - 2029',
    unitKerja: 'Lapas Kelas IIA Suryatama',
  );

  int _selectedTabIndex = 0;
  int _selectedNapiIndex = 0;
  List<Narapidana> _daftarNapi = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  Future<void> _muatData() async {
    setState(() => _isLoading = true);
    final data = await _controller.muatUsulanDariDatabase();
    if (mounted) {
      setState(() {
        _daftarNapi = data;
        _isLoading = false;
        if (_selectedNapiIndex >= data.length) {
          _selectedNapiIndex = 0;
        }
      });
    }
  }

  Future<void> _prosesSetujuiRemisi(Narapidana napi, int jumlahHari) async {
    final sukses = await _controller.setujuiRemisi(
      kalapas: _kalapas,
      napi: napi,
      jumlahHari: jumlahHari,
    );

    if (sukses && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✓ Remisi $jumlahHari hari untuk ${napi.nama} berhasil disetujui di database oleh Kepala Lapas (${_kalapas.nama})!',
          ),
          backgroundColor: const Color(0xFF0F766E),
        ),
      );
      _muatData();
    }
  }

  Future<void> _prosesSetujuiPembebasan(Narapidana napi) async {
    final sukses = await _controller.setujuiPembebasan(
      kalapas: _kalapas,
      napi: napi,
    );

    if (sukses && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✓ Pembebasan bersyarat ${napi.nama} berhasil disetujui dan diperbarui di database!',
          ),
          backgroundColor: Colors.blue[800],
        ),
      );
      _muatData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final usulanAktif =
        _daftarNapi.isNotEmpty && _selectedNapiIndex < _daftarNapi.length
        ? _daftarNapi[_selectedNapiIndex]
        : null;

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
                    'SIMLAPAS / Persetujuan',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Persetujuan Kepala Lapas',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF101828),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Data bersumber langsung dari database SQLite. Otoritas: ${_kalapas.nama}.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
              IconButton(
                onPressed: _muatData,
                icon: const Icon(Icons.refresh),
                tooltip: 'Segarkan data dari database',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tab Kategori Usulan
          Row(
            children: [
              _buildTabButton('Usulan Remisi (${_daftarNapi.length})', 0),
              const SizedBox(width: 12),
              _buildTabButton('Pembebasan Bersyarat', 1),
            ],
          ),
          const SizedBox(height: 16),

          // Konten Utama
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _daftarNapi.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada narapidana aktif di database yang memerlukan peninjauan.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kolom Kiri: Daftar Narapidana Riil dari Database
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _daftarNapi.length,
                            itemBuilder: (context, index) {
                              final napi = _daftarNapi[index];
                              final isSelected = index == _selectedNapiIndex;
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedNapiIndex = index;
                                  });
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.teal[50]
                                        : Colors.grey[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF0F766E)
                                          : Colors.transparent,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            napi.nama,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            napi.noRegistrasi,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${napi.blok} / ${napi.selNomor}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0F766E),
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            'Sisa: ${napi.sisaMasaTahanan()} hr',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Kolom Kanan: Detail & Eksekusi Method OOP
                      if (usulanAktif != null)
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Tinjauan Keputusan (OOP KepalaLapas)',
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
                                        usulanAktif.status,
                                        style: TextStyle(
                                          color: Colors.teal[800],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  usulanAktif.nama,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${usulanAktif.noRegistrasi} · ${usulanAktif.blok} / ${usulanAktif.selNomor}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                                const Divider(height: 24),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildInfoVonisBox(
                                      'Sisa Masa Tahanan',
                                      '${usulanAktif.sisaMasaTahanan()} hari',
                                      Colors.grey[100]!,
                                      Colors.grey[800]!,
                                    ),
                                    _buildInfoVonisBox(
                                      'Opsi Remisi',
                                      '30 hari',
                                      Colors.teal[50]!,
                                      Colors.teal[800]!,
                                    ),
                                    _buildInfoVonisBox(
                                      'Estimasi Bebas',
                                      usulanAktif.estimasiBebas
                                          .toIso8601String()
                                          .substring(0, 10),
                                      Colors.blue[50]!,
                                      Colors.blue[800]!,
                                    ),
                                  ],
                                ),
                                const Spacer(),

                                // Tombol Aksi Persetujuan (Eksekusi Method OOP)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () =>
                                          _prosesSetujuiPembebasan(usulanAktif),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.blue[800],
                                      ),
                                      child: const Text('Bebas bersyarat'),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton(
                                      onPressed: () =>
                                          _prosesSetujuiRemisi(usulanAktif, 30),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF0F766E,
                                        ),
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text(
                                        '✓ Setujui remisi (30 hr)',
                                      ),
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

  Widget _buildTabButton(String title, int index) {
    final isActive = _selectedTabIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0F766E) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? const Color(0xFF0F766E) : Colors.grey[400]!,
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
      ),
    );
  }

  Widget _buildInfoVonisBox(
    String title,
    String value,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: textColor, fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
