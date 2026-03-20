import 'package:flutter/foundation.dart';

class LoginViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  Future<void> login(String username, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // TODO: Llamada a backend
    } catch (e) {
      errorMessage = 'Error al iniciar sesión';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}