import 'package:flutter/foundation.dart';

class LoginModel extends ChangeNotifier {
  final dynamic _userRepository;

  LoginModel(this._userRepository);

  bool isLoading = false;
  String? errorMessage;

  Future<void> login(String username, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _userRepository.login(username, password);
    } catch (e) {
      errorMessage = 'Error al iniciar sesión';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
