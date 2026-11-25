import 'package:flutter/material.dart';

import '../../controllers/blok_controller.dart';
import '../../helpers/database_helper.dart';

class BlokSelScreen extends StatefulWidget {
  const BlokSelScreen({super.key});

  @override
  State<BlokSelScreen> createState() => _BlokSelScreenState();
}

class _BlokSelScreenState extends State<BlokSelScreen> {
  final BlokController _blokController = BlokController();
  final _namaBlokController = TextEditingController();
  final _kapasitasSelController = TextEditingController();
  final _maksPenghuniController = TextEditingController();

  String? selectedBlok;
  String _keamananPilihan = 'Menengah';

  @override
  void dispose() {
    _namaBlokController.dispose();
    _kapasitasSelController.dispose();
    _maksPenghuniController.dispose();
    super.dispose();
  }

  Future<void> _tampilkanDialogTambahBlok(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
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
                      .map(
                        (keamanan) => DropdownMenuItem(
                          value: keamanan,
                          child: Text(keamanan),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _keamananPilihan = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final namaBlok = _namaBlokController.text.trim();
                final kapasitasText = _kapasitasSelController.text.trim();
                final maksText = _maksPenghuniController.text.trim();

                if (namaBlok.isEmpty || maksText.isEmpty) return;

                final kapasitasSel = int.tryParse(
                  kapasitasText.isEmpty ? '8' : kapasitasText,
                );
                final maksPenghuni = int.tryParse(maksText);

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

                try {
                  await _blokController.tambahBlokBaru(
                    namaBlok: namaBlok,
                    kapasitasSel: kapasitasSel,
                    maksPenghuni: maksPenghuni,
                    tingkatKeamanan: _keamananPilihan,
                  );
                } catch (error, stackTrace) {
                  debugPrint('Gagal menyimpan blok: $error\n$stackTrace');
                  if (!mounted || !dialogContext.mounted) return;
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Gagal menyimpan data blok.')),
                  );
                  return;
                }

                if (!mounted || !dialogContext.mounted) return;
                _namaBlokController.clear();
                _kapasitasSelController.clear();
                _maksPenghuniController.clear();
                Navigator.pop(dialogContext);
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          SizedBox(height: 170, child: _buildBlockList()),
          const SizedBox(height: 24),
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

        selectedBlok ??= listBlok.first['nama_blok']?.toString();

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: listBlok.length,
          itemBuilder: (context, index) {
            final blok = listBlok[index];
            final namaBlok = blok['nama_blok']?.toString() ?? '';
            final maks = int.tryParse(blok['maks_penghuni'].toString()) ?? 48;
            final jmlSel = int.tryParse(blok['kapasitas_sel'].toString()) ?? 8;
            final keamanan = blok['tingkat_keamanan']?.toString() ?? 'Menengah';
            final isSelected = selectedBlok == namaBlok;

            return FutureBuilder<int>(
              future: DatabaseHelper.instance.getJumlahNapiByBlok(namaBlok),
              builder: (context, napiSnapshot) {
                final jumlahNapi = napiSnapshot.data ?? 0;
                final persentase = maks > 0
                    ? ((jumlahNapi / maks) * 100).round()
                    : 0;

                return GestureDetector(
                  onTap: () => setState(() => selectedBlok = namaBlok),
                  child: Container(
                    width: 220,
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF0F766E)
                            : Colors.grey[200]!,
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
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
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
