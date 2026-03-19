import 'package:flutter/foundation.dart';
import 'package:marketplace_flutter_application/models/app_user.dart';

class LoginModel extends ChangeNotifier {
  dynamic _userRepo;
  dynamic _analytics;

  bool isLoading = false;
  String? errorMessage;
  AppUser? user;

  void init(dynamic userRepo, dynamic analytics) {
    _userRepo = userRepo;
    _analytics = analytics;
  }

  Future<void> login(String username, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      user = await _userRepo?.login(username, password);
      await _analytics?.logLogin('email');
    } catch (e) {
      errorMessage = 'Error al iniciar sesión';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // TEMP: bypass for testing without firebase
  Future<bool> bypassLogin() async {
    isLoading = true;
    notifyListeners();

    try {
      user = await _userRepo?.login('', '');
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
