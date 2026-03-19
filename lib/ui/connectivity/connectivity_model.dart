import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../data/services/connectivity_service.dart';

class ConnectivityModel extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  Future<void> connectivity(String username, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final connectivityService = ConnectivityService();
      final isOnline = await connectivityService.isOnline;

      if (isOnline) {
        // Conectividad verificada
      }
      else {
        // mostrar mensaje de error
      }

    } catch (e) {
      errorMessage = 'Error al verificar conectividad';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}