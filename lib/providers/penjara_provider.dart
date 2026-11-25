import 'package:flutter/foundation.dart';
import '../model/penjara.dart';
import '../repositories/penjara_repository.dart';

class PenjaraProvider with ChangeNotifier {
  Penjara _lapas = PenjaraRepository.getDummyData();
  bool _isLoading = false;

  Penjara get lapas => _lapas;
  bool get isLoading => _isLoading;

  Future<void> loadFromDatabase() async {
    _isLoading = true;
    notifyListeners();
    try {
      _lapas = await PenjaraRepository.loadPenjaraFromDatabase();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  void updateData() {
    notifyListeners();
  }
}
