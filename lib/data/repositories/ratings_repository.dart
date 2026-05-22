import 'package:marketplace_flutter_application/data/dtos/ratings/rating_dto.dart';
import 'package:marketplace_flutter_application/data/services/ratings_service.dart';
import 'package:marketplace_flutter_application/data/repositories/auth_repository.dart';
import 'package:marketplace_flutter_application/models/ratings/user_ratings.dart';

class RatingsRepository {
  final RatingsService _service;
  final AuthRepository _authRepository;

  RatingsRepository({
    required RatingsService service,
    required AuthRepository authRepository,
  }) : _service = service,
       _authRepository = authRepository;

  Future<UserRatings> getMyRatings() async {
    final token = await _authRepository.getAccessToken();
    if (token == null) throw Exception('No active session');

    final dto = await _service.getMyRatings(token);
    return _mapToModel(dto);
  }

  Future<UserRatings> getRatingsForUser(String userId) async {
    final token = await _authRepository.getAccessToken();
    if (token == null) throw Exception('No active session');

    final dto = await _service.getRatingsForUser(userId, token);
    return _mapToModel(dto);
  }

  UserRatings _mapToModel(UserRatingsDto dto) {
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
}