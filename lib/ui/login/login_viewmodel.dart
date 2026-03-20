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
      debugPrint('LOGIN OK');
      debugPrint('Usuario: ${currentUser?.email}');
    } catch (e, st) {
      errorMessage = e.toString();
      debugPrint('LOGIN ERROR: $e');
      debugPrintStack(stackTrace: st);
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
    } catch (e, st) {
      errorMessage = e.toString();
      debugPrint('Login error: $e');
      debugPrintStack(stackTrace: st);
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