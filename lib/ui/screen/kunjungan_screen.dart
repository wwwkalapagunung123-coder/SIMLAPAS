import 'package:flutter/material.dart';
import '../../controllers/kunjungan_controller.dart';
import '../../model/kunjungan.dart';
import '../../model/narapidana.dart';

class KunjunganScreen extends StatefulWidget {
  const KunjunganScreen({super.key});

  @override
  State<KunjunganScreen> createState() => _KunjunganScreenState();
}

class _KunjunganScreenState extends State<KunjunganScreen> {
  final KunjunganController _controller = KunjunganController();
  List<Kunjungan> _daftarKunjungan = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  Future<void> _muatData() async {
    setState(() => _isLoading = true);
    final data = await _controller.muatSemuaKunjungan();
    if (mounted) {
      setState(() {
        _daftarKunjungan = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _tampilkanDialogTambahKunjungan() async {
    final napiList = await _controller.muatDaftarNarapidana();
    if (napiList.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum ada data narapidana di database.')),
      );
      return;
    }

    final namaPengunjungController = TextEditingController();
    final hubunganController = TextEditingController(text: 'Keluarga');
    final waktuController = TextEditingController(text: '10.00 - 10.30 WIB');
    Narapidana selectedNapi = napiList.first;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Jadwalkan Kunjungan Baru'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: namaPengunjungController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Pengunjung',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: hubunganController,
                        decoration: const InputDecoration(
                          labelText: 'Hubungan (Istri/Suami/Ibu/Ayah/dsb)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<Narapidana>(
                        initialValue: selectedNapi,
                        decoration: const InputDecoration(
                          labelText: 'Pilih Warga Binaan (Database)',
                          border: OutlineInputBorder(),
                        ),
                        items: napiList.map((n) {
                          return DropdownMenuItem(
                            value: n,
                            child: Text('${n.nama} (${n.noRegistrasi})'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedNapi = val);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: waktuController,
                        decoration: const InputDecoration(
                          labelText: 'Sesi / Jam Besuk',
                          border: OutlineInputBorder(),
                        ),
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
                    if (namaPengunjungController.text.trim().isEmpty) return;

                    await _controller.jadwalkanKunjungan(
                      namaPengunjung: namaPengunjungController.text.trim(),
                      hubungan: hubunganController.text.trim(),
                      noRegNapi: selectedNapi.noRegistrasi,
                      namaNapi: selectedNapi.nama,
                      waktu: waktuController.text.trim(),
                    );

                    if (!context.mounted) return;
                    Navigator.pop(context);
                    _muatData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Jadwal kunjungan berhasil disimpan ke database!',
                        ),
                        backgroundColor: Color(0xFF0F766E),
                      ),
                    );
                  },
                  child: const Text('Simpan Jadwal'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _ubahStatusKunjungan(Kunjungan kunjungan, String status) async {
    if (kunjungan.id == null) return;
    await _controller.ubahStatus(kunjungan.id!, status);
    _muatData();
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
                    'SIMLAPAS / Kunjungan',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Kunjungan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF101828),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Data jadwal riil dari database SQLite (Clean MVC).',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _muatData,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Segarkan data',
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _tampilkanDialogTambahKunjungan,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Jadwalkan Kunjungan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F766E),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _daftarKunjungan.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada jadwal kunjungan di database.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _daftarKunjungan.length,
                      itemBuilder: (context, index) {
                        final k = _daftarKunjungan[index];
                        Color bgColor = Colors.amber[50]!;
                        Color textColor = Colors.amber[800]!;

                        if (k.status == 'Selesai') {
                          bgColor = Colors.grey[100]!;
                          textColor = Colors.grey[700]!;
                        } else if (k.status == 'Berlangsung') {
                          bgColor = Colors.teal[50]!;
                          textColor = Colors.teal[800]!;
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.teal[100],
                                foregroundColor: const Color(0xFF0F766E),
                                child: Text(
                                  k.namaPengunjung.isNotEmpty
                                      ? k.namaPengunjung[0].toUpperCase()
                                      : 'P',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${k.namaPengunjung} (${k.hubungan})',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      'Menjenguk: ${k.namaNarapidana} [${k.noRegNarapidana}]',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      'Waktu: ${k.waktu}',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  k.status,
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              PopupMenuButton<String>(
                                onSelected: (val) {
                                  if (val == 'Hapus' && k.id != null) {
                                    _controller
                                        .hapusKunjungan(k.id!)
                                        .then((_) => _muatData());
                                  } else {
                                    _ubahStatusKunjungan(k, val);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'Terjadwal',
                                    child: Text('Tandai Terjadwal'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'Berlangsung',
                                    child: Text('Tandai Berlangsung'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'Selesai',
                                    child: Text('Tandai Selesai'),
                                  ),
                                  const PopupMenuDivider(),
                                  const PopupMenuItem(
                                    value: 'Hapus',
                                    child: Text(
                                      'Hapus Jadwal',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
