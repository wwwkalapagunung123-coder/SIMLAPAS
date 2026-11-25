import 'package:flutter/material.dart';
import '../../controllers/blok_controller.dart';
import '../../controllers/petugas_controller.dart';
import '../../model/block.dart';
import '../../model/petugas.dart';

class PetugasScreen extends StatefulWidget {
  const PetugasScreen({super.key});

  @override
  State<PetugasScreen> createState() => _PetugasScreenState();
}

class _PetugasScreenState extends State<PetugasScreen> {
  final PetugasController _petugasController = PetugasController();
  final BlokController _blokController = BlokController();
  // Fungsi Dialog Edit Penugasan (Mendukung: Tidak Bertugas, Blok Saja, atau Blok + Sel)
  void _tampilkanFormEditPetugas(BuildContext context, Petugas petugas) {
    final id = petugas.id ?? 0;
    final nama = petugas.nama;
    final nip = petugas.nip;
    final role = petugas.jabatan;
    String? selectedBlok = petugas.isBertugas ? petugas.blokJaga : null;
    String? selectedSel = petugas.selJaga;

    final listBlokFuture = _blokController.muatSemuaBlok();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Penugasan Jaga - $nama'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NIP: $nip · Jabatan: $role',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<List<Blok>>(
                        future: listBlokFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const LinearProgressIndicator();
                          }
                          if (snapshot.hasError) {
                            return Text(
                              'Gagal memuat database blok: ${snapshot.error}',
                            );
                          }

                          final listBlok = snapshot.data ?? [];

                          // Opsi pilihan blok ditambah opsi "-- Tidak Bertugas / Tanpa Blok --"
                          final blockOptions = listBlok
                              .map((b) => b.kode)
                              .where((name) => name.isNotEmpty)
                              .toList();

                          final selectedBlockData = listBlok
                              .where((b) => b.kode == selectedBlok)
                              .toList();

                          final kapasitasSel = selectedBlockData.isEmpty
                              ? 0
                              : selectedBlockData.first.kapasitasSel;

                          final selOptions = selectedBlockData.isEmpty
                              ? <String>[]
                              : List.generate(
                                  kapasitasSel,
                                  (index) =>
                                      '${selectedBlok!}-${(index + 1).toString().padLeft(2, '0')}',
                                );

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Pilih Blok Penugasan:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Dropdown Blok (Bisa dikosongkan / Tidak Bertugas)
                              DropdownButtonFormField<String?>(
                                initialValue:
                                    blockOptions.contains(selectedBlok)
                                    ? selectedBlok
                                    : null,
                                hint: const Text(
                                  '-- Tidak Bertugas (Tanpa Blok) --',
                                ),
                                isExpanded: true,
                                items: [
                                  const DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text(
                                      '-- Tidak Bertugas (Tanpa Blok) --',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                  ...blockOptions.map((namaBlok) {
                                    return DropdownMenuItem<String?>(
                                      value: namaBlok,
                                      child: Text(namaBlok),
                                    );
                                  }),
                                ],
                                onChanged: (val) {
                                  setDialogState(() {
                                    selectedBlok = val;
                                    selectedSel =
                                        null; // Reset sel jika blok diubah/dikosongkan
                                  });
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                              ),
                              const SizedBox(height: 16),

                              const Text(
                                'Pilih Sel Spesifik (Opsional):',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Dropdown Sel (Hanya aktif jika blok dipilih)
                              DropdownButtonFormField<String?>(
                                key: ValueKey('sel-petugas-$selectedBlok'),
                                initialValue: selOptions.contains(selectedSel)
                                    ? selectedSel
                                    : null,
                                hint: Text(
                                  selectedBlok == null
                                      ? 'Pilih blok terlebih dahulu'
                                      : '-- Jaga Seluruh Blok (Tanpa Sel Khusus) --',
                                ),
                                isExpanded: true,
                                items: [
                                  const DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text(
                                      '-- Jaga Seluruh Blok (Tanpa Sel Khusus) --',
                                    ),
                                  ),
                                  ...selOptions.map((sel) {
                                    return DropdownMenuItem<String?>(
                                      value: sel,
                                      child: Text('Sel $sel'),
                                    );
                                  }),
                                ],
                                onChanged: selectedBlok == null
                                    ? null
                                    : (val) {
                                        setDialogState(() {
                                          selectedSel = val;
                                        });
                                      },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
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
                    String penugasanTersimpan = '-';
                    if (selectedBlok != null) {
                      penugasanTersimpan = selectedSel != null
                          ? '$selectedBlok / $selectedSel'
                          : selectedBlok!;
                    }

                    await _petugasController.perbaruiPenugasanBlok(
                      id: id,
                      penugasan: penugasanTersimpan,
                    );

                    if (!context.mounted) return;
                    Navigator.pop(context);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Status penugasan petugas berhasil diperbarui!',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SIMLAPAS / Petugas',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Petugas',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF101828),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kelola petugas, jabatan, dan penugasan blok sesuai kewenangan.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: FutureBuilder<List<Petugas>>(
              future: _petugasController.muatSemuaPetugas(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Gagal memuat data petugas: ${snapshot.error}'),
                  );
                }

                final listPetugas = snapshot.data ?? [];

                int totalPetugas = listPetugas.length;
                final jumlahKalapas = listPetugas
                    .where((petugas) => petugas.jabatan == 'Kepala Lapas')
                    .length;
                final jumlahSipir = listPetugas
                    .where((petugas) => petugas.jabatan == 'Sipir')
                    .length;
                final sedangBertugas = listPetugas
                    .where((petugas) => petugas.isBertugas)
                    .length;

                return Column(
                  children: [
                    Row(
                      children: [
                        _buildPetugasCard(
                          'Total petugas',
                          '$totalPetugas orang',
                        ),
                        const SizedBox(width: 16),
                        _buildPetugasCard(
                          'Sedang bertugas',
                          '$sedangBertugas orang',
                        ),
                        const SizedBox(width: 16),
                        _buildPetugasCard(
                          'Kepala lapas',
                          '$jumlahKalapas orang',
                        ),
                        const SizedBox(width: 16),
                        _buildPetugasCard('Sipir', '$jumlahSipir orang'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: listPetugas.isEmpty
                            ? const Center(
                                child: Text(
                                  'Belum ada data petugas terdaftar.',
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: listPetugas.length,
                                itemBuilder: (context, index) {
                                  final petugas = listPetugas[index];
                                  final blok = petugas.labelPenugasan;
                                  final statusLabel = petugas.isBertugas
                                      ? 'Bertugas'
                                      : 'Tidak Bertugas';

                                  return _buildPetugasRow(
                                    context,
                                    petugas,
                                    petugas.nama,
                                    petugas.nip,
                                    petugas.jabatan,
                                    'Reguler',
                                    blok,
                                    statusLabel,
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetugasCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF101828),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetugasRow(
    BuildContext context,
    Petugas petugas,
    String name,
    String nip,
    String jabatan,
    String shift,
    String blok,
    String status,
  ) {
    final bool isBertugas = status == 'Bertugas';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'NIP: $nip · Jabatan: $jabatan',
                style: TextStyle(color: Colors.grey[600], fontSize: 11),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                'Shift: $shift (Penugasan: $blok)',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isBertugas ? Colors.teal[50] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: isBertugas ? Colors.teal[800] : Colors.grey[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(
                  Icons.edit,
                  size: 18,
                  color: Color(0xFF0F766E),
                ),
                onPressed: () => _tampilkanFormEditPetugas(context, petugas),
                tooltip: 'Edit Penugasan Blok & Sel',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
