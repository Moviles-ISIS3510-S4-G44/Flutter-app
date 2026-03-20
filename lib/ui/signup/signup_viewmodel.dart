import 'package:flutter/foundation.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/domains/auth/app_user.dart';

class SignUpViewModel extends ChangeNotifier {
  final AuthRepository repository;

  SignUpViewModel(this.repository);

  bool isLoading = false;
  String? errorMessage;
  AppUser? currentUser;

  bool get isAuthenticated => currentUser != null;

  Future<void> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await repository.signup(
        name: name,
        email: email,
        password: password,
      );
    } catch (e) {
      errorMessage = 'No se pudo crear la cuenta';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

}