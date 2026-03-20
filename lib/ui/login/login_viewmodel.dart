import 'package:flutter/foundation.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/domains/auth/app_user.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository repository;

  LoginViewModel(this.repository);

  bool isLoading = false;
  String? errorMessage;
  AppUser? currentUser;

  bool get isAuthenticated => currentUser != null;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    if (isLoading) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      currentUser = await repository.login(
        email: email,
        password: password,
      );
    } catch (e) {
      errorMessage = 'No se pudo iniciar sesión';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSession() async {
    if (isLoading) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      currentUser = await repository.tryRestoreSession();
    } catch (e) {
      errorMessage = 'No se pudo restaurar la sesión';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await repository.logout();
    currentUser = null;
    errorMessage = null;
    notifyListeners();
  }
}