// file: lib/controllers/persetujuan_controller.dart
import '../model/narapidana.dart';
import '../model/kepala_sipir.dart';
import '../services/narapidana_service.dart';

/// Controller: Menjembatani PersetujuanScreen dengan NarapidanaService.
/// Memuat data narapidana riil dari database dan mengeksekusi method OOP Kepala Lapas.
class PersetujuanController {
  final NarapidanaService _napiService;

  PersetujuanController({NarapidanaService? napiService})
      : _napiService = napiService ?? NarapidanaService();

  /// Mengambil daftar narapidana aktif langsung dari database untuk ditinjau
  Future<List<Narapidana>> muatUsulanDariDatabase() async {
    final list = await _napiService.ambilSemuaNarapidana();
    return list.where((n) => n.status == 'Aktif').toList();
  }

  /// Eksekusi persetujuan remisi narapidana di database oleh Kepala Lapas
  Future<bool> setujuiRemisi({
    required KepalaLapas kalapas,
    required Narapidana napi,
    required int jumlahHari,
  }) async {
    return _napiService.prosesRemisiOlehKalapas(
      kalapas: kalapas,
      napi: napi,
      jumlahHari: jumlahHari,
    );
  }

  /// Eksekusi persetujuan pembebasan narapidana di database oleh Kepala Lapas
  Future<bool> setujuiPembebasan({
    required KepalaLapas kalapas,
    required Narapidana napi,
  }) async {
    return _napiService.prosesPembebasanOlehKalapas(
      kalapas: kalapas,
      napi: napi,
    );
  }
}
