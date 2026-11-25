// file: lib/controllers/dashboard_controller.dart
import '../services/operasional_lapas_service.dart';

/// Controller: Menjembatani DashboardScreen dengan OperasionalLapasService.
/// Mengambil statistik riil dari database SQLite tanpa data hardcoded.
class DashboardController {
  final OperasionalLapasService _operasionalService;

  DashboardController({OperasionalLapasService? operasionalService})
      : _operasionalService = operasionalService ?? OperasionalLapasService();

  Future<Map<String, dynamic>> muatStatistikRiil() async {
    return _operasionalService.hitungStatistikLapas();
  }
}
