import 'package:flutter/material.dart';

import '../../helpers/database_helper.dart';

class OperasionalSipirScreen extends StatefulWidget {
  const OperasionalSipirScreen({super.key, required this.loggedInUser});

  final Map<String, dynamic> loggedInUser;

  @override
  State<OperasionalSipirScreen> createState() => _OperasionalSipirScreenState();
}

class _OperasionalSipirScreenState extends State<OperasionalSipirScreen> {
  final _namaNapiController = TextEditingController();
  final _noRegController = TextEditingController();
  final _keteranganInsidenController = TextEditingController();

  // Variabel untuk Pilihan Blok & Sel secara dinamis dari database
  String? _selectedBlokTujuan;
  String? _selectedSelTujuan;
  List<String> _listSelTersedia = [];

  @override
  void dispose() {
    _namaNapiController.dispose();
    _noRegController.dispose();
    _keteranganInsidenController.dispose();
    super.dispose();
  }

  String get _blokJaga => widget.loggedInUser['blok']?.toString() ?? 'Blok A';

  Future<void> _simpanNarapidanaBaru() async {
    final nama = _namaNapiController.text.trim();
    final noReg = _noRegController.text.trim();
    final keteranganInsiden = _keteranganInsidenController.text.trim();
    final tanggalHariIni = DateTime.now().toIso8601String().substring(0, 10);

    if (nama.isEmpty ||
        noReg.isEmpty ||
        _selectedBlokTujuan == null ||
        _selectedSelTujuan == null) {
      _showMessage('Nama, No. Registrasi, Blok, dan Sel wajib diisi/dipilih!');
      return;
    }

    try {
      await DatabaseHelper.instance.insertNarapidanaWithInsiden(
        {
          'no_reg': noReg,
          'nama': nama,
          'blok': _selectedBlokTujuan!,
          'sel': _selectedSelTujuan!,
          'tanggal_masuk': tanggalHariIni,
          'estimasi_bebas': '2028-01-01',
          'status': 'Aktif',
        },
        insiden: keteranganInsiden.isEmpty
            ? null
            : {
                'no_reg': noReg,
                'nama_napi': nama,
                'nip_petugas':
                    widget.loggedInUser['nip']?.toString() ?? 'SIPIR-01',
                'keterangan': keteranganInsiden,
                'tanggal': tanggalHariIni,
              },
      );
    } catch (error, stackTrace) {
      debugPrint('Gagal menyimpan narapidana dan insiden: $error\n$stackTrace');
      if (mounted) {
        _showMessage('Gagal menyimpan data narapidana atau insiden.');
      }
      return;
    }

    if (!mounted) return;
    _namaNapiController.clear();
    _noRegController.clear();
    _keteranganInsidenController.clear();
    setState(() {
      _selectedBlokTujuan = null;
      _selectedSelTujuan = null;
      _listSelTersedia.clear();
    });
    _showMessage(
      keteranganInsiden.isEmpty
          ? 'Berhasil menambahkan data narapidana ke sel terpilih!'
          : 'Data narapidana dan insiden berhasil disimpan!',
    );
  }

  Future<void> _ubahStatusNapi(
    Map<String, Object?> napi,
    String statusBaru,
  ) async {
    try {
      await DatabaseHelper.instance.updateNarapidana({
        ...napi,
        'status': statusBaru,
      });
    } catch (error, stackTrace) {
      debugPrint('Gagal memperbarui status narapidana: $error\n$stackTrace');
      if (mounted) _showMessage('Gagal memperbarui status narapidana.');
      return;
    }

    if (mounted) setState(() {});
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final namaPetugas =
        widget.loggedInUser['nama']?.toString() ?? 'Petugas Sipir';
    final nipPetugas = widget.loggedInUser['nip']?.toString() ?? '-';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SIMLAPAS / Operasional Sipir',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(height: 4),
          const Text(
            'Operasional sipir',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pengelolaan narapidana dan pencatatan insiden untuk $_blokJaga.',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                _buildInfoSipir(
                  'Petugas Bertugas',
                  '$namaPetugas (NIP: $nipPetugas)',
                ),
                _buildInfoSipir('Blok Penjagaan', 'Menjaga khusus $_blokJaga'),
                _buildInfoSipir(
                  'Sistem Akses',
                  'Database Lokal SQLite Terhubung',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 900;
                return Flex(
                  direction: compact ? Axis.vertical : Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 3, child: _buildNarapidanaList()),
                    SizedBox(width: compact ? 0 : 16, height: compact ? 16 : 0),
                    Expanded(flex: 2, child: _buildForms()),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNarapidanaList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: FutureBuilder<List<Map<String, Object?>>>(
        future: DatabaseHelper.instance.getNarapidanaByBlok(_blokJaga),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Gagal memuat daftar narapidana: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }
          final listNapi = snapshot.data ?? [];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Daftar Penghuni & Status Absensi $_blokJaga',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              if (listNapi.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Belum ada narapidana terdaftar di $_blokJaga.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ),
              for (final napi in listNapi) _buildAbsenRow(napi),
            ],
          );
        },
      ),
    );
  }

  Widget _buildForms() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _formDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tambah Narapidana dan Catat Insiden',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _namaNapiController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Narapidana',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _noRegController,
                  decoration: const InputDecoration(
                    labelText: 'No. Registrasi',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),

                // 1. Dropdown Pilih Blok Tujuan dari Database
                FutureBuilder<List<Map<String, Object?>>>(
                  future: DatabaseHelper.instance.getAllBlok(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LinearProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text(
                        'Gagal memuat daftar blok: ${snapshot.error}',
                      );
                    }
                    final listBlok = snapshot.data ?? [];
                    return DropdownButtonFormField<String>(
                      initialValue: _selectedBlokTujuan,
                      hint: const Text(
                        'Pilih Blok Tujuan',
                        style: TextStyle(fontSize: 13),
                      ),
                      isExpanded: true,
                      items: listBlok.map((b) {
                        final namaBlok = b['nama_blok']?.toString() ?? '';
                        return DropdownMenuItem<String>(
                          value: namaBlok,
                          child: Text(
                            namaBlok,
                            style: const TextStyle(fontSize: 13),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedBlokTujuan = val;
                          _selectedSelTujuan = null; // Reset pilihan sel

                          final selectedBlokData = listBlok.firstWhere(
                            (b) => b['nama_blok']?.toString() == val,
                            orElse: () => <String, Object?>{},
                          );
                          final int jumlahSel =
                              int.tryParse(
                                selectedBlokData['kapasitas_sel']?.toString() ??
                                    '8',
                              ) ??
                              8;

                          final prefix = val ?? 'A';
                          _listSelTersedia = List.generate(jumlahSel, (i) {
                            final nomorSel = (i + 1).toString().padLeft(2, '0');
                            return '$prefix-$nomorSel';
                          });
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Pilih Blok',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),

                // 2. Dropdown Pilih Nomor Sel Berdasarkan Kapasitas Blok
                DropdownButtonFormField<String>(
                  initialValue: _selectedSelTujuan,
                  hint: const Text(
                    'Pilih Nomor Sel',
                    style: TextStyle(fontSize: 13),
                  ),
                  isExpanded: true,
                  items: _listSelTersedia.map((sel) {
                    return DropdownMenuItem<String>(
                      value: sel,
                      child: Text(
                        'Sel $sel',
                        style: const TextStyle(fontSize: 13),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedSelTujuan = val;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Pilih Sel',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _keteranganInsidenController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Keterangan insiden (opsional)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _simpanNarapidanaBaru,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 38),
                  ),
                  child: const Text('Simpan Napi ke Database'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _formDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[200]!),
    );
  }

  Widget _buildInfoSipir(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Color(0xFF101828),
          ),
        ),
      ],
    );
  }

  Widget _buildAbsenRow(Map<String, Object?> napi) {
    final name = napi['nama']?.toString() ?? '';
    final reg = napi['no_reg']?.toString() ?? '';
    final sel = napi['sel']?.toString() ?? '';
    final status = napi['status']?.toString() ?? 'Aktif';
    final statusColor = status == 'Sakit' || status == 'Perlu pemeriksaan'
        ? Colors.amber
        : status == 'Tidak Hadir'
        ? Colors.red
        : Colors.teal;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                '$reg · Sel $sel',
                style: TextStyle(color: Colors.grey[600], fontSize: 11),
              ),
            ],
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _ubahStatusNapi(napi, value),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'Aktif', child: Text('Hadir / Aktif')),
              PopupMenuItem(
                value: 'Perlu pemeriksaan',
                child: Text('Perlu Pemeriksaan'),
              ),
              PopupMenuItem(value: 'Sakit', child: Text('Sakit')),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor[50],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    status,
                    style: TextStyle(
                      color: statusColor[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 16,
                    color: statusColor[800],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
