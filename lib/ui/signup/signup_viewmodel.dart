import 'package:flutter/foundation.dart';
import '../../data/repositories/auth_repository.dart';

class SignUpViewModel extends ChangeNotifier {
  final AuthRepository repository;

  SignUpViewModel(this.repository);

  bool isLoading = false;
  String? errorMessage;
  bool signupSuccess = false;

  Future<void> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    if (isLoading) return;

    isLoading = true;
    errorMessage = null;
    signupSuccess = false;
    notifyListeners();

    try {
      await repository.signup(
        name: name,
        email: email,
        password: password,
      );

      signupSuccess = true;
    } catch (e) {
      errorMessage = 'No se pudo crear la cuenta';
      debugPrint('Signup error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearState() {
    errorMessage = null;
    signupSuccess = false;
    notifyListeners();
  }
}