import 'package:flutter/foundation.dart';
import 'package:marketplace_flutter_application/data/domains/auth/app_user.dart';
import 'package:marketplace_flutter_application/data/repositories/auth_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/ratings_repository.dart';
import 'package:marketplace_flutter_application/models/ratings/user_ratings.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthRepository repository;
  final RatingsRepository ratingsRepository;

  ProfileViewModel({
    required this.repository,
    required this.ratingsRepository,
  });

  AppUser? currentUser;
  UserRatings? userRatings;
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadProfile() async {
    if (isLoading) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Carga perfil y ratings en paralelo
      final results = await Future.wait([
        repository.tryRestoreSession(),
        ratingsRepository.getMyRatings().catchError((_) => null),
      ]);

      currentUser = results[0] as AppUser?;
      userRatings = results[1] as UserRatings?;
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
    userRatings = null;
    notifyListeners();
  }
}