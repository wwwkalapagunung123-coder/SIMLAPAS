import 'package:flutter/material.dart';

import '../../model/block.dart';
import '../../model/narapidana.dart';
import '../../model/insiden.dart';
import '../../controllers/blok_controller.dart';
import '../../controllers/narapidana_controller.dart';
import 'detail_narapidana_screen.dart';

class NarapidanaScreen extends StatefulWidget {
  const NarapidanaScreen({super.key});

  @override
  State<NarapidanaScreen> createState() => _NarapidanaScreenState();
}

class _NarapidanaScreenState extends State<NarapidanaScreen> {
  final NarapidanaController _napiController = NarapidanaController();
  final BlokController _blokController = BlokController();
  Future<void> _tampilkanFormNarapidana(
    BuildContext context, {
    Narapidana? existingNapi,
  }) async {
    final isEdit = existingNapi != null;

    final namaController = TextEditingController(
      text: existingNapi?.nama ?? '',
    );
    final noRegController = TextEditingController(
      text: existingNapi?.noRegistrasi ?? '',
    );
    final estimasiBebasController = TextEditingController(
      text:
          existingNapi?.estimasiBebas.toIso8601String().substring(0, 10) ??
          '2028-01-01',
    );
    final insidenController = TextEditingController();
    Insiden? selectedInsiden;

    String? selectedBlok = existingNapi?.blok;
    String? selectedSel = existingNapi?.selNomor;
    final listBlokFuture = _blokController.muatSemuaBlok();
    final listInsidenFuture = isEdit
        ? _napiController.muatInsiden(existingNapi.noRegistrasi)
        : Future.value(<Insiden>[]);

    try {
      await showDialog<void>(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Text(
                  isEdit ? 'Edit Data Narapidana' : 'Tambah Narapidana Baru',
                ),
                content: SingleChildScrollView(
                  child: SizedBox(
                    width: 400,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: namaController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Lengkap',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: noRegController,
                          enabled:
                              !isEdit, // No registrasi tidak boleh diubah saat edit agar relasi aman
                          decoration: const InputDecoration(
                            labelText: 'No. Registrasi',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Dropdown Pilih Blok dari Database
                        FutureBuilder<List<Blok>>(
                          future: listBlokFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const LinearProgressIndicator();
                            }
                            if (snapshot.hasError) {
                              return Text(
                                'Gagal memuat daftar blok: ${snapshot.error}',
                              );
                            }
                            final listBlok = snapshot.data ?? [];
                            if (listBlok.isEmpty) {
                              return const Text(
                                'Belum ada blok. Tambahkan blok terlebih dahulu.',
                              );
                            }

                            final selectedBlockData = listBlok
                                .where((block) => block.kode == selectedBlok)
                                .toList();
                            final capacity = selectedBlockData.isEmpty
                                ? 0
                                : selectedBlockData.first.kapasitasSel;
                            final selOptions = selectedBlockData.isEmpty
                                ? <String>[]
                                : List.generate(
                                    capacity,
                                    (index) =>
                                        '${selectedBlok!}-${(index + 1).toString().padLeft(2, '0')}',
                                  );
                            if (selectedSel != null &&
                                !selOptions.contains(selectedSel)) {
                              selOptions.add(selectedSel!);
                            }
                            final blockOptions = listBlok
                                .map((block) => block.kode)
                                .where((name) => name.isNotEmpty)
                                .toSet();

                            return Column(
                              children: [
                                DropdownButtonFormField<String>(
                                  initialValue:
                                      blockOptions.contains(selectedBlok)
                                      ? selectedBlok
                                      : null,
                                  hint: const Text('Pilih Blok'),
                                  isExpanded: true,
                                  items: blockOptions
                                      .map(
                                        (name) => DropdownMenuItem(
                                          value: name,
                                          child: Text(name),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    setDialogState(() {
                                      selectedBlok = value;
                                      selectedSel = null;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                  key: ValueKey('sel-$selectedBlok'),
                                  initialValue: selOptions.contains(selectedSel)
                                      ? selectedSel
                                      : null,
                                  hint: const Text('Pilih Nomor Sel'),
                                  isExpanded: true,
                                  items: selOptions
                                      .map(
                                        (sel) => DropdownMenuItem(
                                          value: sel,
                                          child: Text('Sel $sel'),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    setDialogState(() => selectedSel = value);
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
                        const SizedBox(height: 12),
                        TextField(
                          controller: estimasiBebasController,
                          decoration: const InputDecoration(
                            labelText: 'Estimasi Bebas (YYYY-MM-DD)',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                        if (isEdit) ...[
                          const SizedBox(height: 16),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Riwayat Insiden',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 8),
                          FutureBuilder<List<Insiden>>(
                            future: listInsidenFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const LinearProgressIndicator();
                              }
                              if (snapshot.hasError) {
                                return Text(
                                  'Gagal memuat riwayat insiden: ${snapshot.error}',
                                );
                              }
                              final insidenList = snapshot.data ?? [];
                              if (insidenList.isEmpty) {
                                return Text(
                                  'Belum ada catatan insiden untuk narapidana ini.',
                                  style: TextStyle(color: Colors.grey[600]),
                                );
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (final insiden in insidenList)
                                    Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.red[50],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Tanggal: ${insiden.tanggal} · Petugas: ${insiden.nipPetugas}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.red[800],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(insiden.keterangan),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: TextButton(
                                              onPressed: () {
                                                setDialogState(() {
                                                  selectedInsiden = insiden;
                                                  insidenController.text =
                                                      insiden.keterangan;
                                                });
                                              },
                                              child: Text(
                                                selectedInsiden?.id ==
                                                        insiden.id
                                                    ? 'Dipilih untuk diedit'
                                                    : 'Edit catatan ini',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                          if (selectedInsiden != null) ...[
                            const SizedBox(height: 12),
                            TextField(
                              controller: insidenController,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                labelText: 'Ubah keterangan insiden',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ] else
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                'Pilih satu catatan dari riwayat untuk diedit.',
                              ),
                            ),
                        ],
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
                      if (namaController.text.trim().isEmpty ||
                          noRegController.text.trim().isEmpty ||
                          selectedBlok == null ||
                          selectedSel == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Semua field wajib diisi/dipilih!'),
                          ),
                        );
                        return;
                      }

                      if (!_isValidDate(estimasiBebasController.text.trim())) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Estimasi bebas harus menggunakan format YYYY-MM-DD.',
                            ),
                          ),
                        );
                        return;
                      }

                      final keteranganInsiden = insidenController.text.trim();
                      if (selectedInsiden != null &&
                          keteranganInsiden.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Keterangan insiden tidak boleh kosong.',
                            ),
                          ),
                        );
                        return;
                      }

                      final estimasiBebas = DateTime.parse(
                        estimasiBebasController.text.trim(),
                      );

                      try {
                        if (isEdit) {
                          await _napiController.perbaruiDataNarapidana(
                            dataLama: existingNapi,
                            nama: namaController.text.trim(),
                            blok: selectedBlok!,
                            sel: selectedSel!,
                            estimasiBebas: estimasiBebas,
                            insidenTerpilih: selectedInsiden,
                            keteranganInsiden: keteranganInsiden,
                          );
                        } else {
                          await _napiController.daftarkanNarapidana(
                            nama: namaController.text.trim(),
                            noReg: noRegController.text.trim(),
                            blokNama: selectedBlok!,
                            selNomor: selectedSel!,
                            estimasiBebas: estimasiBebas,
                          );
                        }
                      } catch (error, stackTrace) {
                        debugPrint(
                          'Gagal menyimpan data narapidana atau insiden: $error\n$stackTrace',
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Gagal menyimpan data narapidana atau insiden.',
                            ),
                          ),
                        );
                        return;
                      }

                      if (!context.mounted) return;
                      Navigator.pop(context);
                      if (mounted) setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEdit
                                ? selectedInsiden == null
                                      ? 'Berhasil memperbarui data narapidana!'
                                      : 'Data narapidana dan insiden berhasil diperbarui!'
                                : 'Berhasil menambahkan narapidana baru!',
                          ),
                        ),
                      );
                    },
                    child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah'),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      namaController.dispose();
      noRegController.dispose();
      estimasiBebasController.dispose();
      insidenController.dispose();
    }
  }

  bool _isValidDate(String value) {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) return false;
    final date = DateTime.tryParse(value);
    return date != null && date.toIso8601String().substring(0, 10) == value;
  }

  // Fungsi Konfirmasi Hapus Narapidana
  void _konfirmasiHapus(BuildContext context, int id, String nama) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Narapidana'),
        content: Text(
          'Apakah Anda yakin ingin menghapus data narapidana atas nama $nama?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              try {
                await _napiController.hapusNarapidana(id);
              } catch (error, stackTrace) {
                debugPrint(
                  'Gagal menghapus data narapidana: $error\n$stackTrace',
                );
                if (!context.mounted) return;
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Gagal menghapus data narapidana.'),
                  ),
                );
                return;
              }
              if (!context.mounted) return;
              Navigator.pop(context);
              if (mounted) setState(() {});
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Data narapidana berhasil dihapus.'),
                ),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
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
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: constraints.maxWidth < 1000
                        ? 1000
                        : constraints.maxWidth,
                    child: Column(
                      children: [
                        _buildTableHeader(),
                        const Divider(height: 1),
                        Expanded(
                          child: FutureBuilder<List<Narapidana>>(
                            future: _napiController.muatSemuaNarapidana(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                    'Gagal memuat data narapidana: ${snapshot.error}',
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }
                              final listNapi = snapshot.data ?? [];
                              if (listNapi.isEmpty) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Text(
                                      'Belum ada data narapidana. Klik tombol "Tambah Narapidana" di atas.',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 13,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              }
                              return ListView.builder(
                                itemCount: listNapi.length,
                                itemBuilder: (context, index) =>
                                    _buildRowItem(context, listNapi[index]),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SIMLAPAS / Data Narapidana',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            SizedBox(height: 4),
            Text(
              'Data narapidana',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF101828),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Kelola identitas, penempatan, dan masa tahanan secara langsung dari database.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        );
        final addButton = ElevatedButton.icon(
          onPressed: () => _tampilkanFormNarapidana(context),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Tambah Narapidana'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F766E),
            foregroundColor: Colors.white,
          ),
        );

        if (constraints.maxWidth < 700) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [title, const SizedBox(height: 12), addButton],
          );
        }
        return Row(
          children: [
            const Expanded(child: title),
            addButton,
          ],
        );
      },
    );
  }

  Widget _buildTableHeader() {
    const headers = [
      (label: 'NO. REGISTRASI', flex: 2),
      (label: 'NAMA', flex: 2),
      (label: 'BLOK / SEL', flex: 1),
      (label: 'TANGGAL MASUK', flex: 2),
      (label: 'ESTIMASI BEBAS', flex: 2),
      (label: 'STATUS', flex: 1),
      (
        label: 'AKSI',
        flex: 2,
      ), // Diperlebar sedikit untuk tombol detail, edit, hapus
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          for (final header in headers)
            Expanded(
              flex: header.flex,
              child: Text(
                header.label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRowItem(BuildContext context, Narapidana napi) {
    final id = napi.id ?? 0;
    final reg = napi.noRegistrasi;
    final nama = napi.nama;
    final blok = napi.blok;
    final sel = napi.selNomor;
    final masuk = napi.tanggalMasuk.toIso8601String().substring(0, 10);
    final bebas = napi.estimasiBebas.toIso8601String().substring(0, 10);
    final status = napi.status;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              reg,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(nama, style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '$blok / $sel',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              masuk,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              bebas,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.teal[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                status,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.teal[800],
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Bagian Tombol Aksi (Detail, Edit, Hapus)
          Expanded(
            flex: 2,
            child: Row(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) =>
                            DetailNarapidanaScreen(narapidana: napi),
                      ),
                    );
                  },
                  child: const Text(
                    'Detail',
                    style: TextStyle(fontSize: 12, color: Color(0xFF0F766E)),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 16, color: Colors.blue),
                  onPressed: () =>
                      _tampilkanFormNarapidana(context, existingNapi: napi),
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                  onPressed: () => _konfirmasiHapus(context, id, nama),
                  tooltip: 'Hapus',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
