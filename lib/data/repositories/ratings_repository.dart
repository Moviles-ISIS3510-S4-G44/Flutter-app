import 'package:marketplace_flutter_application/data/dtos/ratings/user_ratings_dto.dart';
import 'package:marketplace_flutter_application/data/repositories/auth_repository.dart';
import 'package:marketplace_flutter_application/data/services/connectivity_service.dart';
import 'package:marketplace_flutter_application/data/services/ratings_service.dart';
import 'package:marketplace_flutter_application/data/storage/ratings_cache_storage.dart';
import 'package:marketplace_flutter_application/models/ratings/user_ratings.dart';

class RatingsRepository {
  final RatingsService _service;
  final RatingsCacheStorage _cache;
  final AuthRepository _authRepository;
  final ConnectivityService _connectivity;

  RatingsRepository({
    required RatingsService service,
    required RatingsCacheStorage cache,
    required AuthRepository authRepository,
    required ConnectivityService connectivity,
  })  : _service = service,
        _cache = cache,
        _authRepository = authRepository,
        _connectivity = connectivity;

  //  API pública 

  /// Estrategia: cache fresco a red, cache stale a error
  Future<UserRatings> getRatings(String userId) async {
    // 1. Cache dentro del TTL
    final cached = await _cache.get(userId);
    if (cached != null) return _toModel(cached);

    // 2. Red disponible
    final isOnline = await _connectivity.isOnline;
    if (isOnline) return _fetchAndCache(userId);

    // 3. Cache vencido (offline fallback)
    final stale = await _cache.getStale(userId);
    if (stale != null) return _toModel(stale);

    throw Exception('No hay datos de calificaciones disponibles sin conexión.');
  }

  /// Refresh silencioso, nunca lanza, usado para stale-while-revalidate
  Future<UserRatings?> refreshInBackground(String userId) async {
    try {
      final isOnline = await _connectivity.isOnline;
      if (!isOnline) return null;
      return await _fetchAndCache(userId);
    } catch (_) {
      return null;
    }
  }

  Future<DateTime?> lastUpdated(String userId) => _cache.lastUpdated(userId);

  Future<void> clearCache(String userId) => _cache.clear(userId);

  // Privado

  Future<UserRatings> _fetchAndCache(String userId) async {
    final token = await _authRepository.getAccessToken();
    if (token == null) throw Exception('Sin sesión activa');

    final dto = await _service.getRatingsForUser(userId, token);

    // Si el servicio devuelve null (404) guardamos un resultado vacío
    final result = dto ??
        UserRatingsDto(
          userId: userId,
          average: 0.0,
          total: 0,
          ratings: [],
        );

    await _cache.save(userId, result);
    return _toModel(result);
  }

  UserRatings _toModel(UserRatingsDto dto) {
    return UserRatings(
      userId: dto.userId,
      average: dto.average,
      total: dto.total,
      items: dto.ratings
          .map(
            (r) => RatingItem(
              purchaseId: r.purchaseId,
              buyerId: r.buyerId,
              score: r.score,
              purchasedAt: r.purchasedAt,
            ),
          )
          .toList(),
    );
  }

  Future<void> rateSeller({
    required String purchaseId,
    required int score,
  }) async {
    final token = await _authRepository.getAccessToken();
    if (token == null) throw Exception('Sin sesión activa');
    await _service.rateSeller(
      purchaseId: purchaseId,
      score: score,
      token: token,
    );
  }
  
}