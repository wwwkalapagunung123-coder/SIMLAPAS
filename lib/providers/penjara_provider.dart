import 'package:flutter/foundation.dart';
import '../model/penjara.dart';
import '../repositories/penjara_repository.dart';

class PenjaraProvider with ChangeNotifier {
  final Penjara _lapas = PenjaraRepository.getDummyData();

  Penjara get lapas => _lapas;

  // Fungsi untuk merefresh atau memperbarui data
  void updateData() {
    notifyListeners();
  }
}
