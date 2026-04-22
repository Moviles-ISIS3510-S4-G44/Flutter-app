import 'package:flutter/foundation.dart';
import 'package:marketplace_flutter_application/data/domains/auth/app_user.dart';
import 'package:marketplace_flutter_application/data/repositories/auth_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthRepository repository;

  ProfileViewModel({
    required this.repository,
  });

  AppUser? currentUser;
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadProfile() async {
    if (isLoading) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      currentUser = await repository.tryRestoreSession();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await repository.logout();
    currentUser = null;
    notifyListeners();
  }
}