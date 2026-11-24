import 'package:flutter/material.dart';
import '../../helpers/database_helper.dart';

class BlokSelScreen extends StatefulWidget {
  const BlokSelScreen({super.key});

  @override
  State<BlokSelScreen> createState() => _BlokSelScreenState();
}

class _BlokSelScreenState extends State<BlokSelScreen> {
  String? selectedBlok;

  // Controller untuk form Tambah Blok
  final _namaBlokController = TextEditingController();
  final _kapasitasSelController = TextEditingController();
  final _maksPenghuniController = TextEditingController();
  String _keamananPilihan = 'Menengah';

  @override
  void dispose() {
    _namaBlokController.dispose();
    _kapasitasSelController.dispose();
    _maksPenghuniController.dispose();
    super.dispose();
  }

  // Fungsi memunculkan Dialog Tambah Blok
  void _tampilkanDialogTambahBlok(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Blok Penjara Baru'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _namaBlokController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Blok (Contoh: Blok E)',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _kapasitasSelController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Jumlah Sel (Contoh: 8)',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _maksPenghuniController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Maksimal Kapasitas Napi (Contoh: 48)',
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _keamananPilihan,
                  decoration: const InputDecoration(
                    labelText: 'Tingkat Keamanan',
                  ),
                  items: ['Rendah', 'Menengah', 'Tinggi']
                      .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _keamananPilihan = val!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (_namaBlokController.text.trim().isEmpty ||
                    _maksPenghuniController.text.trim().isEmpty) {
                  return;
                }

                final kapasitasSel = int.tryParse(
                  _kapasitasSelController.text.trim().isEmpty
                      ? '8'
                      : _kapasitasSelController.text.trim(),
                );
                final maksPenghuni = int.tryParse(
                  _maksPenghuniController.text.trim(),
                );
                if (kapasitasSel == null ||
                    kapasitasSel <= 0 ||
                    maksPenghuni == null ||
                    maksPenghuni <= 0) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Kapasitas harus berupa angka positif.'),
                    ),
                  );
                  return;
                }

                final row = <String, Object?>{
                  'nama_blok': _namaBlokController.text.trim(),
                  'kapasitas_sel': kapasitasSel,
                  'maks_penghuni': maksPenghuni,
                  'tingkat_keamanan': _keamananPilihan,
                };

                try {
                  await DatabaseHelper.instance.insertBlok(row);
                } catch (error, stackTrace) {
                  debugPrint('Gagal menyimpan blok: $error\n$stackTrace');
                  if (!mounted || !context.mounted) return;
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Gagal menyimpan data blok.')),
                  );
                  return;
                }

                if (!mounted || !context.mounted) return;
                _namaBlokController.clear();
                _kapasitasSelController.clear();
                _maksPenghuniController.clear();

                Navigator.pop(context);
                setState(() {});

                messenger.showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Berhasil menambahkan blok baru ke database!',
                    ),
                  ),
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header & Tombol Tambah Blok
          _buildHeader(context),
          const SizedBox(height: 24),

          // 2. Daftar Blok Horisontal
          SizedBox(height: 170, child: _buildBlockList()),
          const SizedBox(height: 24),

          // 3. Daftar Penghuni di Blok Terpilih
          const Text(
            'Daftar Penghuni di Blok Terpilih (Beserta Penempatan Sel)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Expanded(child: _buildResidentSection()),
        ],
      ),
    );
  }

  // ==========================================
  // SUB-KOMPONEN UI
  // ==========================================

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SIMLAPAS / Blok & Sel',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 4),
              const Text(
                'Blok & sel',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF101828),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pantau penempatan, kapasitas sel, dan narapidana di setiap blok.',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _tampilkanDialogTambahBlok(context),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Tambah blok'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F766E),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildBlockList() {
    return FutureBuilder<List<Map<String, Object?>>>(
      future: DatabaseHelper.instance.getAllBlok(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Gagal memuat daftar blok: ${snapshot.error}'),
          );
        }

        final listBlok = snapshot.data ?? [];
        if (listBlok.isEmpty) {
          return const Center(
            child: Text('Belum ada data blok. Klik "Tambah blok" di atas.'),
          );
        }

        if (selectedBlok == null && listBlok.isNotEmpty) {
          selectedBlok = listBlok[0]['nama_blok']?.toString();
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: listBlok.length,
          itemBuilder: (context, index) {
            final blok = listBlok[index];
            final namaBlok = blok['nama_blok']?.toString() ?? '';
            final maks = int.tryParse(blok['maks_penghuni'].toString()) ?? 48;
            final jmlSel = int.tryParse(blok['kapasitas_sel'].toString()) ?? 8;
            final keamanan = blok['tingkat_keamanan']?.toString() ?? 'Menengah';
            final isSelected = (selectedBlok == namaBlok);

            return _buildBlockCard(
              namaBlok: namaBlok,
              maks: maks,
              jmlSel: jmlSel,
              keamanan: keamanan,
              isSelected: isSelected,
            );
          },
        );
      },
    );
  }

  Widget _buildBlockCard({
    required String namaBlok,
    required int maks,
    required int jmlSel,
    required String keamanan,
    required bool isSelected,
  }) {
    return FutureBuilder<int>(
      future: DatabaseHelper.instance.getJumlahNapiByBlok(namaBlok),
      builder: (context, napiSnapshot) {
        final jumlahNapi = napiSnapshot.data ?? 0;
        final persentase = maks > 0 ? ((jumlahNapi / maks) * 100).round() : 0;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedBlok = namaBlok;
            });
          },
          child: Container(
            width: 220,
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFF0F766E) : Colors.grey[200]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      namaBlok,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '$persentase%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '$jumlahNapi / $maks Penghuni',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF101828),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$jmlSel sel · keamanan $keamanan',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResidentSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: selectedBlok == null
          ? const Center(child: Text('Pilih salah satu blok di atas.'))
          : FutureBuilder<List<Map<String, Object?>>>(
              future: DatabaseHelper.instance.getNarapidanaByBlok(
                selectedBlok!,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Gagal memuat penghuni blok: ${snapshot.error}',
                    ),
                  );
                }
                final listNapi = snapshot.data ?? [];
                if (listNapi.isEmpty) {
                  return Center(
                    child: Text(
                      'Belum ada narapidana yang ditempatkan di $selectedBlok.',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: listNapi.length,
                  itemBuilder: (context, index) {
                    final napi = listNapi[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                napi['nama']?.toString() ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                'No. Reg: ${napi['no_reg']}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.teal[50],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Sel: ${napi['sel']}',
                              style: TextStyle(
                                color: Colors.teal[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
