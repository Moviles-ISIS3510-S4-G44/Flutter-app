import 'package:flutter/foundation.dart';

class SignUpModel extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  Future<void> SignUp(String username, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // TODO: Llamada a backend
    } catch (e) {
      errorMessage = 'Error al crear usuario. Intente nuevamente.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}