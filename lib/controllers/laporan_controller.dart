// file: lib/controllers/laporan_controller.dart
import '../services/operasional_lapas_service.dart';

/// Controller: Menjembatani LaporanScreen dengan OperasionalLapasService.
class LaporanController {
  final OperasionalLapasService _operasionalService;

  LaporanController({OperasionalLapasService? operasionalService})
      : _operasionalService = operasionalService ?? OperasionalLapasService();

  /// Membuat laporan resmi lapas dari database melalui interface Laporan
  Future<String> buatLaporanResmi() async {
    return _operasionalService.buatLaporanResmiLapas();
  }

  /// Mengambil statistik riil untuk pratinjau tabel laporan
  Future<Map<String, dynamic>> muatRingkasanLaporan() async {
    return _operasionalService.hitungStatistikLapas();
  }
}
