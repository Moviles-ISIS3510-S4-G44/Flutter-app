import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:marketplace_flutter_application/data/domains/auth/app_user.dart';
import 'package:marketplace_flutter_application/data/repositories/auth_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/ratings_repository.dart';
import 'package:marketplace_flutter_application/data/services/connectivity_service.dart';
import 'package:marketplace_flutter_application/models/ratings/user_ratings.dart';

enum ProfileDataState { loading, stale, refreshing, fresh }

class ProfileViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final RatingsRepository _ratingsRepository;
  final ConnectivityService _connectivity;

  ProfileViewModel({
    required AuthRepository repository,
    required RatingsRepository ratingsRepository,
    required ConnectivityService connectivityService,
  })  : _authRepository = repository,
        _ratingsRepository = ratingsRepository,
        _connectivity = connectivityService;

  AppUser? currentUser;
  UserRatings? ratings;
  ProfileDataState dataState = ProfileDataState.loading;
  String? errorMessage;
  DateTime? cachedAt;

  bool get isLoading => dataState == ProfileDataState.loading;
  bool get isStale => dataState == ProfileDataState.stale;
  bool get isRefreshing => dataState == ProfileDataState.refreshing;

  StreamSubscription<ConnectivityStatus>? _connectivitySub;

  void startConnectivityListener() {
    _connectivitySub?.cancel();
    _connectivitySub = _connectivity.statusStream.listen((status) {
      if (status == ConnectivityStatus.online &&
          dataState == ProfileDataState.stale) {
        _refreshInBackground();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  // Carga inicial 

  Future<void> loadProfile() async {
    if (dataState == ProfileDataState.refreshing) return;

    dataState = ProfileDataState.loading;
    errorMessage = null;
    notifyListeners();

    try {
      // Restaurar sesión desde token local (rápido, no necesita red)
      currentUser = await _authRepository.tryRestoreSession();
      if (currentUser == null) {
        errorMessage = 'Sesión expirada. Por favor inicia sesión de nuevo.';
        dataState = ProfileDataState.fresh;
        notifyListeners();
        return;
      }

      final isOnline = await _connectivity.isOnline;

      if (isOnline) {
        dataState = ProfileDataState.refreshing;
        notifyListeners();

        // Perfil y ratings en paralelo
        final results = await Future.wait([
          _authRepository.getMyProfile(),
          _ratingsRepository.getRatings(currentUser!.id),
        ]);

        currentUser = results[0] as AppUser;
        ratings = results[1] as UserRatings;
        cachedAt = null;
        dataState = ProfileDataState.fresh;
      } else {
        // Sin red: servir desde cache
        ratings = await _ratingsRepository.getRatings(currentUser!.id);
        cachedAt = await _ratingsRepository.lastUpdated(currentUser!.id);
        dataState = ProfileDataState.stale;
      }
    } catch (e) {
      // Red falló — intentar cache stale
      if (currentUser != null) {
        try {
          final stale =
              await _ratingsRepository.refreshInBackground(currentUser!.id);
          if (stale != null) ratings = stale;
          cachedAt = await _ratingsRepository.lastUpdated(currentUser!.id);
          dataState = ProfileDataState.stale;
        } catch (_) {
          errorMessage = e.toString();
          dataState = ProfileDataState.fresh;
        }
      } else {
        errorMessage = e.toString();
        dataState = ProfileDataState.fresh;
      }
    }

    notifyListeners();
  }


  Future<void> _refreshInBackground() async {
    if (currentUser == null) return;
    if (dataState == ProfileDataState.refreshing) return;

    dataState = ProfileDataState.refreshing;
    notifyListeners();

    try {
      final results = await Future.wait([
        _authRepository.getMyProfile(),
        _ratingsRepository.refreshInBackground(currentUser!.id),
      ]);

      currentUser = results[0] as AppUser;
      if (results[1] != null) ratings = results[1] as UserRatings;
      cachedAt = null;
      dataState = ProfileDataState.fresh;
    } catch (_) {
      dataState = ProfileDataState.stale;
    }

    notifyListeners();
  }

  /// Pull-to-refresh manual desde la UI
  Future<void> refresh() => _refreshInBackground();

  // Logout

  Future<void> logout() async {
    _connectivitySub?.cancel();
    await _authRepository.logout();
    if (currentUser != null) {
      await _ratingsRepository.clearCache(currentUser!.id);
    }
    currentUser = null;
    ratings = null;
    dataState = ProfileDataState.loading;
    notifyListeners();
  }
}