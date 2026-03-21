import 'package:flutter/foundation.dart';

class SignUpModel extends ChangeNotifier {
  final dynamic _userRepository;

  SignUpModel(this._userRepository);

  bool isLoading = false;
  String? errorMessage;

  Future<void> signUp(String username, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // TODO: call backend signup
    } catch (e) {
      errorMessage = 'Error al crear usuario. Intente nuevamente.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
